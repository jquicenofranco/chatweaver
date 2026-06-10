# 05 — Thinking Models y Visualizacion de Reasoning

> Especifica la capacidad de la app para exponer el proceso de razonamiento (chain-of-thought, thinking trace) de modelos que lo soportan, separandolo visualmente de la respuesta final.

---

SPEC: Thinking Models y Reasoning Display
VERSION: 1.0.0
ESTADO: DRAFT
FECHA: 2026-06-09
AUTOR: spec-architect-sdd
REVISADO POR: pendiente

---

## 1. OUTCOMES

### 1.1 Resultado para el usuario

- **OUTCOME-1**: Cuando el usuario mantiene una conversacion con un modelo que soporta reasoning (ej. MiniMax M3 con `thinking` adaptativo habilitado), el panel de reasoning se despliega automaticamente debajo del mensaje del assistant, separado de la respuesta final, sin mezclarse nunca con el contenido de la respuesta.
- **OUTCOME-2**: El usuario puede colapsar/expandir el panel de reasoning en cualquier momento. El estado de colapso es por mensaje y se recuerda en memoria durante la sesion (no se persiste entre sesiones).
- **OUTCOME-3**: Los tokens de reasoning se muestran en el `TokenMeter` como una tercera categoria, separada de input y output tokens de la respuesta.
- **OUTCOME-4**: Mensajes de modelos sin soporte de reasoning (no-thinking models) y sesiones existentes se comportan identicamente a como lo hacian antes — cero regression.

### 1.2 Resultado para el sistema

- **OUTCOME-5**: El stream del provider puede emitir reasoning y answer como **flujos independientes** (campos separados en el chunk DTO), lo que permite que la UI los maneje por separado sin necesidad de post-procesamiento.
- **OUTCOME-6**: El reasoning se persiste en la DB y sobrevive al cierre de la app, permitiendo que el usuario lo reconsulte.
- **OUTCOME-7**: La arquitectura es provider-agnostica: cualquier provider futuro que implemente `ILLMProvider` y exponga reasoning puede activar esta feature sin cambios en UI ni en la capa de dominio.

---

## 2. GLOSARIO / CONCEPTOS

### 2.1 Terminos del dominio

| Termino | Definicion |
|---|---|
| **Thinking Model** | Modelo LLM que produce un trace de razonamiento previo a generar la respuesta final. Ejemplos: MiniMax M3 (con `thinking` adaptativo), Claude with extended thinking, DeepSeek-R1, OpenAI o1. |
| **Reasoning Trace** | El texto completo del proceso de razonamiento generado por el modelo. Se descarta o se trunca en la mayoria de los casos de uso final; en ChatWeaver se preserva porque el usuario pidio verlo. |
| **Chain-of-Thought (CoT)** | Tecnica de prompting que induce al modelo a mostrar pasos intermedios. En el contexto de esta spec, el reasoning trace es la salida de CoT intern del modelo, no el resultado de un prompt instructivo. |
| **Thinking Delta** | Chunk incremental del reasoning trace, equivalente a `textDelta` pero para el proceso de razonamiento. |
| **Answer Delta** | Chunk incremental de la respuesta final. Equivalente al `textDelta` actual de `GenerateResponseChunk`. |
| **Thinking Tokens** | Tokens consumidos por el trace de razonamiento. El API del provider los devuelve en campos separados dentro de `usage`. Se cuentan contra el context window. |
| **Answer Tokens** | Tokens de la respuesta final (el comportamiento actual que spec 02 y 04 llaman "output tokens"). |
| **Reasoning Panel** | Widget UI colapsable que muestra el reasoning trace. Se renders por encima (o debajo) del mensaje del assistant, jamas intercalado. |
| **Provider Supports Reasoning** | Booleano en `ModelDefinition` que indica si el modelo seleccionado para la sesion activa puede producir un reasoning trace. |

### 2.2 Glosario de MiniMax (MVP)

| Campo en respuesta MiniMax | Mapeo en esta spec | Notas |
|---|---|---|
| `reasoning_content` (cuando `reasoning_split: true`) | `reasoningDelta` | Texto incremental del trace de razonamiento |
| `content` (respuesta final) | `textDelta` | Comportamiento actual, sin cambios |
| `completion_tokens` (standard) | `answerTokens` | Tokens de la respuesta final |
| TBD: campo specfico de MiniMax para reasoning tokens | `thinkingTokens` | **TBD** — verificar via API real. Ver Open Questions. |
| `usage.reasoning_tokens` (nombre exacto a verificar) | `thinkingTokens` | **TBD** — verificar en la documentacion real de MiniMax. |

> **Nota:** MiniMax M3 con `thinking: {"type":"adaptive"}` produce reasoning. El flag `reasoning_split: true` es el que pide al API que separe `reasoning_content` de `content`. Ver spec 03 seccion 11.3.

---

## 3. SCOPE BOUNDARIES

### 3.1 IN (lo que esta spec cubre)

- Extension de `GenerateResponseChunk` con campos para `reasoningDelta` y `thinkingTokens`.
- Extension de `MiniMaxResponseDTO` y `MiniMaxAdapter` para parsear `reasoning_content`.
- Extension de la entidad de dominio `Message` con un campo `reasoning` opcional.
- Extension de la tabla `messages` en Drift con columna `reasoning TEXT`.
- Caso de uso `SendMessage` acumula reasoning en paralelo con answer (dos buffers independientes).
- Extension de `TokenUsage` con `thinkingTokens`.
- Extension de `TokenMeter` para mostrar `thinkingTokens` como capa adicional.
- Widget `ReasoningPanel` (colapsable) renders entre el thinking trace y la respuesta final.
- Extension de `ChatState` con campo `reasoningBuffer` por mensaje en curso.
- Migracion de DB v2 → v3 (aditiva: columna nullable `reasoning`).
- Flag `supportsReasoning` en `model_configs` y `ModelDefinition`.

### 3.2 OUT (lo que esta spec NO cubre)

- **Mostrar reasoning como streamed token-by-token en tiempo real** — la UI lo recibe completo al final (despues de que el provider termina de razonar). Streaming paralelo de reasoning y answer se deja para una iteracion futura si hay demanda.
- **Edicion del reasoning por el usuario.** El trace es solo lectura.
- **Comparacion side-by-side** de reasoning vs. respuesta. Un panel vertical/horizontal es out of scope.
- **Persistencia del estado de colapso del reasoning panel entre sesiones.** No se anade columna a la DB para esto.
- **Proveedores que entrelazan reasoning y answer en un solo stream sin posibilidad de separarlos.** Si el provider no puede separar los flujos, la feature se desactiva automaticamente y el modelo se trata como no-thinking.
- **Cost estimation para thinking tokens.** Mas alla del conteo en `TokenMeter`; no se anade a `costPer1kTokens` en v1.
- **Storage de API keys en reasoning logs.** Siempre prohibido (regla existente en specs 01 y 03).

---

## 4. CONSTRAINTS

### 4.1 Tecnicos

| ID | Constraint | Justificacion |
|---|---|---|
| C-TECH-01 | `GenerateResponseChunk` debe tener `reasoningDelta: String?` y `thinkingTokens: int?` como campos nuevos, sin modificar los existentes. | Backward compatibility: providers sin reasoning siguen emitiendo chunks sin estos campos y la UI existente funciona sin cambios. |
| C-TECH-02 | El streaming de reasoning y answer son **dos campos separados** en el chunk DTO, no un unico campo mixto. | La UI necesita renderizarlos independientemente. Un campo mixto obligaria a hacer parsing heuristico, lo cual es fragil y provider-specific. |
| C-TECH-03 | La entidad `Message` de dominio (`lib/message/domain/entities/message.dart`) no conoce Drift ni Flutter. Any modification must remain a pure Dart class. | Regla arquitectonica existente en spec 01 y 02. |
| C-TECH-04 | La migracion de DB v2 → v3 es **aditiva**: se anade columna nullable `reasoning TEXT` a `messages`. No se borran ni renombran columnas existentes. | Regla de migraciones aditivas de spec 02. |
| C-TECH-05 | El widget `ReasoningPanel` vive en `lib/message/presentation/widgets/`. No conoce Drift, ni providers concretos, ni la logica de streaming. Solo recibe el texto del reasoning como parametro. | Modularity: la UI no sabe si el reasoning viene de MiniMax, OpenAI o cualquier otro provider. |
| C-TECH-06 | Los tokens de reasoning se acumulan en `TokenUsage.thinkingTokens` y se reflejan en el `TokenMeter` como una barra adicional (o componente separado). No se incluyen en `outputTokens` (respuesta final). | Convergencia con spec 02: los tres flujos de tokens (input, thinking, answer) deben ser independientes en el modelo de dominio. |

### 4.2 De negocio

| ID | Constraint | Justificacion |
|---|---|---|
| C-BIZ-01 | El reasoning NO se mezcla visualmente con la respuesta final bajo ninguna circunstancia. Si la UI detecta que el texto del reasoning contiene caracteres que parecen ser una respuesta final, no hace ningun tratamiento especial — simplemente muestra ambos paneles por separado. | Requisito explicito del usuario: "el thinking debe mantenerse visual y logicamente separado de la respuesta final". |
| C-BIZ-02 | Si el provider no soporta la separacion de reasoning (no expone `reasoning_content` o similar), la feature se desactiva silenciosamente para esa sesion. No se muestra mensaje de error. | Experiencia de usuario: el usuario eligio un modelo; si ese modelo no produce reasoning, la app se comporta como antes. |

### 4.3 De rendimiento

| ID | Constraint | Justificacion |
|---|---|---|
| C-PERF-01 | El reasoning trace puede ser largo (miles de tokens). La UI debe renderizarlo de forma eficiente (e.g., `ListView` con `ListTile` por parrafo, no un solo `Text` con el string completo). | Reasoning traces de modelos como DeepSeek-R1 pueden exceder 10k tokens. Un solo `Text` causaria lags en el scroll. |
| C-PERF-02 | La actualizacion del `TokenMeter` mientras el reasoning esta en curso no debe causar rebuilds de la pantalla de chat completa. | El streaming de reasoning ocurrira antes de que el answer empiece. La UI debe mantener 60fps durante todo el stream. |

### 4.4 De seguridad

| ID | Constraint | Justificacion |
|---|---|---|
| C-SEC-01 | El reasoning **nunca** se persiste en logs de la app ni se envia a sistemas de crash reporting que no tengan sanitizacion de datos del usuario. | Un reasoning trace puede contener informacion sensible que el usuario ingreso en su mensaje. |
| C-SEC-02 | Si el modo de clustering/analytics de la app algun dia se anade, el reasoning se exclude automaticamente. | Mismo principio: el reasoning es contenido del usuario. |

---

## 5. PRIOR DECISIONS

| Decision | Referencia | Impacto en esta spec |
|---|---|---|
| `ILLMProvider` es la unica interfaz publica del modulo `llm/`. La UI y los casos de uso solo conocen esta abstraccion. | spec 01 §3.2, spec 03 §1 | La exposicion de reasoning se hace via `GenerateResponseChunk`, no directamente desde `MiniMaxProvider`. |
| `MiniMaxProvider` se auto-registra en `LLMFactory` sin que `session/` o `ui/` lo importen directamente. | spec 01 §3.3, spec 03 §9 | La deteccion de si un modelo soporta reasoning se hace via `ModelDefinition.supportsReasoning`, no por isinstance de provider. |
| Drift se usa con migraciones versionadas; los DTOs de Drift no cruzan a `domain`. | spec 02 §1, §4 | La columna `reasoning TEXT` en `messages` se mapea a `Message.reasoning` via `MessageMapper` existente. |
| `ContextWindowManager` usa `SlidingWindowStrategy` y delega el calculo de tokens a `provider.calculateTokens()`. | spec 02 §10 | El calculo de `thinkingTokens` contra el context window se delega al provider. MiniMax aun no tiene `calculateTokens` para thinking; se documenta como TBD. |
| `TokenMeter` recibe `TokenUsage` y `contextBudget`; el proyecto es `TokenUsage` con `inputTokens` y `outputTokens`. | spec 02 §3, spec 04 §11 | Se extiende `TokenUsage` con `thinkingTokens`. |
| `ChatController` recibe `SendMessage` como caso de uso inyectado. El caso de uso es el unico que conoce el stream del provider. | spec 04 §10 | `SendMessage` acumula `reasoningDelta` en paralelo con `textDelta`, actualizando el buffer de reasoning en `Message`. |
| El prefijo `I` se usa en interfaces de provider (`ILLMProvider`). | spec 01 §6 | Si se necesitara una interfaz `IReasoningProvider` en el futuro, se aplicaria la misma convencion. No se necesita en v1. |

---

## 6. TASK BREAKDOWN

Las tareas estan ordenadas por dependencia. Las que no tienen dependencia de otra pueden ejecutarse en paralelo.

### Fase 1: Modelo de dominio y DTOs de LLM

- [T-01] Extender `GenerateResponseChunk` (`lib/llm/generate_response.dart`) con `reasoningDelta: String?` y `thinkingTokens: int?`. Los campos existentes (`textDelta`, `usage`, `finishReason`) no se modifican.
- [T-02] Extender `LlmUsage` (`lib/llm/generate_response.dart`) con `thinkingTokens: int` con default 0.
- [T-03] Extender `TokenUsage` (`lib/message/domain/entities/token_usage.dart`) con `thinkingTokens: int` con default 0.
- [T-04] Extender `Message` (`lib/message/domain/entities/message.dart`) con `reasoning: String?` nullable.
- [T-05] Extender `MiniMaxDeltaDTO` (`lib/llm/providers/minimax/dto/minimax_response_dto.dart`) con `reasoningContent: String?`. Si MiniMax no tiene este campo en su DTO nativo, se anade de todas formas como nullable para futura compatibilidad. **TBD: verificar nombre real del campo en la respuesta MiniMax.**

### Fase 2: Adapter y Provider

- [T-06] Extender `MiniMaxAdapter.toChunk` para mapear `delta.reasoningContent` → `GenerateResponseChunk.reasoningDelta`. Si `reasoningContent` es null, el chunk no tiene reasoningDelta (comportamiento backward-compatible).
- [T-07] Extender `MiniMaxProvider.generateStream` para que, cuando el provider detecte que el modelo soporta reasoning, envie `reasoning_split: true` en el request. Si no se envia, el API responde sin reasoning (y la app funciona igual).
- [T-08] Implementar en `MiniMaxProvider` el calculo de tokens para reasoning: `calculateThinkingTokens(String text)`. **TBD: MiniMax no documenta un metodo especifico; se usa la misma aproximacion que `calculateTokens` (length/4) hasta que se verifique el metodo real.** La tarea de verificacion esta en Open Questions.

### Fase 3: Base de datos

- [T-09] Anadir columna `reasoning TEXT` nullable a `Messages` en `lib/db/tables/messages_table.dart`.
- [T-10] Crear migracion v2→v3 en `AppDatabase` que anade la columna `reasoning` a `messages`. La migracion es aditiva.
- [T-11] Extender `MessageMapper` (`lib/db/mappers/message_mapper.dart`) para mapear la columna `reasoning` hacia/y desde `Message.reasoning`.
- [T-12] Extender `MessagesRepository` (`lib/message/domain/repositories/messages_repository.dart`) con `Future<void> updateReasoning(String id, String reasoning)` para hacer upsert incremental si se внедря streaming en el futuro (en v1 el reasoning llega al final).
- [T-13] Anadir test de migracion v2→v3 en `test/db/migration_v2_to_v3_test.dart`.

### Fase 4: Caso de uso SendMessage

- [T-14] Extender `SendMessage` (`lib/session/domain/usecases/send_message.dart`) para que, mientras itera sobre los chunks del stream, acumule `reasoningDelta` en un `StringBuffer reasoningBuffer` paralelo al `buffer` existente de `textDelta`.
- [T-15] Cuando llega el `finishReason` (ultimo chunk), persiste `reasoningBuffer.toString()` en la DB usando `messagesRepository.updateReasoning(assistantMsgId, reasoningBuffer.toString())` y persiste los `thinkingTokens` usando `messagesRepository.updateTokenUsage` con el campo nuevo.
- [T-16] El caso de uso `SendMessage` debe leer `ModelDefinition.supportsReasoning` del modelo activo para decidir si envia `reasoning_split: true` en el request MiniMax.

### Fase 5: UI — TokenMeter

- [T-17] Extender `TokenMeter` (`lib/message/presentation/widgets/token_meter.dart`) para aceptar `TokenUsage` con `thinkingTokens` y mostrar una segunda barra o una分区 adicional en la misma fila. Diseno: tres segmentos (input / thinking / answer) con colores distintos. **Diseno exacto a definir en colaboracion con el equipo de UX — se registra como Open Question.**
- [T-18] Extender `projectedTokensProvider` para incluir una estimacion de thinking tokens del proximo mensaje. **TBD: sin datos historicos, la estimacion inicial es 0 o un porcentaje fijo del answer estimado.**

### Fase 6: UI — ReasoningPanel widget

- [T-19] Crear `ReasoningPanel` (`lib/message/presentation/widgets/reasoning_panel.dart`): widget que recibe `String? reasoning` y `bool isStreaming`. Muestra un ExpansionTile con titulo "Razonamiento" y un icono de chip/cerebro. Contenido: `SelectableText` con el reasoning. El panel esta collapsed por defecto.
- [T-20] El `ReasoningPanel` debe soportar accessibility: `Semantics.label: 'Razonamiento del modelo, colapsado/expandido'`. Boton de copiar reasoning al portapapeles con `Semantics.label: 'Copiar razonamiento'`.
- [T-21] Si `reasoning` es null o vacio, el widget no se renderiza (devuelve `const SizedBox.shrink()`). Esto simplifica la logica del consumer.

### Fase 7: UI — ChatScreen

- [T-22] Extender `ChatState` (`lib/ui/chat/chat_controller.dart`) con `reasoningBuffer: String` que se actualiza en paralelo durante el streaming. Alternativamente, se puede obtener el reasoning directamente de la DB via `watchBySession` ya que `SendMessage` lo persiste en cada chunk (T-15).
- [T-23] Modificar `MessageBubble` (`lib/message/presentation/widgets/message_bubble.dart`) para que, cuando `message.reasoning != null`, renders el `ReasoningPanel` encima del bubble del assistant.
- [T-24] Para mensajes en streaming, `MessageBubble` debe observar el campo `reasoning` de la entidad `Message` que viene del stream del repositorio. Si el provider soporta reasoning y aun no termino, el panel aparece progresivamente (el reasoning se persiste en cada chunk de reasoning segun T-15).

### Fase 8: ModelDefinition y catalog

- [T-25] Extender `ModelDefinition` (`lib/session/domain/entities/model_definition.dart`) con `supportsReasoning: bool` con default `false`.
- [T-26] Anadir `supports_reasoning BOOLEAN NOT NULL DEFAULT 0` a `model_configs` en Drift.
- [T-27] Actualizar el seed de `model_configs` (en `AppDatabase._seedModelConfigs`) para que MiniMax M3 tenga `supports_reasoning = true`; M2.7 y M2.7-highspeed tendran `false`.

### Fase 9: Flags y configurabilidad

- [T-28] Anadir un setting global en `SettingsScreen` (spec 04 §4.5) para que el usuario pueda **desactivar** la muestra de reasoning aunque el modelo lo soporte. Preferencia almacenada en `shared_preferences` (no en DB). Key: `show_reasoning_for_thinking_models` (bool, default `true`).
- [T-29] Leer esta preferencia en `MessageBubble` antes de renderizar `ReasoningPanel`.

---

## 7. VERIFICATION CRITERIA

### 7.1 Escenarios de aceptacion

**VC-01: Sesion con modelo thinking — reasoning visible**

```
DADO un modelo MiniMax M3 configurado con supports_reasoning = true
  Y un sesion activa de chat con ese modelo
  Y el usuario tiene la preferencia show_reasoning_for_thinking_models = true
CUANDO el usuario envia un mensaje
ENTONCES el ReasoningPanel aparece debajo del mensaje del assistant, colapsado por defecto
  Y el panel muestra el trace de razonamiento completo
  Y la respuesta final aparece en un bubble separado debajo del ReasoningPanel
  Y los tres flujos de tokens (input, thinking, answer) se reflejan en el TokenMeter
```

**VC-02: Sesion con modelo no-thinking — cero cambios en UX**

```
DADO un modelo MiniMax M2.7 con supports_reasoning = false
  O un modelo con supports_reasoning = true pero la preferencia show_reasoning = false
CUANDO el usuario envia un mensaje
ENTONCES el ReasoningPanel nunca se renderiza para ese mensaje
  Y el bubble del assistant se comporta igual que antes de esta feature
  Y TokenMeter muestra solo input y answer tokens
```

**VC-03: Sesion existente cargada — reasoning persistence**

```
DADO una sesion guardada en DB con un mensaje de assistant que tiene reasoning
CUANDO el usuario abre esa sesion
ENTONCES el ReasoningPanel se renderiza con el contenido persistido
  Y el panel se puede expandir y colapsar
  Y al recargar la app, el estado de colapso se reinicia (panel colapsado)
```

**VC-04: Sesion con modelo thinking que no devolvio reasoning**

```
DADO un modelo con supports_reasoning = true
  PERO el API de ese provider no devolvio reasoning_content en la respuesta
CUANDO el mensaje se procesa
ENTONCES el ReasoningPanel no se renderiza
  Y no se muestra ningun error ni mensaje de advertencia
  Y el answer se renderiza normalmente
```

**VC-05: TokenMeter muestra tres categorias**

```
DADO una sesion con un mensaje de assistant que consumio thinking tokens
CUANDO el TokenMeter se renderiza
ENTONCES muestra tres segmentos: input tokens (azul), thinking tokens (naranja), answer tokens (verde)
  Y el tooltip muestra "Input: X | Thinking: Y | Answer: Z"
```

**VC-06: Migracion v2→v3 no pierde datos**

```
DADO una base de datos existente con schema v2
  Y sesiones con mensajes existentes
CUANDO la app hace upgrade a la version con migracion v3
ENTONCES todas las sesiones y mensajes existentes siguen existiendo
  Y la columna reasoning es null para todos los mensajes pre-existentes
  Y la app no reporta errores de migracion
```

**VC-07: Copiar reasoning al portapapeles**

```
DADO un mensaje expandido con ReasoningPanel visible
CUANDO el usuario toca el boton de copiar
ENTONCES el reasoning se copia al portapapeles del dispositivo
  Y se muestra un SnackBar "Razonamiento copiado"
  Y el contenido copiado es exactamente el texto del reasoning, sin modificacion
```

### 7.2 Criterios de no-regresion

- `flutter analyze` pasa sin warnings ni errores.
- `flutter test` pasa sin fallos.
- El comportamiento de MiniMax M2.7 (no-thinking) no cambia en nada respecto a la version anterior a esta feature.
- Sesiones guardadas en DB v2 se abren correctamente en DB v3.
- El streaming de mensajes sin reasoning sigue funcionando con la misma latencia.

---

## 8. OPEN QUESTIONS

Las siguientes preguntas requieren verificacion con la documentacion del API o con el equipo de producto antes de que la implementacion pueda completarse. Cada una tiene un responsable asignado y una fecha limite tentativa.

### OQ-01: Nombre exacto del campo reasoning en la respuesta MiniMax

- **Pregunta**: Cuando `reasoning_split: true` en el request, MiniMax devuelve `reasoning_content` en el delta o en otro campo del choice? Cual es la estructura exacta del chunk SSE?
- **Responsable**: Quien implemente T-05 y T-06
- **Fecha limite tentativa**: Antes de comenzar Fase 2
- **Accion**: Hacer un curl real a `api.minimax.io/v1/chat/completions` con `model: MiniMax-M3`, `messages: [{role: user, content: "Why is the sky blue?"}]`, `thinking: {"type":"adaptive"}`, `reasoning_split: true`, `stream: true` y observar la estructura real de los chunks SSE. No confiar en la documentacion sin verificar.
- **Impacto**: Si el nombre es diferente a `reasoningContent`, T-05 y T-06 deben actualizarse.

### OQ-02: Campo de usage para thinking tokens en MiniMax

- **Pregunta**: MiniMax devuelve un campo de `usage` especifico para los tokens de reasoning (ej. `reasoning_tokens`) o los cuenta dentro de `completion_tokens`?
- **Responsable**: Quien implemente T-08
- **Fecha limite tentativa**: Antes de comenzar Fase 2
- **Accion**: Verificar en la respuesta no-streaming del curl de OQ-01. Si `usage` tiene un campo adicional, mapearlo. Si no, los thinking tokens se estiman como la longitud del `reasoning_content` / 4 (igual aproximacion que `calculateTokens`).
- **Impacto**: Si MiniMax no devuelve un campo de usage para thinking, `thinkingTokens` en `LlmUsage` sera siempre 0 en el provider y la estimacion caera en el fallback.

### OQ-03: Diseno visual exacto del TokenMeter con tres categorias

- **Pregunta**: El equipo de UX no ha definido como se ven tres segmentos (input / thinking / answer) en el TokenMeter. Una barra con tres secciones coloreadas? Tres filas pequenas? Un grafico circular?
- **Responsable**: UX / Product Owner
- **Fecha limite**: Antes de comenzar T-17
- **Impacto**: T-17 no puede completarse sin esta decision.

### OQ-04: Estimacion de thinking tokens en projectedTokensProvider

- **Pregunta**: Sin historico de uso, como estima `projectedTokensProvider` los thinking tokens del proximo mensaje? Un porcentaje fijo del answer estimado? Un promedio movil? Cero?
- **Responsable**: Tech Lead
- **Fecha limite**: Antes de comenzar T-18
- **Impacto**: T-18. Si se pone 0, el warning de contexto cercano no aparecera para sesiones con reasoning. Aceptable para MVP.

### OQ-05: MiniMax M3 requiere habilitacion explicita de thinking?

- **Pregunta**: El flag `thinking: {"type":"adaptive"}` se necesita enviar en el request para que M3 produca reasoning, o lo hace por defecto? Si lo hace por defecto, `reasoning_split` sigue siendo necesario para separarlo?
- **Responsable**: Quien implemente T-07
- **Fecha limite**: Antes de comenzar T-07
- **Accion**: Verificar en la documentacion de MiniMax o con el curl de OQ-01 comparando respuestas con y sin `thinking` en el request.
- **Impacto**: Determina si T-16 (leer `supportsReasoning` del modelo) se usa para enviar `thinking` en el request o no.

---

## 9. CROSS-SPEC IMPACT

Esta spec implica actualizaciones en las specs existentes 02, 03 y 04. A continuacion el detalle:

### Spec 02 (Local Database And Context)

- **Cambios**: extension de `messages_table.dart` (columna `reasoning TEXT nullable`), entidad `Message` con campo `reasoning`, `TokenUsage` con `thinkingTokens`, `MessagesRepository` con `updateReasoning`, seed de `model_configs` con `supports_reasoning`.
- **Tipo de version en CHANGE LOG de spec 02**: MINOR (nueva columna nullable en tabla existente, entidad ampliada con campo optional — cambio backward-compatible).
- **_archivo**: `.specify/spec/02_Local_Database_And_Context.md`

### Spec 03 (LLM Module And MiniMax)

- **Cambios**: extension de `GenerateResponseChunk` con `reasoningDelta` y `thinkingTokens`, `LlmUsage` con `thinkingTokens`, `MiniMaxDeltaDTO` con `reasoningContent`, `MiniMaxAdapter.toChunk` con mapeo de reasoning, `MiniMaxProvider.generateStream` con envio de `reasoning_split` cuando aplica, nuevo metodo `calculateThinkingTokens`.
- **Tipo de version en CHANGE LOG de spec 03**: MINOR (campos anadidos a DTOs freezed, comportamiento backward-compatible — providers existentes siguen sin emitir reasoningDelta).
- **_archivo**: `.specify/spec/03_LLM_Module_And_MiniMax.md`

### Spec 04 (UI State And Flow)

- **Cambios**: `TokenMeter` con soporte para `thinkingTokens`, `ChatState` o la logica de `MessageBubble` para renderizar `ReasoningPanel`, preferencia `show_reasoning_for_thinking_models` en Settings, `model_configs` con `supports_reasoning` en el seed.
- **Tipo de version en CHANGE LOG de spec 04**: MINOR (widget nuevo + extension de widget existente, no hay breaking changes en flujos).
- **_archivo**: `.specify/spec/04_UI_State_And_Flow.md`

### Spec 01 (Architecture And Folders)

- **Cambios**: ninguno. La arquitectura de modulos y patrones no se ve alterada por esta feature — solo se anaden archivos dentro de modulos existentes (`message/presentation/widgets/reasoning_panel.dart`).
- **Tipo de version**: ninguna (no cambia).

---

## 10. CHANGE LOG

| Version | Fecha | Autor | Descripcion |
|---|---|---|---|
| 1.0.0 | 2026-06-09 | spec-architect-sdd | Creacion inicial de la spec. Define el modelo de dominio para reasoning separado del answer, la extension de DTOs de streaming, la migracion de DB v3, el widget ReasoningPanel, y los cambios en TokenMeter y MessageBubble. Documenta 5 Open Questions sobre MiniMax API que requieren verificacion con API real antes de implementacion. |

---

## 11. ILUSTRACION DE ARQUITECTURA (flujo de datos)

```
Provider (MiniMaxProvider)
   │
   │  stream de MiniMaxResponseDTO con reasoning_content
   ▼
MiniMaxAdapter.toChunk()
   │
   │  GenerateResponseChunk { textDelta, reasoningDelta?, thinkingTokens? }
   ▼
SendMessage (caso de uso)
   │
   ├─► buffer textDelta ──► messagesRepository.updateContent()
   │                          (Message.content)
   │
   ├─► reasoningBuffer ────► messagesRepository.updateReasoning()
   │                          (Message.reasoning)          [T-15]
   │
   └─► thinkingTokens ─────► messagesRepository.updateTokenUsage()
                                (Message.thinkingTokens)    [T-15]
                                + sessionsRepository.accumulateTokens()
                                   (session.totalThinkingTokens) [TBD: se anade?]

MessagesRepository.watchBySession()
   │
   │  Stream<List<Message>> con Message.reasoning
   ▼
MessageBubble (widget)
   │
   ├─► ReasoningPanel(reasoning) ──► ExpansionTile (collapsed)
   │                                    SelectableText + copy button
   └─► Answer bubble (comportamiento actual)
          (message.content)

TokenMeter
   │
   └─► TokenUsage { inputTokens, thinkingTokens, outputTokens }
           Three-segment progress bar
```

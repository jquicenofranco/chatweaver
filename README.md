# ChatWeaver

Cliente de chat **local-first** para múltiples proveedores de LLM, hecho en Flutter. El MVP habla con **MiniMax**, pero la arquitectura está diseñada para añadir OpenAI, Ollama, Anthropic u otros sin reescribir la lógica de chat.

**Sin backend propio. Sin registro. Sin login.** Toda la información —sesiones, mensajes, credenciales, configuración— vive en el dispositivo. La app es la dueña del contexto de la conversación y del presupuesto de tokens: no delega esa responsabilidad en el proveedor.

---

## Qué hace la app

### Onboarding en tres pasos

1. **Selección de proveedor** (`/providers`) — Lista los proveedores registrados en tiempo de ejecución. Cada uno muestra un badge de *Conectado* o *Sin configurar* según si ya tiene credenciales guardadas.
2. **Selección de modelo** (`/models`) — Catálogo del proveedor con su ventana de contexto y si soporta streaming. En MiniMax: `MiniMax-M3` (1 000 000 tokens de contexto, con razonamiento), `MiniMax-M2.7` y `MiniMax-M2.7-highspeed` (204 800 tokens).
3. **Ingreso del token** (`/token`) — Se valida la API key contra el proveedor real antes de guardarla. Si la conexión falla, el error se muestra traducido y la clave no se persiste.

La selección de proveedor va **primero** a propósito: permite cambiar de proveedor con un solo tap aunque ya existan credenciales guardadas.

### Sesiones de chat

Panel de sesiones (`/sessions`) con creación, renombrado y borrado (con diálogo de confirmación). Cada sesión muestra cuándo fue el último mensaje y cuántos tokens acumula. Desde aquí se cambia de modelo o de proveedor y se entra a Ajustes.

### Pantalla de chat

- **Respuestas en streaming**, token a token, persistidas incrementalmente en la base de datos. Si el stream se corta, se cancela o falla a mitad de camino, **lo generado hasta ese momento no se pierde**.
- **Botón de detener** para abortar la generación en curso.
- **Prompt del sistema** configurable por sesión.
- **Renombrar / borrar** la sesión desde el menú.
- Renderizado de Markdown en las respuestas.

### Razonamiento (*thinking models*)

Los modelos con razonamiento —hoy `MiniMax-M3`— exponen su cadena de pensamiento en un **panel plegable** independiente de la respuesta final.

MiniMax no devuelve el razonamiento en un campo separado: lo emite **inline dentro del `content`**, delimitado por etiquetas `<think>...</think>`. `ThinkingStreamParser` lo separa del lado del cliente mientras el stream llega, de forma defensiva, así que el panel funciona aunque el formato del proveedor cambie. El razonamiento parcial se guarda igual que el contenido: sobrevive a cancelaciones y errores.

Se puede desactivar la visualización del razonamiento desde Ajustes.

### Medidor de contexto (TokenMeter)

Barra que muestra, en una sola fila, cuánto de la ventana de contexto se está consumiendo, con tres segmentos apilados en el orden real de consumo:

| Color | Segmento |
|---|---|
| 🔵 Azul | Tokens de entrada (*input*) |
| 🟠 Naranja | Tokens de razonamiento (*thinking*) |
| 🟢 Verde | Tokens de respuesta (*output*) |

El cálculo incluye el historial, el borrador que se está escribiendo, el prompt del sistema y el máximo de salida reservado, de modo que el medidor anticipa el coste del **próximo** envío, no solo el pasado.

### Gestión del contexto

Cuando el historial no cabe en la ventana del modelo, entra `SlidingWindowStrategy`: reserva un **margen de seguridad del 10 %** del presupuesto, recorre los mensajes del más reciente al más antiguo y descarta los viejos hasta que el resto quepa, preservando el orden cronológico. El prompt del sistema se descuenta primero y nunca se recorta.

La estrategia es intercambiable (patrón Strategy): se pueden añadir otras —resumen, recuperación semántica— sin tocar los casos de uso.

### Ajustes

- **Credenciales**: listar, añadir y borrar API keys por proveedor.
- **Modelos**: habilitar o deshabilitar modelos del catálogo.
- **Mostrar razonamiento**: interruptor global.

### Internacionalización y accesibilidad

Español e inglés (118 claves de traducción). **El idioma plantilla es el español** (`app_es.arb`); el inglés se deriva de él. Los errores de red, autenticación, límite de tasa, timeout y desbordamiento de contexto se muestran siempre como mensajes legibles para una persona, nunca como excepciones crudas.

---

## Privacidad y manejo de secretos

Es la regla más importante del proyecto:

- La **API key vive únicamente** en `flutter_secure_storage` (Keychain / Keystore) y en memoria del proveedor activo.
- **Nunca** se escribe en SQLite, ni en `shared_preferences`, ni en logs.
- SQLite guarda solo un *handle* de la credencial (id, proveedor, etiqueta) — jamás el secreto.
- `SecureCredentialStore` es el único punto del código que lee o escribe la clave.

---

## Stack técnico

| Área | Elección |
|---|---|
| Estado y DI | `flutter_riverpod` |
| Navegación | `go_router` |
| Persistencia | `drift` sobre SQLite |
| Secretos | `flutter_secure_storage` |
| HTTP / streaming | `dio` |
| Modelos y codegen | `freezed`, `json_serializable` |
| Tests | `flutter_test`, `mocktail` |

---

## Arquitectura

Arquitectura **modular top-level** (no hay carpeta `core/`). Cada módulo aplica Clean Architecture internamente: `presentation → domain ← data`.

```
lib/
├── llm/          Contrato ILLMProvider, LLMFactory, LlmException
│   └── providers/minimax/    DTOs, cliente HTTP, adapter, parser de <think>
├── session/      ChatSession, ModelDefinition, repos y casos de uso (SendMessage)
├── message/      Message, TokenUsage, repos y widgets (burbuja, panel, TokenMeter)
├── db/           AppDatabase (Drift), DAOs, mappers, credenciales
├── context/      ContextStrategy + ContextWindowManager (presupuesto de tokens)
├── ui/           Pantallas, widgets compartidos, router
├── di/           global_providers.dart — todos los providers Riverpod
└── l10n/         Traducciones (.arb)
```

### Los tres patrones que lo sostienen

- **Strategy** — `ILLMProvider` es la interfaz intercambiable. El caso de uso `SendMessage` solo conoce esa abstracción; jamás ve un tipo concreto de proveedor.
- **Factory** — `LLMFactory` mantiene un registro de constructores. Cada proveedor se registra **explícitamente** (`MiniMaxProvider.registerSelf(factory)`) desde `global_providers.dart`. No se usa auto-registro por efecto secundario de import, porque Dart no garantiza el orden de los imports.
- **Adapter** — `MiniMaxAdapter` traduce los DTOs del proveedor a entidades de dominio, de modo que ningún tipo específico del proveedor llega nunca a la UI ni al almacenamiento.

### Flujo de un mensaje

```
ChatScreen → ChatController → SendMessage
   → ContextWindowManager.trimHistory()   (recorta el historial al presupuesto)
   → ILLMProvider.generateStream()        (streaming del proveedor)
   → persistencia incremental en Drift    (contenido + razonamiento, por chunk)
   → la UI se redibuja desde messagesStreamProvider
```

Drift es la **única fuente de verdad** del contenido de los mensajes: la UI no lee del estado del controlador, lee de la base de datos. Por eso lo generado sobrevive a cierres, cancelaciones y errores.

### Añadir un proveedor nuevo

Solo cambian dos cosas: se crea `lib/llm/providers/<id>/` y se añade **una línea** de registro en `lib/di/global_providers.dart`. La UI y la capa de almacenamiento no se tocan. El catálogo de proveedores de la pantalla se deriva en runtime de `LLMFactory.supportedProviders`, así que registrar el proveedor es lo que lo hace aparecer.

### Base de datos

Drift, `schemaVersion = 3`. Tablas: `model_configs`, `sessions`, `messages`, `credential_handles`. Las migraciones son idempotentes, están cubiertas por tests (`test/db/`) y respetan `PRAGMA foreign_keys = ON`.

| Versión | Cambio |
|---|---|
| v1 | Esquema original |
| v2 | Reemplazo de IDs de modelo obsoletos por los reales de la API |
| v3 | Columnas de razonamiento: `reasoning`, `thinking_tokens`, `supports_reasoning` |

---

## Puesta en marcha

Todos los comandos se ejecutan desde `chatweaver/`.

```bash
flutter pub get                                          # dependencias
dart run build_runner build --delete-conflicting-outputs # codegen (freezed/Drift/json)
flutter run                                              # ejecutar la app
```

Necesitás una **API key de MiniMax** (`https://api.minimax.io/v1`). La app la pide en el onboarding y la valida contra el proveedor antes de guardarla.

### Desarrollo

```bash
flutter analyze                              # análisis estático (debe quedar limpio)
dart format .                                # formato
flutter test                                 # suite completa
flutter test test/ruta/al/archivo_test.dart  # un archivo
flutter test --plain-name "descripción"      # un test por nombre
flutter gen-l10n                             # regenerar traducciones
```

Hay que volver a correr `build_runner` después de tocar cualquier `@freezed`, tabla de Drift o DTO. Los archivos generados (`*.g.dart`, `*.freezed.dart`, `lib/l10n/generated/`) **se versionan** en el repo: hay que regenerarlos y commitearlos junto al cambio que los provoca.

El analizador corre con lints estrictos (`strict-casts`, `strict-inference`, `strict-raw-types`, comas finales obligatorias, sin `print`).

---

## Documentación

- `.specify/spec/` — **Especificaciones normativas: son la fuente de verdad.** Arquitectura, base de datos y contexto, módulo LLM y MiniMax, UI y flujo de estado, y modelos con razonamiento.
- `.specify/plans/IMPLEMENTATION_PLAN.md` y `.specify/checklists/` — Plan de implementación en 20 fases con sus checklists.
- `CLAUDE.md` — Guía para agentes de código que trabajen en el repo.

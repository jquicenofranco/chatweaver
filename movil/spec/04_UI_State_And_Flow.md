# 04 — Estado de UI y Flujo

> Especifica las pantallas, su estado asociado (Riverpod), el flujo de navegacion con `go_router`, el `ChatController` con el caso de uso `SendMessage`, el widget `TokenMeter`, y el flujo de actualizacion en tiempo real de tokens.

---

## 1. Principios de UX

- **Sin login.** El primer arranque lleva directo al selector de modelos.
- **Cero friccion.** El usuario elige un modelo, pega un token, ve sus chats.
- **Offline-first.** Toda la lista de sesiones se sirve desde el storage local, sin spinners ni esperas.
- **Streaming visible.** El usuario ve aparecer la respuesta token a token con un caret parpadeante.
- **Reversible.** Renombrar y borrar chats son siempre confirmables.
- **Sin limite de caracteres** en el input del prompt.

---

## 2. Mapa de pantallas

```
SplashRoute (/)
        │
        ▼ (redirect condicional)
┌──────────────────┐
│  ModelSelector   │  Lista de modelos activos
└────────┬─────────┘
         │ tap modelo
         ▼
┌──────────────────┐
│  TokenInput      │  Pegar API key + validar
└────────┬─────────┘
         │ test OK
         ▼
┌──────────────────┐
│ SessionsPanel    │  CRUD de sesiones
└────────┬─────────┘
         │ tap sesion o "Nueva"
         ▼
┌──────────────────┐
│  ChatScreen      │  Interfaz de chat
└──────────────────┘
```

Acciones globales:

- `AppBar` accion **"Modelos"** → vuelve a `ModelSelector`.
- `AppBar` accion **"Ajustes"** → gestiona credenciales, modelos deshabilitados, system prompts por defecto.

---

## 3. Navegacion con `go_router`

### 3.1 Rutas

| Ruta | Pantalla | Recibe |
|---|---|---|
| `/` | `SplashRoute` | — |
| `/models` | `ModelSelectorScreen` | — |
| `/token` | `TokenInputScreen` | `modelId` (query) |
| `/sessions` | `SessionsPanelScreen` | `modelId` (query) |
| `/chat/:sessionId` | `ChatScreen` | `sessionId` (path) |
| `/settings` | `SettingsScreen` | — |

### 3.2 Redirect de splash

```dart
GoRoute(
  path: '/',
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final hasAny = container.read(hasAnyCredentialProvider).valueOrNull ?? false;
    return hasAny ? '/sessions' : '/models';
  },
)
```

> Al primer arranque no hay credenciales → vamos a `/models`. Tras guardar el primer token, el siguiente arranque va directo a `/sessions`.

### 3.3 Transicion entre credenciales y panel

El flujo es: `/models` → tap → `/token?modelId=xxx` → validar → guardar → pushReplacement a `/sessions?modelId=xxx`.

---

## 4. Pantallas en detalle

### 4.1 `ModelSelectorScreen`

**Proposito:** elegir el modelo LLM a usar.

**Estado (Riverpod):**

```dart
final availableModelsProvider = FutureProvider<List<ModelDefinition>>((ref) async {
  return ref.read(modelCatalogRepositoryProvider).listEnabled();
});
```

**Layout:**

- `AppBar` con titulo "Elegi un modelo" y accion `Icon(Icons.settings)` → `/settings`.
- `ListView` de `ModelCard`:
  - Icono del proveedor (placeholder para MVP).
  - Nombre del modelo.
  - Subtitulo: "200k tokens • streaming".
  - Badge "free" / "paid".
- Estado vacio: ilustracion + "No hay modelos habilitados. Toca Ajustes."

**Acciones:**

- Tap en `ModelCard` → `context.go('/token?modelId=${model.id}')`.
- Long-press → bottom sheet con "Deshabilitar" (actualiza `model_configs.enabled`).

---

### 4.2 `TokenInputScreen`

**Proposito:** capturar y validar la API key del provider.

**Estado:**

```dart
final connectionTestProvider = StateNotifierProvider.autoDispose<
    ConnectionTestController, AsyncValue<void>>(
  (ref) => ConnectionTestController(ref),
);
```

`ConnectionTestController`:

```dart
class ConnectionTestController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  ConnectionTestController(this._ref) : super(const AsyncData(null));

  Future<String?> test({
    required String apiKey,
    required String modelId,
  }) async {
    state = const AsyncLoading();
    try {
      // 1. Cargar definicion del modelo desde el catalogo local.
      final def = await _ref.read(modelCatalogRepositoryProvider).getById(modelId);
      if (def == null) {
        const err = 'Modelo no encontrado en el catalogo';
        state = AsyncError(err, StackTrace.current);
        return err;
      }

      // 2. Construir el provider con la definicion real.
      final provider = _ref.read(llmProviderFactoryProvider).build(
        providerId: def.providerId,
        modelId: def.id,
        apiKey: apiKey,
        contextWindow: def.contextWindow,
        dio: _ref.read(dioProvider),
      );

      // 3. Probar conexion.
      final err = await provider.testConnection(apiKey: apiKey);
      if (err != null) {
        state = AsyncError(err, StackTrace.current);
        return err;
      }
      state = const AsyncData(null);
      return null;
    } catch (e, st) {
      state = AsyncError(e, st);
      return e.toString();
    }
  }
}
```

**Layout:**

- Header con nombre del modelo y provider.
- `TextField` monoespaciado, password obscure, multilinea (los API keys son largos), `autocorrect: false`.
- `SwitchListTile` "Recordar token" (default ON, persiste en secure storage).
- Boton "Probar y continuar" (loading state mientras `test` corre).
- Link "Donde consigo mi token?" → abre URL en `url_launcher`.

**Acciones:**

- Submit → `controller.test(apiKey, modelId)`.
- Exito → guarda en secure storage (si "Recordar" esta ON), `context.pushReplacement('/sessions?modelId=$modelId')`.
- Error → `SnackBar` con el mensaje devuelto por el tester.

---

### 4.3 `SessionsPanelScreen`

**Proposito:** CRUD de sesiones del modelo activo.

**Estado:**

```dart
final activeModelIdProvider = StateProvider<String?>((_) => null);

final sessionsStreamProvider = StreamProvider<List<ChatSession>>((ref) {
  final modelId = ref.watch(activeModelIdProvider);
  if (modelId == null) return Stream.value([]);
  return ref.read(sessionsRepositoryProvider).watchByModel(modelId);
});
```

**Layout:**

- `AppBar`:
  - Titulo: nombre del modelo activo.
  - Acciones: "Modelos" (`/models`), "Ajustes" (`/settings`).
- `ListView.separated` de `SessionTile`:
  - Titulo (editable in-place con long-press).
  - Subtitulo: "hace 2 h • 1.2k tokens" (formato `intl`).
  - `trailing`: `PopupMenu` (Renombrar, Borrar).
- `FloatingActionButton.extended` "Nueva sesion".
- Estado vacio: ilustracion + "Empeza tu primera conversacion" + boton CTA.

**Acciones:**

- Tap sesion → `context.push('/chat/${session.id}')`.
- "Nueva sesion" → `context.push('/chat/$newId')` (crea sesion via `CreateSession` use case).

```dart
// lib/session/domain/usecases/create_session.dart
class CreateSession {
  final SessionsRepository _repo;
  final Uuid _uuid;
  CreateSession(this._repo, this._uuid);

  Future<String> call({
    required String modelId,
    required String providerId,
    String title = 'Nueva sesion',
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _repo.create(ChatSession(
      id: id,
      title: title,
      modelId: modelId,
      providerId: providerId,
      createdAt: now,
      updatedAt: now,
    ));
    return id;
  }
}

final createSessionProvider = Provider<CreateSession>((ref) {
  return CreateSession(
    ref.read(sessionsRepositoryProvider),
    ref.read(uuidProvider),
  );
});
```

- Renombrar → `AlertDialog` con `TextField` precargado.
- Borrar → `AlertDialog` de confirmacion tipo "warning".

---

### 4.4 `ChatScreen`

**Proposito:** interfaz de chat con input libre, metricas de tokens y contexto.

**Estado (Riverpod):**

```dart
// Watch del stream de mensajes de la sesion
final messagesStreamProvider = StreamProvider.family<List<Message>, String>(
  (ref, sessionId) =>
      ref.read(messagesRepositoryProvider).watchBySession(sessionId),
);

// Watch de la sesion
final sessionProvider = FutureProvider.family<ChatSession?, String>(
  (ref, sessionId) =>
      ref.read(sessionsRepositoryProvider).getById(sessionId),
);

// Controller de chat
final chatControllerProvider = StateNotifierProvider.autoDispose
    .family<ChatController, ChatState, String>(
  (ref, sessionId) => ChatController(
    sessionId: sessionId,
    ref: ref,
    sendMessage: ref.read(sendMessageProvider(sessionId)),
  ),
);
```

`sendMessageProvider(sessionId)` es un `Provider.family` que construye el caso de uso `SendMessage` resolviendo: `ILLMProvider` (via `activeLlmProviderProvider(sessionId)`), `ContextWindowManager`, `SessionsRepository`, `MessagesRepository`. Asi `ChatController` recibe un caso de uso listo y no se acopla a 4 providers distintos.

`ChatState` (freezed):

```dart
@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    required List<Message> messages,
    @Default(false) bool isStreaming,
    @Default(TokenUsage()) TokenUsage sessionUsage,
    /// Se inicializa desde la sesion (`session.contextWindow`).
    required int contextBudget,
    @Default('') String draft,
    String? error,
  }) = _ChatState;
}
```

`ChatController`:

```dart
class ChatController extends StateNotifier<ChatState> {
  final String sessionId;
  final SendMessage _sendMessage;
  CancelToken? _cancelToken;

  ChatController({
    required this.sessionId,
    required Ref ref,
    required SendMessage sendMessage,
  })  : _sendMessage = sendMessage,
        super(_initialState(ref, sessionId));

  static ChatState _initialState(Ref ref, String sessionId) {
    final session = ref.read(sessionProvider(sessionId)).valueOrNull;
    return ChatState(
      messages: const [],
      contextBudget: session?.contextWindow ?? 0,
    );
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    _cancelToken = CancelToken();
    state = state.copyWith(isStreaming: true, error: null);
    try {
      await _sendMessage(
        sessionId: sessionId,
        userText: text,
        cancelToken: _cancelToken,
      );
    } on LlmException catch (e) {
      state = state.copyWith(error: e.userMessage);
    } finally {
      state = state.copyWith(isStreaming: false);
    }
  }

  void abort() => _cancelToken?.cancel('user_aborted');

  void updateDraft(String draft) {
    state = state.copyWith(draft: draft);
  }
}
```

**Layout (de arriba a abajo):**

1. `AppBar`:
   - Titulo editable de la sesion (tap para renombrar).
   - Accion "Stop" (visible solo si `isStreaming`).
   - Overflow: Renombrar, System Prompt, Borrar sesion.
2. `TokenMeter` widget: barra de progreso `sessionUsage / contextBudget`, color verde/amarillo/rojo, tooltip con numeros exactos.
3. `Expanded` con `ListView.builder` inverso de `MessageBubble`.
4. `PromptInput` widget: `TextField` multilinea autocrecimiento, boton enviar, hint "Escribi tu mensaje…".

---

### 4.5 `SettingsScreen`

**Proposito:** gestionar credenciales, modelos deshabilitados, preferencias.

**Secciones:**

- **Credenciales:** lista de `CredentialHandle`. Tap → editar (pegar nuevo token + re-validar). Long-press → borrar.
- **Modelos:** switch on/off por modelo.
- **Apariencia:** tema (light/dark/system).
- **Idioma:** selector.
- **Avanzado:** `intl` formatos, politica de truncado, exportar/borrar todos los datos.
- **Acerca de:** version, licencias, link a codigo.

---

## 5. Componentes compartidos (`ui/shared/`)

| Widget | Proposito |
|---|---|
| `PrimaryButton` | Boton estandar con loading state |
| `LoadingOverlay` | Spinner sobre pantalla con mensaje |
| `ErrorView` | Ilustracion + mensaje + boton "Reintentar" |
| `ConfirmDialog` | Dialogo reutilizable para borrados y acciones destructivas |
| `EmptyStateView` | Ilustracion + texto + CTA opcional |

---

## 6. Estados vacios y de error (matriz)

| Pantalla | Estado | Componente |
|---|---|---|
| `ModelSelector` | sin modelos | `EmptyStateView` + "Ir a Ajustes" |
| `ModelSelector` | error al cargar | `ErrorView` con "Reintentar" |
| `TokenInput` | test fallido | `SnackBar` con mensaje del tester |
| `SessionsPanel` | sin sesiones | `EmptyStateView` + CTA "Nueva sesion" |
| `SessionsPanel` | error al cargar | `ErrorView` con "Reintentar" |
| `Chat` | sin mensajes | Hint "Escribi tu primer mensaje abajo" |
| `Chat` | envio fallido | `MessageBubble` con badge rojo + boton "Reintentar" |
| `Chat` | context overflow | `Banner` amarillo + "Se descartaron N mensajes antiguos" |
| `Settings` | sin credenciales | `EmptyStateView` con CTA "Agregar credencial" |

---

## 7. Theming

- **Material 3**, `ColorScheme.fromSeed(seedColor: Color(0xFF6750A4))` (violeta suave).
- Soporte dark/light automatico segun `themeMode` del sistema.
- Tipografia: Roboto (default); `displayLarge` para branding.
- Radio de bordes: 16 px en tarjetas, 24 px en inputs.
- Espaciado: multiplos de 4.
- Tamanos minimos de touch: 48x48 dp.

---

## 8. Accesibilidad

- Todos los botones con `Semantics` label.
- Contraste WCAG AA verificado.
- Focus traversal con teclado fisico (tablet).
- TalkBack / VoiceOver verificados en smoke tests.
- Mensajes con `Semantics.liveRegion` para que el lector de pantalla anuncie la respuesta del assistant al llegar.

---

## 9. Internacionalizacion

- Strings en `lib/l10n/app_es.arb` y `lib/l10n/app_en.arb` con `flutter_localizations` + `intl`.
- **MVP:** `es` (default) y `en`.
- Fechas y numeros formateados con `intl.DateFormat` e `intl.NumberFormat`.
- Tokens se formatean con separador de miles (`1.234` en es, `1,234` en en).

---

## 10. El caso de uso `SendMessage`

```dart
// lib/session/domain/usecases/send_message.dart
class SendMessage {
  final ILLMProvider _provider;                 // Strategy
  final SessionsRepository _sessions;
  final MessagesRepository _messages;
  final ContextWindowManager _context;
  final Uuid _uuid;

  SendMessage({
    required ILLMProvider provider,
    required SessionsRepository sessions,
    required MessagesRepository messages,
    required ContextWindowManager context,
    required Uuid uuid,
  })  : _provider = provider,
        _sessions = sessions,
        _messages = messages,
        _context = context,
        _uuid = uuid;

  Future<void> call({
    required String sessionId,
    required String userText,
    CancelToken? cancelToken,
  }) async {
    // 1. Cargar sesion e historial.
    final session = await _sessions.getById(sessionId);
    if (session == null) throw SessionNotFoundException(sessionId);

    final history = await _messages.listBySession(sessionId);

    // 2. Convertir historial persisted (Message/message) a formato LLM (ChatMessage/llm).
    //    Esto es el adapter inverso: DB -> wire format.
    final historyAsChat = history
        .map((m) => ChatMessage(
              role: _toChatRole(m.role),
              content: m.content,
              timestamp: m.createdAt,
            ))
        .toList();

    // 3. Truncar contexto al budget del modelo, descontando el system prompt.
    //    ContextWindowManager delega en provider.calculateTokens().
    final trimmed = _context.trimHistory(
      historyAsChat,
      systemPrompt: session.systemPrompt,
    );

    // 4. Persistir mensaje del usuario.
    final userMsgId = _uuid.v4();
    await _messages.append(Message(
      id: userMsgId,
      sessionId: sessionId,
      role: MessageRole.user,
      content: userText,
      status: MessageStatus.complete,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
    ));
    await _sessions.touch(sessionId, DateTime.now());

    // 5. Construir GenerateRequest (incluye el nuevo userText
    //    que no esta en trimmed — el provider lo recibe por encima).
    final request = GenerateRequest(
      messages: [
        ...trimmed,
        ChatMessage(
          role: ChatRole.user,
          content: userText,
          timestamp: DateTime.now(),
        ),
      ],
      systemPrompt: session.systemPrompt,
    );

    // 6. Crear placeholder assistant y streamear.
    final assistantMsgId = _uuid.v4();
    await _messages.append(Message(
      id: assistantMsgId,
      sessionId: sessionId,
      role: MessageRole.assistant,
      content: '',
      status: MessageStatus.streaming,
      createdAt: DateTime.now(),
    ));

    final buffer = StringBuffer();
    try {
      await for (final chunk in _provider.generateStream(
        request: request,
        cancelToken: cancelToken,
      )) {
        if (chunk.errorMessage != null) {
          await _messages.updateStatus(
            assistantMsgId, MessageStatus.failed, error: chunk.errorMessage);
          throw ProviderException(chunk.errorMessage!);
        }
        if (chunk.textDelta != null) {
          buffer.write(chunk.textDelta);
          await _messages.updateContent(assistantMsgId, buffer.toString());
        }
        if (chunk.usage != null) {
          await _messages.updateTokenUsage(
            assistantMsgId,
            inputTokens: chunk.usage!.inputTokens,
            outputTokens: chunk.usage!.outputTokens,
          );
          await _sessions.accumulateTokens(
            sessionId,
            input: chunk.usage!.inputTokens,
            output: chunk.usage!.outputTokens,
          );
        }
        if (chunk.finishReason != null) {
          await _messages.updateStatus(
            assistantMsgId, MessageStatus.complete);
          await _messages.patch(assistantMsgId, completedAt: DateTime.now());
        }
      }
    } on CancelToken {
      // El usuario aborto. El texto parcial queda persistido.
      await _messages.updateStatus(assistantMsgId, MessageStatus.complete);
      await _messages.patch(assistantMsgId, completedAt: DateTime.now());
      rethrow;
    }
  }

  ChatRole _toChatRole(MessageRole r) => switch (r) {
        MessageRole.system => ChatRole.system,
        MessageRole.user => ChatRole.user,
        MessageRole.assistant => ChatRole.assistant,
      };
}

/// Excepcion que indica que la sesion solicitada no existe.
/// Vive en lib/session/domain/exceptions/session_not_found_exception.dart.
class SessionNotFoundException implements Exception {
  final String sessionId;
  const SessionNotFoundException(this.sessionId);
  @override
  String toString() => 'SessionNotFoundException: $sessionId';
}
```

---

## 11. TokenMeter — widget de medicion de contexto

```dart
// lib/message/presentation/widgets/token_meter.dart
class TokenMeter extends StatelessWidget {
  final TokenUsage usage;         // tokens acumulados en la sesion
  final int contextBudget;        // contextWindow - maxOutput
  final double projectedRatio;    // ratio estimado del proximo envio

  const TokenMeter({
    super.key,
    required this.usage,
    required this.contextBudget,
    required this.projectedRatio,
  });

  @override
  Widget build(BuildContext context) {
    final usedRatio = usage.total / contextBudget;
    final color = _colorFor(usedRatio);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: usedRatio.clamp(0.0, 1.0),
                color: color,
                backgroundColor: color.withOpacity(0.15),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${usage.total} / ${contextBudget}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        if (projectedRatio > 0.85)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.warning_amber, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  'Proximo mensaje usara ${(projectedRatio * 100).toInt()}% del contexto',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _colorFor(double ratio) {
    if (ratio < 0.60) return Colors.green;
    if (ratio < 0.85) return Colors.amber;
    return Colors.red;
  }
}
```

**Logica de actualizacion en tiempo real:**

```dart
// Provider que calcula el ratio proyectado del proximo envio.
// Se recalcula cada vez que cambia el draft o los mensajes.
final projectedTokensProvider = Provider.autoDispose<int>((ref) {
  final messages = ref.watch(messagesStreamProvider).valueOrNull ?? [];
  final draft = ref.watch(chatControllerProvider).draft;
  final session = ref.watch(sessionProvider).valueOrNull;
  if (session == null) return 0;

  final provider = ref.watch(activeLlmProviderProvider(session.id)).valueOrNull;
  if (provider == null) return 0;

  // Estimacion: historial + draft + system prompt + maxOutput.
  // La logica detallada esta en ContextWindowManager.estimateNextSendTokens
  // (ver 02 §10.5). Aqui se duplica la cuenta para evitar construir
  // el manager solo para el calculo de la UI.
  const perMessageOverhead = 4;
  var total = provider.calculateTokens(draft) + perMessageOverhead + 1024;
  if (session.systemPrompt != null && session.systemPrompt!.isNotEmpty) {
    total += provider.calculateTokens(session.systemPrompt!) + perMessageOverhead;
  }
  for (final m in messages) {
    total += provider.calculateTokens(m.content) + perMessageOverhead;
  }
  return total;
});
```

---

## 12. Flujos de usuario resumidos

### Flujo 1: Primer uso

1. Arranca la app → splash → no hay credenciales → `/models`.
2. Usuario tap "MiniMax M" → `/token?modelId=MiniMax-M`.
3. Pega token → "Probar" → spinner → exito.
4. SnackBar "Conectado" → navega a `/sessions?modelId=MiniMax-M`.
5. Pantalla vacia con CTA → tap → crea sesion → `/chat/:id`.
6. Escribe prompt (sin limite) → respuesta streaming via `provider.generateStream()`.
7. Cierra la app. Estado preservado (sesion, mensajes, metricas).

### Flujo 2: Vuelta a una sesion existente

1. App abierta → splash → credencial existente → `/sessions`.
2. Lista de sesiones anteriores (ordenadas por `last_message_at` desc).
3. Tap en una → `/chat/:id`.
4. Historial cargado al instante via `Stream`.
5. Escribe nuevo mensaje → contexto previo se envia al provider (con truncado si excede el budget).

### Flujo 3: Cambio de modelo

1. `SessionsPanel` → overflow o AppBar "Modelos" → `/models`.
2. Elige otro modelo (incluso de otro provider) → `/token`.
3. Si ya tiene credencial de ese provider, omite `/token` (futuro).
4. Vuelve a `/sessions?modelId=nuevo`.

### Flujo 4: Manejo de error de auth

1. Usuario pega token expirado → `provider.testConnection()` devuelve "Token invalido o expirado".
2. `SnackBar` con el mensaje.
3. Usuario corrige y reintenta, o navega atras.

### Flujo 5: Stop durante streaming

1. Usuario envia prompt largo → respuesta streaming via `provider.generateStream()`.
2. Tap "Stop" → `cancelToken.cancel('user_aborted')`.
3. Mensaje assistant queda con `status = complete` y el texto recibido hasta el momento.
4. El usuario puede reenviar el prompt o editarlo.

---

## 13. Resumen de invariantes UI

1. Las pantallas son `ConsumerWidget` o `ConsumerStatefulWidget`. No usan `Provider.of` ni `setState` para estado global.
2. Toda mutacion pasa por un **provider** o un **caso de uso**, no por llamadas directas al repositorio desde la UI.
3. La UI nunca conoce Drift ni Dio.
4. Los textos hardcodeados estan prohibidos en `presentation/`; usar `AppLocalizations.of(context).key`.
5. El input de chat no tiene `maxLength` (requisito explícito).
6. La app **no** muestra pantallas de login, splash de marca largo, ni onboarding obligatorio.
7. La UI nunca ve `DioException` ni codigos de error HTTP crudos; `parseNetworkError` traduce todo a `LlmException.userMessage`.

# 02 — Base de Datos Local y Manejo de Contexto

> Especifica el motor de base de datos, los esquemas de tablas, las entidades del dominio, los DAOs, los repositorios, y la logica algoritmica detallada de inyeccion de contexto (SlidingWindowStrategy con pseudocodigo paso a paso).

---

## 1. Decision: Drift (SQLite)

**Motor elegido: Drift v2 sobre SQLite nativo.**

### 1.1 Comparativa

| Criterio | Drift | Isar 3.x | Hive |
|---|---|---|---|
| Mantenimiento activo | ✅ | ⚠️ 3.x en pausa, v4 incierto | ✅ |
| Datos relacionales (FK, joins) | ✅ | ⚠️ links manuales | ❌ |
| Full-text search (FTS5) | ✅ nativo | ❌ | ❌ |
| Migraciones versionadas | ✅ `schemaVersion` | ⚠️ | ❌ |
| Queries type-safe (compilacion) | ✅ | ✅ | ❌ |
| Performance con miles de filas | ✅ | ✅✅ | ✅ |

**Justificacion detallada:**

- La informacion de un chat es **intrinsecamente relacional** (una sesion tiene muchos mensajes). Forzar links manuales en Isar anade friccion.
- Necesitamos **busqueda** sobre el historial (FTS5).
- Drift esta **activamente mantenido** y tiene comunidad amplia.
- El rendimiento de SQLite es mas que suficiente para un chat local; Isar gana en benchmarks sinteticos, pero no en un caso de uso real de chat.

### 1.2 Ubicacion de la base de datos

- Path: `<applicationDocumentsDirectory>/chatweaver.db`
- Version inicial: `schemaVersion = 1`
- Creada via `drift_flutter` que resuelve el path multiplataforma.
- Una sola conexion en produccion.

---

## 2. Tablas

### 2.1 `model_configs`

Catalogo local de modelos disponibles. Sembrado en el primer arranque.

| Columna | Tipo | Notas |
|---|---|---|
| `id` | TEXT PK | Identificador unico, ej. `MiniMax-M` |
| `provider_id` | TEXT NOT NULL | Apunta al provider (`MiniMax`, `openai`, …) |
| `display_name` | TEXT NOT NULL | Nombre visible en UI |
| `context_window` | INTEGER NOT NULL | Tamanio maximo de la ventana en tokens |
| `supports_streaming` | BOOLEAN NOT NULL DEFAULT 1 | |
| `api_base_url` | TEXT | Override opcional por modelo |
| `enabled` | BOOLEAN NOT NULL DEFAULT 1 | El usuario puede deshabilitar |
| `created_at` | DATETIME NOT NULL | |

Indices:
- `(provider_id)` — agrupar por proveedor.

### 2.2 `sessions`

Representa una conversacion (thread).

| Columna | Tipo | Notas |
|---|---|---|
| `id` | TEXT PK | UUID v4 |
| `title` | TEXT NOT NULL | Editable; default = primeros 40 chars del primer mensaje |
| `model_id` | TEXT NOT NULL | FK a `model_configs.id` |
| `provider_id` | TEXT NOT NULL | Para resolver el factory (ej. `MiniMax`) |
| `system_prompt` | TEXT | Opcional, override por sesion |
| `total_input_tokens` | INTEGER NOT NULL DEFAULT 0 | Acumulado |
| `total_output_tokens` | INTEGER NOT NULL DEFAULT 0 | Acumulado |
| `last_message_at` | DATETIME | Para ordenar el panel |
| `created_at` | DATETIME NOT NULL | |
| `updated_at` | DATETIME NOT NULL | |

Indices:
- `(last_message_at DESC)` — listado del panel.
- `(model_id)` — filtrar sesiones por modelo activo.
- `(provider_id)` — filtrar por provider.

### 2.3 `messages`

Mensajes individuales de una sesion.

| Columna | Tipo | Notas |
|---|---|---|
| `id` | TEXT PK | UUID v4 |
| `session_id` | TEXT NOT NULL | FK a `sessions.id` ON DELETE CASCADE |
| `role` | TEXT NOT NULL | `system` / `user` / `assistant` |
| `content` | TEXT NOT NULL | Texto plano (MVP). Markdown embebido. |
| `input_tokens` | INTEGER | Devueltos por el provider en la respuesta |
| `output_tokens` | INTEGER | Idem |
| `status` | TEXT NOT NULL | `sending` / `streaming` / `complete` / `failed` |
| `error_message` | TEXT | Cuando `status = failed` |
| `created_at` | DATETIME NOT NULL | |
| `completed_at` | DATETIME | Cuando llega el ultimo chunk |

Indices:
- `(session_id, created_at)` — leer cronologicamente.
- `(status)` — buscar mensajes a reintentar.

### 2.4 `credential_handles`

Metadatos de credenciales. **NO** almacena el token real.

| Columna | Tipo | Notas |
|---|---|---|
| `id` | TEXT PK | Ej. `MiniMax-default` |
| `provider_id` | TEXT NOT NULL | |
| `label` | TEXT NOT NULL | "Personal", "Trabajo" |
| `secure_key` | TEXT NOT NULL | Clave usada en `flutter_secure_storage` |
| `created_at` | DATETIME NOT NULL | |
| `last_used_at` | DATETIME | |

El token real vive en `flutter_secure_storage` bajo `secure_key`. La tabla es solo metadata.

---

### 2.5 Clases Drift para las tablas

```dart
// lib/db/tables/model_configs_table.dart
import 'package:drift/drift.dart';

@DataClassName('ModelConfigRow')
class ModelConfigs extends Table {
  TextColumn get id => text()();
  TextColumn get providerId => text()();
  TextColumn get displayName => text()();
  IntColumn get contextWindow => integer()();
  BoolColumn get supportsStreaming => boolean().withDefault(const Constant(true))();
  TextColumn get apiBaseUrl => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

// lib/db/tables/sessions_table.dart
@DataClassName('SessionRow')
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get modelId => text().references(ModelConfigs, #id)();
  TextColumn get providerId => text()();
  TextColumn get systemPrompt => text().nullable()();
  IntColumn get totalInputTokens => integer().withDefault(const Constant(0))();
  IntColumn get totalOutputTokens => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastMessageAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

// lib/db/tables/messages_table.dart
@DataClassName('MessageRow')
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text()();
  TextColumn get content => text()();
  IntColumn get inputTokens => integer().nullable()();
  IntColumn get outputTokens => integer().nullable()();
  TextColumn get status => text()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

// lib/db/tables/credential_handles_table.dart
@DataClassName('CredentialHandleRow')
class CredentialHandles extends Table {
  TextColumn get id => text()();
  TextColumn get providerId => text()();
  TextColumn get label => text()();
  TextColumn get secureKey => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}
```

Convenciones:
- `DataClassName` evita colision con la entidad de dominio (row vs entity).
- `withDefault` para columnas con valor por defecto.
- `nullable()` para columnas opcionales.
- `references(...)` con `onDelete: KeyAction.cascade` en `messages.sessionId` para borrar en cascada.

---

## 3. Entidades del dominio (freezed)

Las entidades son clases puras, sin dependencias de Drift ni de Flutter.

```dart
// lib/session/domain/entities/chat_session.dart
@freezed
class ChatSession with _$ChatSession {
  const factory ChatSession({
    required String id,
    required String title,
    required String modelId,
    required String providerId,
    String? systemPrompt,
    @Default(0) int totalInputTokens,
    @Default(0) int totalOutputTokens,
    DateTime? lastMessageAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ChatSession;
}
```

```dart
// lib/message/domain/entities/message.dart
enum MessageRole { system, user, assistant }
enum MessageStatus { sending, streaming, complete, failed }

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String sessionId,
    required MessageRole role,
    required String content,
    int? inputTokens,
    int? outputTokens,
    @Default(MessageStatus.complete) MessageStatus status,
    String? errorMessage,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _Message;
}
```

```dart
// lib/message/domain/entities/token_usage.dart
@freezed
class TokenUsage with _$TokenUsage {
  const factory TokenUsage({
    @Default(0) int inputTokens,
    @Default(0) int outputTokens,
  }) = _TokenUsage;

  const TokenUsage._();

  int get total => inputTokens + outputTokens;
}
```

Entidades adicionales del dominio (completas, no analogas):

```dart
// lib/session/domain/entities/model_definition.dart
@freezed
class ModelDefinition with _$ModelDefinition {
  const factory ModelDefinition({
    required String id,                  // ej. 'MiniMax-M'
    required String providerId,         // ej. 'MiniMax'
    required String displayName,       // ej. 'MiniMax M'
    required int contextWindow,
    @Default(true) bool supportsStreaming,
    String? apiBaseUrl,                 // override opcional
    @Default(true) bool enabled,
  }) = _ModelDefinition;
}

// lib/db/credential_handle.dart
@freezed
class CredentialHandle with _$CredentialHandle {
  const factory CredentialHandle({
    required String id,                  // ej. 'MiniMax-default'
    required String providerId,
    required String label,                // 'Personal', 'Trabajo'
    required String secureKey,           // clave en flutter_secure_storage
    DateTime? lastUsedAt,
    required DateTime createdAt,
  }) = _CredentialHandle;
}
```

> **Nota:** no existe una entidad `ApiCredential` en el dominio. El API key es un dato **transient** que vive solo en memoria del provider activo y en `flutter_secure_storage`. Persistirlo como entidad romperia la regla "nunca en SQLite". `CredentialHandle` apunta a la entrada en secure storage; el valor del token se lee bajo demanda y no se modela.

---

## 4. Mappers Drift Row ↔ Domain

Regla dura: **los DTOs de Drift no salen de la capa `data/` de cada módulo.** Todo cruce a `domain` o `presentation` se hace via una entidad.

```dart
// lib/db/mappers/session_mapper.dart
extension SessionMapper on Session {
  ChatSession toDomain() => ChatSession(
        id: id,
        title: title,
        modelId: modelId,
        providerId: providerId,
        systemPrompt: systemPrompt,
        totalInputTokens: totalInputTokens,
        totalOutputTokens: totalOutputTokens,
        lastMessageAt: lastMessageAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
```

---

## 5. Repositorios (interfaces en domain)

```dart
// lib/session/domain/repositories/sessions_repository.dart
abstract class SessionsRepository {
  Stream<List<ChatSession>> watchAll();
  Stream<List<ChatSession>> watchByModel(String modelId);
  Stream<List<ChatSession>> watchByProvider(String providerId);
  Future<List<ChatSession>> listAll();
  Future<ChatSession?> getById(String id);
  Future<void> create(ChatSession session);
  Future<void> rename(String id, String newTitle);
  Future<void> delete(String id);
  Future<void> touch(String id, DateTime when);
  Future<void> accumulateTokens(String id, {int input = 0, int output = 0});
}
```

```dart
// lib/message/domain/repositories/messages_repository.dart
abstract class MessagesRepository {
  Stream<List<Message>> watchBySession(String sessionId);
  Future<List<Message>> listBySession(String sessionId);
  Future<void> append(Message message);
  Future<void> updateContent(String id, String content);
  Future<void> updateStatus(String id, MessageStatus status, {String? error});
  Future<void> updateTokenUsage(
    String id, {
    int? inputTokens,
    int? outputTokens,
  });
  /// Patch parcial de campos opcionales. Usado por el caso de uso
  /// SendMessage para setear `completedAt` al final del stream
  /// o al abortar.
  Future<void> patch(String id, {DateTime? completedAt});
  Future<void> deleteById(String id);
}
```

```dart
// lib/session/domain/repositories/model_catalog_repository.dart
abstract class ModelCatalogRepository {
  Future<List<ModelDefinition>> listEnabled();
  Future<ModelDefinition?> getById(String id);
  Future<void> setEnabled(String id, bool enabled);
}
```

```dart
// lib/db/credential_repository.dart
abstract class CredentialRepository {
  Future<void> save(CredentialHandle handle, String apiKey);
  Future<String?> read(String handleId);
  Future<void> delete(String handleId);
  Future<List<CredentialHandle>> list();
  Future<CredentialHandle?> activeFor(String providerId);
  Future<void> setActive(String handleId);
}
```

---

## 6. Manejo de tokens y contadores

- Los contadores `total_input_tokens` y `total_output_tokens` en `sessions` se actualizan en cada `updateTokenUsage` ejecutado tras la respuesta del provider.
- El calculo de tokens del input (cliente) se delega a `provider.calculateTokens()` del `ILLMProvider` activo (ver [03_LLM_Module_And_MiniMax.md](03_LLM_Module_And_MiniMax.md)).
- El valor autoritativo es el que devuelve el provider en `LlmUsage`; el del cliente es una estimacion para la UI en tiempo real.

### 6.1 Quien llama a `accumulateTokens`

El caso de uso `SendMessage` (en `session/domain/usecases/send_message.dart`) es el unico caller. Despues de recibir el `LlmUsage` autoritativo en el ultimo chunk del stream, llama a `sessionsRepository.accumulateTokens(sessionId, input: ..., output: ...)`. `MessagesRepository.updateTokenUsage` actualiza el mensaje individual; `SessionsRepository.accumulateTokens` actualiza el agregado de la sesion. Los dos son atomicos en una sola transaccion si el DAO lo soporta, sino secuencial (aceptable en MVP).

---

## 7. Seguridad de credenciales

- El token **nunca** aparece en logs ni en archivos del proyecto.
- `flutter_secure_storage` cifra con Keychain (iOS) y Keystore (Android).
- El token se carga **en memoria solo cuando se va a usar** y se descarta tras la request si el usuario decide "no recordar".
- `CredentialRepository` (implementado en `db/`) es el unico punto de acceso.

---

## 8. Migraciones

Convenciones:

- Cualquier cambio de esquema bump `schemaVersion` y anade un `case` en `onUpgrade`.
- Migraciones **aditivas** en MVP (no destructivas). Drops de columna solo en majors.
- Cada migracion se cubre con un test en `test/db/migration_test.dart`.

---

## 9. Seed inicial

`AppDatabase._seedModelConfigs()` inserta los modelos MiniMax en el primer arranque.

| id | provider_id | display_name | context_window |
|---|---|---|---|
| `MiniMax-M` | `MiniMax` | MiniMax M | 200000 |
| `MiniMax-XL` | `MiniMax` | MiniMax XL | 200000 |

---

## 10. Logica algoritmica de inyeccion de contexto

El módulo `context/` implementa el Strategy Pattern para la gestion de la ventana de contexto. Su objetivo es que cada mensaje enviado al provider respete el `contextWindow` del modelo activo.

### 10.1 Interfaz `ContextStrategy`

```dart
// lib/context/context_strategy.dart
/// Interfaz Strategy para estrategias de manejo de contexto.
///
/// Define el contrato: dada una lista de mensajes y un budget de tokens,
/// decide quais mensajes se incluyen en la proxima peticion.
///
/// El calculo de tokens se delega al [ILLMProvider] activo (Strategy Pattern)
/// — la estrategia de contexto NO conoce la logica de tokenizacion de un
/// modelo especifico.
abstract class ContextStrategy {
  /// Devuelve la sublista de [messages] que cabe dentro de [budget] tokens.
  ///
  /// [budget] es el contextWindow del modelo menos [maxOutputTokens]
  /// (espacio reservado para la respuesta del assistant).
  /// [calculateTokens] viene del ILLMProvider activo y es especifico
  /// del modelo.
  List<ChatMessage> apply({
    required List<ChatMessage> messages,
    required int budget,
    required int Function(String text) calculateTokens,
  });
}
```

### 10.2 SlidingWindowStrategy (default en MVP)

Mantiene los mensajes mas recientes, descartando los mas antiguos hasta que el total quepa en el budget.

**Pseudocodigo detallado:**

```
FUNCION SlidingWindowStrategy.apply(messages, budget, calculateTokens):

  // 1. Reservar margen de seguridad (10% del budget)
  safetyMargin = floor(budget * 0.10)
  effectiveBudget = budget - safetyMargin

  // 2. Inicializar acumulador
  kept = []           // lista de mensajes a mantener (en orden original)
  usedTokens = 0

  // 3. Iterar desde el mensaje mas reciente hacia el mas antiguo
  FOR message IN messages.reversed:
    // +4 = overhead aproximado por mensaje (formato role/content, OpenAI-compatible)
    messageTokens = calculateTokens(message.content) + 4

    // 4. Si agregar este mensaje excede el budget, parar (los mas antiguos tampoco cabran)
    IF usedTokens + messageTokens > effectiveBudget:
      BREAK

    // 5. Agregar al inicio de kept (para mantener orden cronologico)
    kept.insert(0, message)
    usedTokens = usedTokens + messageTokens

  // 6. Devolver kept (puede ser vacia si solo el mensaje mas reciente ya no cabe)
  RETURN kept
```

**Propiedades:**
- Siempre intenta mantener la mayor cantidad de contexto reciente posible.
- Si el budget es muy pequeno (ej. < 100 tokens), puede devolver lista vacia.
- El system prompt (si existe) se considera aparte, fuera de esta logica (ver seccion 10.4).

### 10.3 Manejo del budget

El budget disponible se calcula como:

```
budget = contextWindow - maxOutputTokens
```

Donde:
- `contextWindow`: limite absoluto del modelo (ej. 200,000 para MiniMax).
- `maxOutputTokens`: espacio reservado para la respuesta del assistant (default: 1024, configurable por el usuario en Settings).

El budget **no incluye** el mensaje del usuario que se esta por enviar: ese se anade en el caso de uso `SendMessage` al construir el `GenerateRequest`.

### 10.4 System prompt

El system prompt (si existe, establecido por sesion o por defecto global) se inyecta **antes** de aplicar la estrategia de contexto. Logica:

```
1. Si existe systemPrompt:
     systemTokens = calculateTokens(systemPrompt) + 4
     budgetParaHistorial = budget - systemTokens
   Sino:
     budgetParaHistorial = budget
2. Aplicar SlidingWindowStrategy sobre historial con budgetParaHistorial.
3. Construir GenerateRequest.messages como:
   [systemPrompt (si existe)] + [historial_truncado] + [mensaje_usuario_actual]
```

### 10.5 Implementacion del ContextWindowManager

```dart
// lib/context/context_window_manager.dart
class ContextWindowManager {
  final ILLMProvider _provider; // Strategy inyectada
  final int _contextWindow;
  final int _maxOutputTokens;
  final ContextStrategy _strategy;

  ContextWindowManager({
    required ILLMProvider provider,
    required int contextWindow,
    int maxOutputTokens = 1024,
    ContextStrategy? strategy,
  })  : _provider = provider,
        _contextWindow = contextWindow,
        _maxOutputTokens = maxOutputTokens,
        _strategy = strategy ?? SlidingWindowStrategy();

  /// Budget total disponible: contextWindow - maxOutputTokens.
  int get _totalBudget => _contextWindow - _maxOutputTokens;

  /// Devuelve la sublista de [history] que cabe en el budget disponible,
  /// descontando primero el system prompt (si existe).
  ///
  /// El mensaje del usuario actual se anade aparte en SendMessage.
  /// [systemPrompt] puede ser null o vacio.
  List<ChatMessage> trimHistory(
    List<ChatMessage> history, {
    String? systemPrompt,
  }) {
    // 1. Calcular budget para historial = total - tokens del system prompt.
    final systemTokens = (systemPrompt == null || systemPrompt.isEmpty)
        ? 0
        : _provider.calculateTokens(systemPrompt) + 4;
    final historyBudget = _totalBudget - systemTokens;

    // 2. Si el system prompt solo ya excede el budget, devolver vacio
    //    y dejar que el caso de uso decida (probable warning al usuario).
    if (historyBudget <= 0) return const [];

    // 3. Delegar a la strategy.
    return _strategy.apply(
      messages: history,
      budget: historyBudget,
      calculateTokens: _provider.calculateTokens,
    );
  }

  /// Estima los tokens de un proximo envio (historial + draft + systemPrompt + maxOutput).
  /// Usado por TokenMeter para mostrar feedback en tiempo real.
  int estimateNextSendTokens({
    required List<ChatMessage> history,
    required String draft,
    String? systemPrompt,
  }) {
    final historyTokens = history.fold<int>(
      0,
      (sum, m) => sum + _provider.calculateTokens(m.content) + 4,
    );
    final draftTokens = _provider.calculateTokens(draft) + 4;
    final systemTokens = (systemPrompt == null || systemPrompt.isEmpty)
        ? 0
        : _provider.calculateTokens(systemPrompt) + 4;
    return historyTokens + draftTokens + systemTokens + _maxOutputTokens;
  }

  /// Estima que porcentaje del contextWindow se usaria con [history] + [draft].
  double usageRatio({
    required List<ChatMessage> history,
    required String draft,
    String? systemPrompt,
  }) {
    final estimated = estimateNextSendTokens(
      history: history, draft: draft, systemPrompt: systemPrompt,
    );
    return estimated / _contextWindow;
  }
}
```

### 10.6 Resumen de invariantes

1. Los DTOs de Drift **nunca** cruzan a `domain` ni a `presentation`.
2. Toda operacion de DB pasa por un **DAO**; los repositorios orquestan 1+ DAO si es necesario.
3. El token **nunca** se almacena en SQLite.
4. Las migraciones son **aditivas** y testeadas.
5. Las queries complejas (joins, agregaciones) se evaluan en SQL, no en memoria.
6. `ContextStrategy` es intercambiable; en MVP solo existe `SlidingWindowStrategy`.
7. El budget se calcula en el `ContextWindowManager`, no en el caso de uso.

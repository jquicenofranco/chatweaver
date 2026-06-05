# Plan de Implementación — ChatWeaver Flutter

**Versión:** 1.1 (QA-corrected)
**Fecha:** 2026-06-04
**Proyecto:** ChatWeaver — Cliente móvil local-first para múltiples proveedores LLM (MVP: MiniMax)
**Ubicación del proyecto:** `C:\Proyectos\chatweaver\movil\chatweaver\`
**Specs de referencia:** `C:\Proyectos\chatweaver\movil\spec\`

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.1 (QA-corrected) | 2026-06-04 | QA review corrections applied: DAO types fixed (SessionRow, MessageRow, etc.), duplicate get_session_messages removed, singular DAO naming enforced, accumulateTokens fixed to use update()..where()..write(), sendMessageProvider corrected to Provider.family, Phase 2 migrations added, Phase 5 MiniMaxApiException added, Phase 12 SnackBar task added, Section 0.3 folder diagram updated, mapper clarified (toDomain only), analysis_options redundant lints removed |

---

## Tabla de Contenidos

1. [Resumen Ejecutivo](#0-resumen-ejecutivo)
2. [Principios Arquitectónicos](#1-principios-arquitectónicos)
3. [Fase de Fundación (`db/`, `context/`, `llm/`)](#2-fase-de-fundación)
4. [Fase de Composición (`di/` + casos de uso)](#3-fase-de-composición)
5. [Fase de UI (pantallas, navegación, controladores)](#4-fase-de-ui)
6. [Fase Transversal (calidad, pulido, release)](#5-fase-transversal)
7. [Registro de Riesgos](#6-registro-de-riesgos)
8. [Definición de Done por fase](#7-definición-de-done)
9. [Fuera de alcance para el MVP](#8-fuera-de-alcance)

---

## 0. Resumen Ejecutivo

### 0.1 ¿Qué es ChatWeaver?

ChatWeaver es un cliente móvil **local-first** para interactuar con múltiples proveedores de LLM. El usuario elige un modelo, pega su API key, y conversa. Toda la información (sesiones, mensajes, configuración) persiste en el dispositivo. No hay registro, no hay backend propio, no hay login.

**MVP:** solo MiniMax. La arquitectura está diseñada para agregar OpenAI, Ollama, Anthropic, etc. sin reescribir código existente.

### 0.2 Pilares arquitectónicos

| Pilar | Descripción |
|---|---|
| **Strategy Pattern** | `ILLMProvider` como interfaz intercambiable. Cualquier provider nuevo solo requiere crear un directorio en `llm/providers/`. |
| **Factory Pattern** | `LLMFactory` con registro dinámico. La UI y los casos de uso solo conocen la abstracción, nunca la implementación concreta. |
| **Adapter Pattern** | DTOs nativos de cada API se traducen a entidades de dominio (`ChatMessage`, `GenerateResponseChunk`). Los DTOs nunca cruzan la capa del provider. |
| **Local-first** | SQLite vía Drift para datos relacionales; `flutter_secure_storage` para API keys. El token nunca toca SQLite ni logs. |
| **State management** | Riverpod como contenedor de estado e inyección de dependencias. Compile-time safety, testable, sin `BuildContext`. |

### 0.3 Diagrama de estructura modular

```
lib/
├── main.dart                     # bootstrap + runApp
├── app.dart                      # MaterialApp.router + theming
├── bootstrap.dart                # Inicializaciones (DB, errores)
│
├── llm/                          # ── Aislamiento total del provider ──
│   ├── illm_provider.dart       # Interfaz Strategy (ILLMProvider)
│   ├── llm_factory.dart         # Factory con registro dinámico
│   ├── llm_exception.dart        # Jerarquía de excepciones + parseNetworkError
│   ├── chat_message.dart         # Entidad dominio: ChatRole, ChatMessage
│   ├── generate_request.dart     # GenerateRequest (value object)
│   ├── generate_response.dart    # GenerateResponseChunk, LlmUsage
│   └── providers/
│       └── minimax/
│           ├── minimax_provider.dart   # ILLMProvider → MiniMax
│           ├── minimax_api_client.dart # Cliente HTTP con SSE parsing
│           ├── minimax_adapter.dart     # DTO → dominio (Adapter Pattern)
│           └── dto/
│               ├── minimax_request_dto.dart
│               └── minimax_response_dto.dart
│
├── session/                      # ── Orquestación de sesiones ──
│   ├── domain/
│   │   ├── entities/chat_session.dart   # Entidad ChatSession (freezed)
│   │   ├── repositories/sessions_repository.dart
│   │   └── usecases/
│   │       ├── providers.dart           # createSessionProvider, sendMessageProvider
│   │       ├── create_session.dart
│   │       ├── list_sessions.dart
│   │       ├── rename_session.dart
│   │       ├── delete_session.dart
│   │       └── send_message.dart       # Usa ILLMProvider (Strategy)
│   ├── data/
│   │   ├── sessions_repository_impl.dart
│   │   └── mappers/session_mapper.dart
│   └── presentation/
│       └── screens/sessions_panel_screen.dart
│
├── message/                      # ── Mensajes de chat ──
│   ├── domain/
│   │   ├── entities/message.dart       # Message, MessageRole, MessageStatus
│   │   ├── entities/token_usage.dart   # TokenUsage
│   │   ├── repositories/messages_repository.dart
│   │   └── usecases/
│   │       ├── providers.dart           # appendMessageProvider
│   │       └── append_message.dart
│   ├── data/
│   │   ├── messages_repository_impl.dart
│   │   └── mappers/message_mapper.dart
│   └── presentation/
│       └── widgets/
│           ├── message_bubble.dart
│           └── token_meter.dart
│
├── db/                           # ── Infraestructura ──
│   ├── app_database.dart         # Drift: connection, seed, migrations
│   ├── tables/
│   │   ├── model_configs_table.dart
│   │   ├── sessions_table.dart
│   │   ├── messages_table.dart
│   │   └── credential_handles_table.dart
│   ├── daos/                     # Uno por tabla
│   ├── mappers/                  # Row → Domain
│   └── secure_credential_store.dart
│
├── context/                      # ── Gestión de contexto ──
│   ├── context_strategy.dart     # Interfaz ContextStrategy
│   └── context_window_manager.dart # Recibe ILLMProvider como estrategia
│
├── ui/                           # ── Presentación ──
│   ├── home/
│   │   ├── model_selector_screen.dart
│   │   ├── token_input_screen.dart
│   │   └── connection_test_controller.dart
│   ├── chat/
│   │   ├── chat_screen.dart
│   │   ├── chat_controller.dart
│   │   └── prompt_input.dart
│   ├── sessions/
│   │   └── sessions_panel_screen.dart
│   ├── settings/
│   │   └── settings_screen.dart
│   ├── splash/
│   │   └── splash_screen.dart
│   └── shared/
│       ├── primary_button.dart
│       ├── loading_overlay.dart
│       ├── error_view.dart
│       ├── confirm_dialog.dart
│       └── empty_state_view.dart
│
├── di/                           # ── Inyección de dependencias ──
│   └── global_providers.dart     # TODOS los Riverpod providers globales
│
└── l10n/                         # ── Localización ──
    ├── app_es.arb
    └── app_en.arb
```

### 0.4 Dependencias clave del pubspec.yaml

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  go_router: ^14.8.1
  drift: ^2.23.1
  drift_flutter: ^0.2.4
  sqlite3_flutter_libs: ^0.5.28
  path_provider: ^2.1.5
  flutter_secure_storage: ^9.2.4
  dio: ^5.8.0+1
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  equatable: ^2.0.7
  intl: ^0.20.2
  flutter_markdown: ^0.7.7
  url_launcher: ^6.3.1
  uuid: ^4.5.1

dev_dependencies:
  build_runner: ^2.4.15
  drift_dev: ^2.23.1
  freezed: ^2.5.8
  json_serializable: ^6.9.4
  mocktail: ^1.0.4
```

> **Nota:** Las versiones exactas deben verificarse contra `pub.dev` en el momento de la implementación. Usar `flutter pub add` con `--dry-run` para validar antes de confirmar.

---

## 1. Principios Arquitectónicos

### 1.1 Reglas de dependencia entre módulos (estrictas)

| Módulo | Puede depender de |
|---|---|
| `llm/` | `di/` |
| `session/` | `llm/`, `db/`, `message/` |
| `message/` | `db/` |
| `db/` | ninguno (infraestructura) |
| `context/` | `llm/` |
| `ui/` | `session/`, `message/`, `llm/` |
| `di/` | todos |
| `l10n/` | ninguno |

**Reglas duras:**
- `domain/` de cualquier módulo **NO** importa Flutter, Drift, Dio, ni implementaciones concretas. Solo `dart:*` y paquetes neutros (`equatable`, `freezed_annotation`).
- Ninguna clase fuera de `llm/providers/<provider_id>/` importa `MiniMaxProvider` ni ninguna otra implementación concreta de `ILLMProvider`.
- Los DTOs de Drift **nunca** cruzan a `domain` ni `presentation`. Todo cruce se hace vía mapper.
- No existe `core/` transversal.
- `session/` y `message/` son **pares**: `session` depende de `message` para orquestar, pero `message` no sabe de `session`.

### 1.2 Convenciones de nomenclatura

| Elemento | Convención | Ejemplo |
|---|---|---|
| Archivos | `snake_case.dart` | `chat_message.dart` |
| Clases e interfaces | `PascalCase` | `ILLMProvider`, `MiniMaxProvider` |
| Interfaces de provider | prefijo `I`, sufijo `Provider` | `ILLMProvider` |
| Implementaciones concretas | sufijo `Provider` | `MiniMaxProvider` |
| Providers Riverpod | sufijo `Provider` | `sessionsRepositoryProvider` |
| Notifiers/Controllers | sufijo `Notifier` o `Controller` | `ChatController` |
| Módulos | singular | `llm`, `session` |

### 1.3 Convenciones de código

- `dart format .` antes de cada commit.
- `flutter analyze` debe pasar sin warnings ni errores.
- Líneas máximo 100 caracteres.
- Comentarios solo para explicar **por qué**, no qué.
- `prefer_single_quotes: true` (activar en `analysis_options.yaml`).
- No `print` en código de producción; usar logging estructurado.

### 1.4 Code generation

```bash
# Generar todo (freezed, json_serializable, Drift)
dart run build_runner build --delete-conflicting-outputs

# Regenerar un paquete específico
dart run build_runner build --delete-conflicting-outputs -- --packages=chatweaver
```

**Disciplina:**
- Siempre ejecutar `build_runner` después de modificar archivos `.freezed.dart`, `.g.dart`, o `.drift.dart`.
- Los archivos generados **NO** se versionan en git más allá del `.freezed.dart` que acompaña cada fuente (son parte del source para que `flutter test` funcione sin regenerar).
- Ejecutar `build_runner` en CI antes de `flutter test`.

---

## 2. Fase de Fundación

### Fase 1 — Bootstrap del proyecto y estructura base

**Objetivo:** configurar el proyecto Flutter con todas las dependencias, estructura de carpetas vacía, y el esqueleto de `main.dart`, `app.dart`, `bootstrap.dart`.

**Archivos a crear:**

```
lib/
├── main.dart                     # Entry point: bootstrap() + runApp(child: ProviderScope...)
├── app.dart                      # MaterialApp.router(routerConfig: _router) + theming
└── bootstrap.dart                # Inicializaciones: DB, sanitización de errores, logs

analysis_options.yaml             # Activar prefer_single_quotes, avoid_print, etc.
```

**Clave de `bootstrap.dart`:**

```dart
// lib/bootstrap.dart
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializar base de datos (Drift)
  // Se deja preparado; la conexión real se crea en Phase 2.
  // final db = AppDatabase();

  // 2. Logging de errores no capturados (solo en debug)
  // En prod, reportar a un servicio de crash (ej. Sentry).

  runApp(
    const ProviderScope(
      child: ChatWeaverApp(),
    ),
  );
}
```

**Clave de `app.dart`:**

```dart
// lib/app.dart
class ChatWeaverApp extends ConsumerWidget {
  const ChatWeaverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'ChatWeaver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        useMaterial3: true,
        // Radio de bordes: 16px tarjetas, 24px inputs
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      // routerConfig se implementa en Phase 10
      // routerConfig: _router,
    );
  }
}
```

**Tareas específicas:**

- [ ] Actualizar `pubspec.yaml` con todas las dependencias de producción y desarrollo listadas en §0.4.
- [ ] Ejecutar `flutter pub get` y verificar que no hay conflictos de versión.
- [ ] Crear la estructura de carpetas vacías según el diagrama de §0.3.
- [ ] Configurar `analysis_options.yaml`: `prefer_single_quotes: true`, `avoid_print: true` (los demas lints ya vienen por defecto en flutter.yaml).
- [ ] Crear `lib/main.dart`, `lib/app.dart`, `lib/bootstrap.dart` con el esqueleto выше.
- [ ] Crear archivo `.gitkeep` en cada carpeta vacía para preservar la estructura.
- [ ] Primer `flutter analyze` — debe pasar limpio (salvo warnings de imports no usados, que se resolverán en fases siguientes).

**Criterios de aceptación:**
- `flutter pub get` exitosa, sin conflicts.
- `flutter analyze` pasa con 0 errores, 0 warnings.
- La estructura de carpetas coincide con el diagrama de §0.3.

---

### Fase 2 — Capa de base de datos (`db/`)

**Objetivo:** implementar el módulo `db/` completo: tablas Drift, `AppDatabase`, DAOs, `SecureCredentialStore`, mappers, y migraciones.

**Depende de:** Fase 1 (estructura de carpetas disponible).

#### 2.1 Tablas Drift

```dart
// lib/db/tables/model_configs_table.dart
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

#### 2.2 AppDatabase

```dart
// lib/db/app_database.dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part '../../plans/app_database.g.dart';

@DriftDatabase(tables: [ModelConfigs, Sessions, Messages, CredentialHandles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedModelConfigs();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Phase 2: sin migraciones (schemaVersion = 1)
      },
    );
  }

  Future<void> _seedModelConfigs() async {
    // NOTA: ejecutar build_runner ANTES de ajustar esta funcion.
    // Drift genera insert() con parametros posicionales en orden de declaracion de columna.
    // Usar el formato que build_runner genere en SessionsCompanion.insert().
    // Ejemplo generico (ajustar segun el codigo generado):
    await into(modelConfigs).insert(ModelConfigsCompanion.insert(
      'MiniMax-M',   // id
      'MiniMax',     // providerId
      'MiniMax M',   // displayName
      200000,        // contextWindow
      const Constant(true),  // supportsStreaming (default)
      const Constant(true),  // enabled (default)
      null,          // apiBaseUrl (nullable)
      DateTime.now(),// createdAt
    ));
    await into(modelConfigs).insert(ModelConfigsCompanion.insert(
      'MiniMax-XL',  // id
      'MiniMax',     // providerId
      'MiniMax XL',  // displayName
      200000,        // contextWindow
      const Constant(true),
      const Constant(true),
      null,
      DateTime.now(),
    ));
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'chatweaver');
}
```

#### 2.3 DAOs

Un DAO por tabla. Los DAOs viven en `lib/db/daos/` y se injectan como miembros de `AppDatabase`. Nombrado en singular (`SessionDao`, `MessageDao`, `ModelConfigDao`, `CredentialHandleDao`) para consistencia con el patrón de las demas capas.

**Ejemplo — `SessionDao`:**

```dart
// lib/db/daos/session_dao.dart
class SessionDao {
  final AppDatabase _db;
  SessionDao(this._db);

  Stream<List<SessionRow>> watchAll() {
    return (_db.select(_db.sessions)
          ..orderBy([(t) => OrderingTerm.desc(t.lastMessageAt)]))
        .watch();
  }

  Stream<List<SessionRow>> watchByModel(String modelId) {
    return (_db.select(_db.sessions)
          ..where((t) => t.modelId.equals(modelId))
          ..orderBy([(t) => OrderingTerm.desc(t.lastMessageAt)]))
        .watch();
  }

  Stream<List<SessionRow>> watchByProvider(String providerId) {
    return (_db.select(_db.sessions)
          ..where((t) => t.providerId.equals(providerId))
          ..orderBy([(t) => OrderingTerm.desc(t.lastMessageAt)]))
        .watch();
  }

  Future<SessionRow?> getById(String id) {
    return (_db.select(_db.sessions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> insert(SessionRow session) => _db.into(_db.sessions).insert(session);

  Future<void> update(SessionRow session) => _db.update(_db.sessions).replace(session);

  Future<void> delete(String id) {
    return (_db.delete(_db.sessions)..where((t) => t.id.equals(id))).go();
  }

  Future<void> touch(String id, DateTime when) {
    return (_db.update(_db.sessions)..where((t) => t.id.equals(id)))
        .write(SessionsCompanion(
          lastMessageAt: Value(when),
          updatedAt: Value(when),
        ));
  }

  Future<void> accumulateTokens(
    String id, {
    int input = 0,
    int output = 0,
  }) async {
    final session = await getById(id);
    if (session == null) return;
    await (_db.update(_db.sessions)..where((t) => t.id.equals(id))).write(
      SessionsCompanion(
        totalInputTokens: Value(session.totalInputTokens + input),
        totalOutputTokens: Value(session.totalOutputTokens + output),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
```

**Analogous for `MessageDao`, `ModelConfigDao`, `CredentialHandleDao`.**

#### 2.4 SecureCredentialStore

```dart
// lib/db/secure_credential_store.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureCredentialStore {
  final FlutterSecureStorage _storage;

  const SecureCredentialStore(this._storage);

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key: key);
  }
}
```

#### 2.5 CredentialRepository

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

// lib/db/credential_repository_impl.dart
class CredentialRepositoryImpl implements CredentialRepository {
  final SecureCredentialStore _store;
  final CredentialHandleDao _dao;

  CredentialRepositoryImpl(this._store, this._dao);

  @override
  Future<void> save(CredentialHandle handle, String apiKey) async {
    await _store.write(handle.secureKey, apiKey);
    await _dao.insert(handle);
  }

  @override
  Future<String?> read(String handleId) async {
    final handle = await _dao.getById(handleId);
    if (handle == null) return null;
    return _store.read(handle.secureKey);
  }

  @override
  Future<void> delete(String handleId) async {
    final handle = await _dao.getById(handleId);
    if (handle != null) {
      await _store.delete(handle.secureKey);
      await _dao.delete(handleId);
    }
  }

  @override
  Future<List<CredentialHandle>> list() => _dao.list();

  @override
  Future<CredentialHandle?> activeFor(String providerId) =>
      _dao.activeFor(providerId);

  @override
  Future<void> setActive(String handleId) async {
    final handle = await _dao.getById(handleId);
    if (handle == null) return;
    await _dao.update(handle.copyWith(lastUsedAt: DateTime.now()));
  }
}
```

**Tareas específicas:**

- [ ] Crear `lib/db/tables/` con las 4 tablas Drift (model_configs, sessions, messages, credential_handles).
- [ ] Ejecutar `build_runner` para generar `app_database.g.dart`.
- [ ] Crear `lib/db/daos/session_dao.dart` (singular, tipo `SessionRow`).
- [ ] Crear `lib/db/daos/message_dao.dart` (singular, tipo `MessageRow`).
- [ ] Crear `lib/db/daos/model_config_dao.dart` (singular, tipo `ModelConfigRow`).
- [ ] Crear `lib/db/daos/credential_handle_dao.dart` (singular, tipo `CredentialHandleRow`).
- [ ] Añadir DAOs como miembros de `AppDatabase`.
- [ ] Crear `lib/db/secure_credential_store.dart`.
- [ ] Crear `lib/db/credential_repository.dart` + `credential_repository_impl.dart`.
- [ ] Crear `lib/db/mappers/` con los mappers `SessionMapper`, `MessageMapper` (solo `toDomain()`, sin `toInsertable()`).
- [ ] Documentar convencion de migraciones: archivo `migration_N_to_M.dart` por cada upgrade de schema.
- [ ] Añadir placeholder `onUpgrade` en `AppDatabase` que haga `throw UnsupportedError` para saltos de version no esperados (fail-fast).
- [ ] Crear test: `test/db/migration_test.dart` (placeholder - se poblara cuando el esquema evolucione).
- [ ] Crear test: `test/db/credential_store_test.dart` (usa fake store en tests, no real Keychain).

**Criterios de aceptación:**
- `flutter analyze` limpio.
- `flutter test test/db/` pasa (usar `MockFlutterSecureStorage` con `mocktail`).
- Los 2 modelos MiniMax aparecen en la DB tras el primer arranque.
- `CredentialRepository` nunca expone el API key en texto plano fuera de la memoria.

---

### Fase 3 — Entidades de dominio y repositorios (`session/`, `message/`)

**Objetivo:** implementar las entidades freezed en `domain/` de `session/` y `message/`, las interfaces de repositorio, y las implementaciones en `data/`.

**Depende de:** Fase 2 (`db/` disponible como implementación de los repositorios).

#### 3.1 Entidades

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

// lib/session/domain/entities/model_definition.dart
@freezed
class ModelDefinition with _$ModelDefinition {
  const factory ModelDefinition({
    required String id,
    required String providerId,
    required String displayName,
    required int contextWindow,
    @Default(true) bool supportsStreaming,
    String? apiBaseUrl,
    @Default(true) bool enabled,
  }) = _ModelDefinition;
}

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

// lib/db/credential_handle.dart
@freezed
class CredentialHandle with _$CredentialHandle {
  const factory CredentialHandle({
    required String id,
    required String providerId,
    required String label,
    required String secureKey,
    DateTime? lastUsedAt,
    required DateTime createdAt,
  }) = _CredentialHandle;
}
```

#### 3.2 Interfaces de repositorio

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

// lib/session/domain/repositories/model_catalog_repository.dart
abstract class ModelCatalogRepository {
  Future<List<ModelDefinition>> listEnabled();
  Future<ModelDefinition?> getById(String id);
  Future<void> setEnabled(String id, bool enabled);
}

// lib/message/domain/repositories/messages_repository.dart
abstract class MessagesRepository {
  Stream<List<Message>> watchBySession(String sessionId);
  Future<List<Message>> listBySession(String sessionId);
  Future<void> append(Message message);
  Future<void> updateContent(String id, String content);
  Future<void> updateStatus(String id, MessageStatus status, {String? error});
  Future<void> updateTokenUsage(String id, {int? inputTokens, int? outputTokens});
  Future<void> patch(String id, {DateTime? completedAt});
  Future<void> deleteById(String id);
}
```

#### 3.3 Implementaciones en `data/`

Cada implementación delega en los DAOs de `db/` y usa los mappers.

**Ejemplo — `SessionsRepositoryImpl`:**

```dart
// lib/session/data/sessions_repository_impl.dart
import 'package:drift/drift.dart';
import '../../../db/app_database.dart';
import '../../../db/mappers/session_mapper.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/repositories/sessions_repository.dart';

class SessionsRepositoryImpl implements SessionsRepository {
  final AppDatabase _db;

  SessionsRepositoryImpl(this._db);

  @override
  Stream<List<ChatSession>> watchAll() {
    return _db.sessionDao.watchAll().map(
          (rows) => rows.map((r) => r.toDomain()).toList(),
        );
  }

  @override
  Stream<List<ChatSession>> watchByModel(String modelId) {
    return _db.sessionDao.watchByModel(modelId).map(
          (rows) => rows.map((r) => r.toDomain()).toList(),
        );
  }

  @override
  Stream<List<ChatSession>> watchByProvider(String providerId) {
    return _db.sessionDao.watchByProvider(providerId).map(
          (rows) => rows.map((r) => r.toDomain()).toList(),
        );
  }

  @override
  Future<List<ChatSession>> listAll() async {
    final rows = await _db.sessionDao.listAll();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<ChatSession?> getById(String id) async {
    final row = await _db.sessionDao.getById(id);
    return row?.toDomain();
  }

  @override
  Future<void> create(ChatSession session) async {
    // Insert via SessionsCompanion directly (no toInsertable on mapper).
    await _db.sessionDao.insert(
      SessionsCompanion.insert(
        session.id,
        session.title,
        session.modelId,
        session.providerId,
        session.totalInputTokens,
        session.totalOutputTokens,
        session.lastMessageAt,
        session.createdAt,
        session.updatedAt,
        systemPrompt: Value(session.systemPrompt),
      ),
    );
  }

  @override
  Future<void> rename(String id, String newTitle) async {
    final existing = await _db.sessionDao.getById(id);
    if (existing == null) return;
    await _db.sessionDao.update(existing.copyWith(
      title: newTitle,
      updatedAt: DateTime.now(),
    ));
  }

  @override
  Future<void> delete(String id) => _db.sessionDao.delete(id);

  @override
  Future<void> touch(String id, DateTime when) =>
      _db.sessionDao.touch(id, when);

  @override
  Future<void> accumulateTokens(String id, {int input = 0, int output = 0}) =>
      _db.sessionDao.accumulateTokens(id, input: input, output: output);
}
```

**Tareas específicas:**

- [ ] Crear `lib/session/domain/entities/chat_session.dart` (freezed).
- [ ] Crear `lib/session/domain/entities/model_definition.dart` (freezed).
- [ ] Crear `lib/message/domain/entities/message.dart` (freezed con enums).
- [ ] Crear `lib/message/domain/entities/token_usage.dart` (freezed).
- [ ] Crear `lib/db/credential_handle.dart` (freezed).
- [ ] Ejecutar `build_runner` para generar todos los `.freezed.dart`.
- [ ] Crear interfaces de repositorio en `session/domain/repositories/` y `message/domain/repositories/`.
- [ ] Crear `lib/session/data/sessions_repository_impl.dart`.
- [ ] Crear `lib/message/data/messages_repository_impl.dart`.
- [ ] Crear tests unitarios de mappers: `test/session/data/session_mapper_test.dart`, `test/message/data/message_mapper_test.dart`.
- [ ] Crear tests de repositorio con `MockAppDatabase` y `mocktail`.

**Criterios de aceptación:**
- `flutter analyze` limpio.
- Todos los `.freezed.dart` generados y versionados.
- Mapper cubre todos los campos de la entidad.
- Repositorio implementa todos los métodos de la interfaz.
- Tests de mapper verifican la bidireccionalidad (domain → row → domain, roundtrip).

---

### Fase 4 — Núcleo del módulo `llm/`

**Objetivo:** implementar las entidades de dominio compartidas del módulo `llm/`, la interfaz `ILLMProvider`, el `LLMFactory`, y la jerarquía de excepciones `LlmException`.

**Depende de:** Fase 1 (estructura base).

#### 4.1 Entidades de dominio (`llm/`)

```dart
// lib/llm/chat_message.dart
enum ChatRole { system, user, assistant }

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required ChatRole role,
    required String content,
    int? inputTokens,
    int? outputTokens,
    String? finishReason,
    String? errorMessage,
    DateTime? timestamp,
  }) = _ChatMessage;
}

// lib/llm/generate_request.dart
@freezed
class GenerateRequest with _$GenerateRequest {
  const factory GenerateRequest({
    required List<ChatMessage> messages,
    String? systemPrompt,
    @Default(0.7) double temperature,
    @Default(1024) int maxOutputTokens,
  }) = _GenerateRequest;
}

// lib/llm/generate_response.dart
@freezed
class GenerateResponseChunk with _$GenerateResponseChunk {
  const factory GenerateResponseChunk({
    String? textDelta,
    LlmUsage? usage,
    String? finishReason,
    String? errorMessage,
  }) = _GenerateResponseChunk;
}

@freezed
class LlmUsage with _$LlmUsage {
  const factory LlmUsage({
    required int inputTokens,
    required int outputTokens,
  }) = _LlmUsage;

  const LlmUsage._();

  int get total => inputTokens + outputTokens;
}
```

#### 4.2 ILLMProvider (interfaz Strategy)

```dart
// lib/llm/illm_provider.dart
import 'dart:async';
import 'package:dio/dio.dart';
import '../../plans/generate_request.dart';
import '../../plans/generate_response.dart';
import '../../plans/chat_message.dart';

abstract class ILLMProvider {
  String get providerId;
  String get modelId;
  int get contextWindow;
  ({double inputPer1k, double outputPer1k}) get costPer1kTokens;

  Future<String?> testConnection({required String apiKey});

  Stream<GenerateResponseChunk> generateStream({
    required GenerateRequest request,
    String? apiKey,
    CancelToken? cancelToken,
  });

  LlmException parseNetworkError(Object error, {StackTrace? stackTrace});

  int calculateTokens(String text);
}
```

#### 4.3 LLMFactory

```dart
// lib/llm/llm_factory.dart
import 'package:dio/dio.dart';
import '../../plans/illm_provider.dart';

typedef LlmProviderBuilder = ILLMProvider Function({
  required String apiKey,
  required String modelId,
  required int contextWindow,
  required Dio dio,
});

class UnsupportedProviderException implements Exception {
  final String providerId;
  const UnsupportedProviderException(this.providerId);
  @override
  String toString() => 'UnsupportedProviderException($providerId)';
}

class LLMFactory {
  final Map<String, LlmProviderBuilder> _registry = {};

  void register(String providerId, LlmProviderBuilder builder) {
    _registry[providerId] = builder;
  }

  ILLMProvider build({
    required String providerId,
    required String modelId,
    required String apiKey,
    required int contextWindow,
    required Dio dio,
  }) {
    final builder = _registry[providerId];
    if (builder == null) {
      throw UnsupportedProviderException(providerId);
    }
    return builder(
      apiKey: apiKey,
      modelId: modelId,
      contextWindow: contextWindow,
      dio: dio,
    );
  }

  bool supports(String providerId) => _registry.containsKey(providerId);
  List<String> get supportedProviders => _registry.keys.toList();
}
```

#### 4.4 LlmException

```dart
// lib/llm/llm_exception.dart
sealed class LlmException implements Exception {
  final String userMessage;
  const LlmException(this.userMessage);
  @override
  String toString() => '$runtimeType: $userMessage';
}

class NetworkException extends LlmException {
  const NetworkException(super.userMessage);
}

class AuthException extends LlmException {
  const AuthException(super.userMessage);
}

class ContextWindowExceededException extends LlmException {
  const ContextWindowExceededException(super.userMessage);
}

class RateLimitException extends LlmException {
  const RateLimitException(super.userMessage);
}

class ProviderException extends LlmException {
  const ProviderException(super.userMessage);
}

class TimeoutException extends LlmException {
  const TimeoutException(super.userMessage);
}
```

**Tareas específicas:**

- [ ] Crear `lib/llm/chat_message.dart` (ChatRole enum + ChatMessage freezed).
- [ ] Crear `lib/llm/generate_request.dart` (GenerateRequest freezed).
- [ ] Crear `lib/llm/generate_response.dart` (GenerateResponseChunk + LlmUsage freezed).
- [ ] Crear `lib/llm/illm_provider.dart` (interfaz abstracta).
- [ ] Crear `lib/llm/llm_factory.dart` (Factory + UnsupportedProviderException).
- [ ] Crear `lib/llm/llm_exception.dart` (jerarquía sealed).
- [ ] Ejecutar `build_runner` para generar `.freezed.dart`.
- [ ] Crear tests: `test/llm/llm_factory_test.dart` (verifica registro, `build`, `supports`, `supportedProviders`, lanzamiento de `UnsupportedProviderException`).
- [ ] Crear tests: `test/llm/llm_exception_test.dart` (verifica que todas las subclases tienen `userMessage` y `toString()` correcto).

**Criterios de aceptación:**
- `ILLMProvider` no depende de Flutter ni de Drift.
- `LLMFactory.register` es idempotente en tests (usar `LLMFactory` limpia en cada test, no singleton).
- Todas las subclases de `LlmException` son constructores `const`.
- Los tests de factory verifican que `build()` lanza `UnsupportedProviderException` con el `providerId` correcto.

---

### Fase 5 — Proveedor MiniMax

**Objetivo:** implementar el provider MiniMax completo: DTOs, `MiniMaxApiClient`, `MiniMaxAdapter`, y `MiniMaxProvider` con auto-registro.

**Depende de:** Fase 4 (`ILLMProvider`, `LLMFactory`, entidades `llm/` disponibles).

#### 5.1 DTOs

```dart
// lib/llm/providers/minimax/dto/minimax_request_dto.dart
@freezed
class MiniMaxRequestDTO with _$MiniMaxRequestDTO {
  const factory MiniMaxRequestDTO({
    required String model,
    required List<MiniMaxMessageDTO> messages,
    @Default(true) bool stream,
    @Default(0.7) double temperature,
    @Default(1024) int max_tokens,
  }) = _MiniMaxRequestDTO;
}

@freezed
class MiniMaxMessageDTO with _$MiniMaxMessageDTO {
  const factory MiniMaxMessageDTO({
    required String role,
    required String content,
  }) = _MiniMaxMessageDTO;
}

// lib/llm/providers/minimax/dto/minimax_response_dto.dart
@freezed
class MiniMaxResponseDTO with _$MiniMaxResponseDTO {
  const factory MiniMaxResponseDTO({
    required String id,
    String? object,
    int? created,
    String? model,
    List<MiniMaxChoiceDTO>? choices,
    MiniMaxUsageDTO? usage,
    String? finishReason,
  }) = _MiniMaxResponseDTO;
}

@freezed
class MiniMaxChoiceDTO with _$MiniMaxChoiceDTO {
  const factory MiniMaxChoiceDTO({
    MiniMaxDeltaDTO? delta,
    @JsonKey('finish_reason') String? finishReason,
    int? index,
  }) = _MiniMaxChoiceDTO;
}

@freezed
class MiniMaxDeltaDTO with _$MiniMaxDeltaDTO {
  const factory MiniMaxDeltaDTO({
    String? content,
    String? role,
  }) = _MiniMaxDeltaDTO;
}

@freezed
class MiniMaxUsageDTO with _$MiniMaxUsageDTO {
  const factory MiniMaxUsageDTO({
    @JsonKey('prompt_tokens') int? promptTokens,
    @JsonKey('completion_tokens') int? completionTokens,
    @JsonKey('total_tokens') int? totalTokens,
  }) = _MiniMaxUsageDTO;
}
```

#### 5.2 MiniMaxApiClient

```dart
// lib/llm/providers/minimax/minimax_api_client.dart
class MiniMaxApiClient {
  final Dio _dio;
  final String _baseUrl;

  MiniMaxApiClient({
    required Dio dio,
    String baseUrl = 'https://api.minimax.chat/v1',
  })  : _dio = dio,
        _baseUrl = baseUrl;

  Stream<MiniMaxResponseDTO> streamMessage({
    required MiniMaxRequestDTO request,
    required String apiKey,
    CancelToken? cancelToken,
  }) async* { /* ... */ }

  Future<MiniMaxResponseDTO> sendMessage({
    required MiniMaxRequestDTO request,
    required String apiKey,
    CancelToken? cancelToken,
  }) async { /* ... */ }
}
```

> **Riesgo específico — SSE parsing:** el parsing de SSE (líneas `data:`) debe manejar:
> - Caracteres multi-byte UTF-8 divididos entre chunks del stream.
> - La línea `data: [DONE]` como sentinel de final.
> - Líneas keep-alive comentario (`: keep-alive`) que deben ignorarse.
> - JSON mal formado en una línea que debe descartarse sin abortar el stream.
>
> **Limitacion conocida:** si `[DONE]` llega en la misma linea que otro evento `data:`, el parser actual hace break y puede perder el otro evento. Documentado en `sse_parsing_test.dart`.

#### 5.3 MiniMaxAdapter

```dart
// lib/llm/providers/minimax/minimax_adapter.dart
class MiniMaxAdapter {
  static GenerateResponseChunk toChunk(MiniMaxResponseDTO dto) { /* ... */ }

  static MiniMaxMessageDTO toDto(ChatMessage message) { /* ... */ }
}
```

#### 5.4 MiniMaxProvider

```dart
// lib/llm/providers/minimax/minimax_provider.dart
class MiniMaxProvider implements ILLMProvider {
  // ...
  static void registerSelf(LLMFactory factory) {
    factory.register('MiniMax', ({...}) => MiniMaxProvider(...));
  }
}
```

**Tareas específicas:**

- [ ] Crear `lib/llm/providers/minimax/dto/minimax_request_dto.dart`.
- [ ] Crear `lib/llm/providers/minimax/dto/minimax_response_dto.dart`.
- [ ] Ejecutar `build_runner` para generar `.freezed.dart` y `.g.dart`.
- [ ] Crear `lib/llm/providers/minimax/minimax_api_exception.dart` (excepcion especifica del API client).
- [ ] Crear `lib/llm/providers/minimax/minimax_api_client.dart` (streaming + non-streaming).
- [ ] Crear `lib/llm/providers/minimax/minimax_adapter.dart` (DTO → dominio).
- [ ] Crear `lib/llm/providers/minimax/minimax_provider.dart` (implementación ILLMProvider + `registerSelf`).
- [ ] Crear `test/llm/providers/minimax/minimax_adapter_test.dart` (verifica `toChunk` y `toDto` con datos conocidos).
- [ ] Crear `test/llm/providers/minimax/minimax_provider_test.dart` (test unitario del provider con `MockDio` y `MockMiniMaxApiClient`).
- [ ] **Test de integración SSE real:** `test/llm/providers/minimax/sse_parsing_test.dart` que pruebe el parsing de SSE con datos UTF-8 multi-byte y el sentinel `[DONE]`. Incluir test para `[DONE]` en misma linea que otro evento `data:`.

**Criterios de aceptación:**
- `MiniMaxProvider` implementa todos los métodos de `ILLMProvider`.
- `registerSelf` produce un builder que `LLMFactory` puede invocar correctamente.
- El test de SSE verifica que un payload con `data: [DONE]` termina el stream sin error.
- El test de SSE verifica que caracteres UTF-8 (ej. emojis, texto en español con acentos) no se cortocircuitan.
- El test de SSE verifica que líneas `: keep-alive` no generan output.

---

### Fase 6 — Gestión de contexto (`context/`)

**Objetivo:** implementar el Strategy Pattern para el manejo de la ventana de contexto: interfaz `ContextStrategy`, `SlidingWindowStrategy`, y `ContextWindowManager`.

**Depende de:** Fase 4 (`ILLMProvider` disponible) y Fase 5 (`calculateTokens` disponible).

#### 6.1 ContextStrategy (interfaz)

```dart
// lib/context/context_strategy.dart
abstract class ContextStrategy {
  List<ChatMessage> apply({
    required List<ChatMessage> messages,
    required int budget,
    required int Function(String text) calculateTokens,
  });
}
```

#### 6.2 SlidingWindowStrategy

```dart
// lib/context/sliding_window_strategy.dart
class SlidingWindowStrategy implements ContextStrategy {
  @override
  List<ChatMessage> apply({
    required List<ChatMessage> messages,
    required int budget,
    required int Function(String text) calculateTokens,
  }) {
    // Pseudocódigo (spec §02 §10.2):
    // 1. safetyMargin = floor(budget * 0.10)
    // 2. effectiveBudget = budget - safetyMargin
    // 3. Iterar desde el más reciente hacia el más antiguo.
    // 4. Si usedTokens + messageTokens > effectiveBudget: BREAK.
    // 5. Mantener orden original.
    // 6. Devolver kept (puede ser vacía).
  }
}
```

#### 6.3 ContextWindowManager

```dart
// lib/context/context_window_manager.dart
class ContextWindowManager {
  final ILLMProvider _provider;
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

  int get _totalBudget => _contextWindow - _maxOutputTokens;

  List<ChatMessage> trimHistory(
    List<ChatMessage> history, {
    String? systemPrompt,
  }) { /* ... */ }

  int estimateNextSendTokens({
    required List<ChatMessage> history,
    required String draft,
    String? systemPrompt,
  }) { /* ... */ }

  double usageRatio({
    required List<ChatMessage> history,
    required String draft,
    String? systemPrompt,
  }) { /* ... */ }
}
```

**Tareas específicas:**

- [ ] Crear `lib/context/context_strategy.dart` (interfaz abstracta).
- [ ] Crear `lib/context/sliding_window_strategy.dart` (implementación default).
- [ ] Crear `lib/context/context_window_manager.dart`.
- [ ] Crear `test/context/sliding_window_strategy_test.dart`:
  - Mensaje que cabe solo: se devuelve completo.
  - Dos mensajes que juntos exceden budget: se descarta el más antiguo.
  - Budget < 100 tokens: devuelve lista vacía.
  - System prompt consume todo el budget: devuelve historial vacío.
  - Historial vacío: devuelve lista vacía (sin error).
- [ ] Crear `test/context/context_window_manager_test.dart`:
  - `trimHistory` reserva el system prompt.
  - `estimateNextSendTokens` devuelve valor positivo.
  - `usageRatio` devuelve valor entre 0.0 y 1.0+ (puede superar 1.0 si excede).
- [ ] Verificar que `SlidingWindowStrategy` no modifica la lista de entrada.

**Criterios de aceptación:**
- `SlidingWindowStrategy` es determinista: misma entrada produce misma salida.
- El margen de seguridad del 10% está implementado y testeado.
- `ContextWindowManager` no guarda estado mutable; es un value object con `_provider` como estrategia inyectada.
- `SlidingWindowStrategy` no tiene dependencias fuera de `dart:math`.

---

## 3. Fase de Composición

### Fase 7 — Inyección de dependencias (`di/`)

**Objetivo:** implementar `lib/di/global_providers.dart` con todos los Riverpod providers globales que la app consume.

**Depende de:** Fases 2, 3, 4, 5, 6 (todos los módulos base disponibles).

#### 7.1 Estructura del archivo

```dart
// lib/di/global_providers.dart

// ─── Infraestructura ────────────────────────────────────────────
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 30),
  ));
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

// ─── LLM ────────────────────────────────────────────────────────
final llmProviderFactoryProvider = Provider<LLMFactory>((ref) {
  final factory = LLMFactory();
  MiniMaxProvider.registerSelf(factory);
  return factory;
});

final llmProviderProvider =
    Provider.family<ILLMProvider, LlmProviderArgs>((ref, args) {
  return ref.read(llmProviderFactoryProvider).build(
        providerId: args.providerId,
        modelId: args.modelId,
        apiKey: args.apiKey,
        contextWindow: args.contextWindow,
        dio: ref.read(dioProvider),
      );
});

final activeLlmProviderProvider =
    FutureProvider.family<ILLMProvider, String>((ref, sessionId) async {
  final session = await ref.watch(sessionProvider(sessionId).future);
  if (session == null) throw StateError('Sesion $sessionId no encontrada');
  final credential = await ref.watch(
    activeCredentialForProviderProvider(session.providerId).future,
  );
  if (credential == null) {
    throw StateError('Sin credencial para provider ${session.providerId}');
  }
  return ref.read(llmProviderFactoryProvider).build(
        providerId: session.providerId,
        modelId: session.modelId,
        apiKey: credential.apiKey,
        contextWindow: session.contextWindow,
        dio: ref.read(dioProvider),
      );
});

class LlmProviderArgs {
  final String providerId;
  final String modelId;
  final String apiKey;
  final int contextWindow;
  // equals, hashCode
}

// ─── Database ───────────────────────────────────────────────────
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final sessionDaoProvider = Provider<SessionDao>((ref) {
  return ref.watch(appDatabaseProvider).sessionDao;
});

final messageDaoProvider = Provider<MessageDao>((ref) {
  return ref.watch(appDatabaseProvider).messageDao;
});

final modelConfigDaoProvider = Provider<ModelConfigDao>((ref) {
  return ref.watch(appDatabaseProvider).modelConfigDao;
});

final credentialHandleDaoProvider = Provider<CredentialHandleDao>((ref) {
  return ref.watch(appDatabaseProvider).credentialHandleDao;
});

// ─── Credential ─────────────────────────────────────────────────
final credentialStoreProvider = Provider<SecureCredentialStore>((ref) {
  return SecureCredentialStore(ref.read(secureStorageProvider));
});

final credentialRepositoryProvider = Provider<CredentialRepository>((ref) {
  return CredentialRepositoryImpl(
    ref.read(credentialStoreProvider),
    ref.read(credentialHandleDaoProvider),
  );
});

final activeCredentialForProviderProvider =
    FutureProvider.family<ActiveCredential?, String>((ref, providerId) async {
  final handles = await ref.watch(credentialRepositoryProvider).list();
  final active = handles
      .where((h) => h.providerId == providerId)
      .toList()
      .firstOrNull;
  if (active == null) return null;
  final apiKey = await ref.watch(credentialRepositoryProvider).read(active.id);
  if (apiKey == null) return null;
  return ActiveCredential(handle: active, apiKey: apiKey);
});

class ActiveCredential {
  final CredentialHandle handle;
  final String apiKey;
  const ActiveCredential({required this.handle, required this.apiKey});
}

final hasAnyCredentialProvider = FutureProvider<bool>((ref) async {
  return ref.watch(credentialRepositoryProvider).list().then((l) => l.isNotEmpty);
});

// ─── Repositorios ──────────────────────────────────────────────
final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  return SessionsRepositoryImpl(ref.watch(appDatabaseProvider));
});

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepositoryImpl(ref.watch(appDatabaseProvider));
});

final modelCatalogRepositoryProvider = Provider<ModelCatalogRepository>((ref) {
  return ModelCatalogRepositoryImpl(ref.watch(appDatabaseProvider));
});

// ─── Utilidades ─────────────────────────────────────────────────
final uuidProvider = Provider<Uuid>((ref) => const Uuid());
```

**Tareas específicas:**

- [ ] Crear `lib/di/global_providers.dart` completo con todos los providers.
- [ ] Crear `test/di/global_providers_test.dart` que use `ProviderContainer` para verificar que cada provider se resuelve sin error circular.
- [ ] Verificar que `appDatabaseProvider` cierra la conexión en `onDispose`.
- [ ] Verificar que `hasAnyCredentialProvider` es `false` al inicio (sin credenciales guardadas) y `true` tras guardar una.

**Criterios de aceptación:**
- `flutter analyze` limpio.
- `test/di/global_providers_test.dart` pasa: todos los providers se resolved sin `StackOverflowError` ni `CircularReferenceError`.
- No hay singletons globales fuera de los providers de Riverpod (el `AppDatabase` vivo mientras el `ProviderScope` exista).

---

### Fase 8 — Casos de uso

**Objetivo:** implementar todos los casos de uso del módulo `session/` y `message/`, incluyendo el crítico `SendMessage`.

**Depende de:** Fases 4, 5, 6, 7 (`ILLMProvider`, `ContextWindowManager`, repositorios disponibles).

#### 8.1 Casos de uso de sesión

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
      id: id, title: title, modelId: modelId, providerId: providerId,
      createdAt: now, updatedAt: now,
    ));
    return id;
  }
}

// lib/session/domain/usecases/list_sessions.dart
// lib/session/domain/usecases/rename_session.dart
// lib/session/domain/usecases/delete_session.dart
```

#### 8.2 SendMessage (el caso de uso central)

```dart
// lib/session/domain/usecases/send_message.dart
// Ver spec §04 §10 para código completo.
// responsibilities:
// 1. Cargar sesión e historial de la DB.
// 2. Convertir Message → ChatMessage (adapter inverso).
// 3. Truncar contexto con ContextWindowManager.
// 4. Persistir mensaje del usuario.
// 5. Crear placeholder del assistant.
// 6. Streamear respuesta vía _provider.generateStream().
// 7. Acumular tokens en sesión y mensaje.
// 8. Manejar CancelToken (usuario aborta).
// 9. Traducir errores a LlmException (nunca exponer DioException).
```

```dart
// lib/session/domain/exceptions/session_not_found_exception.dart
class SessionNotFoundException implements Exception {
  final String sessionId;
  const SessionNotFoundException(this.sessionId);
  @override
  String toString() => 'SessionNotFoundException: $sessionId';
}
```

#### 8.3 Provider factories para casos de uso

```dart
// lib/session/domain/usecases/providers.dart
final createSessionProvider = Provider<CreateSession>((ref) {
  return CreateSession(
    ref.read(sessionsRepositoryProvider),
    ref.read(uuidProvider),
  );
});

final sendMessageProvider = Provider.family<SendMessage, String>(
  (ref, sessionId) {
    // Construye SendMessage con el ILLMProvider activo de la sesion.
    // La sesion se resuelve async y se extrae contextWindow para el
    // ContextWindowManager. Si la sesion no existe, se delega a
    // SendMessage.call() que lanzara SessionNotFoundException.
    final sessionAsync = ref.watch(sessionProvider(sessionId));
    final session = sessionAsync.valueOrNull;
    // ...
  },
);
```

> **Nota de diseño:** `sendMessageProvider` es un `Provider.family` (no `StateProvider.family`) porque `SendMessage` es un caso de uso, no estado de UI. `ChatController` recibe un caso de uso listo y no se acopla a 4 providers distintos.

**Tareas específicas:**

- [ ] Crear `lib/session/domain/usecases/create_session.dart`.
- [ ] Crear `lib/session/domain/usecases/list_sessions.dart`.
- [ ] Crear `lib/session/domain/usecases/rename_session.dart`.
- [ ] Crear `lib/session/domain/usecases/delete_session.dart`.
- [ ] Crear `lib/session/domain/exceptions/session_not_found_exception.dart`.
- [ ] Crear `lib/session/domain/usecases/send_message.dart` completo (spec §04 §10). `SendMessage` llama directamente a `MessagesRepository.listBySession()`, no a un caso de uso intermediario.
- [ ] Crear `lib/session/domain/usecases/providers.dart` con `createSessionProvider` y `sendMessageProvider`.
- [ ] Crear `lib/message/domain/usecases/append_message.dart`.
- [ ] Crear `lib/message/domain/usecases/providers.dart` con `appendMessageProvider`.
- [ ] Crear tests para cada caso de uso:
  - `test/session/domain/usecases/create_session_test.dart`
  - `test/session/domain/usecases/send_message_test.dart` (con `MockILLMProvider`, `MockSessionsRepository`, `MockMessagesRepository`).
- [ ] Verificar que `SendMessage` nunca propaga `DioException` ni `SocketException` al llamador; siempre las convierte a `LlmException`.

**Criterios de aceptación:**
- `SendMessage` es el único caso de uso que llama a `ILLMProvider.generateStream()`.
- `SendMessage` reserva espacio para `maxOutputTokens` en el budget de contexto.
- El mensaje del usuario actual **no** se trunca (va por encima del budget ya que se agrega después de `trimHistory`).
- Cancelar durante streaming deja el mensaje del assistant con el texto parcial recibido hasta el momento.
- El `CancelToken` se propaga hasta `Dio` para abortar la conexión HTTP.

---

## 4. Fase de UI

### Fase 9 — Theming y widgets compartidos

**Objetivo:** implementar el tema Material 3 y los widgets compartidos reutilizables.

**Depende de:** Fase 7 (providers disponibles para theming).

#### 9.1 Theme

```dart
// lib/ui/theme/app_theme.dart
class AppTheme {
  static const _seedColor = Color(0xFF6750A4);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          filled: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 2,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        // Mismos radios de bordes
      );
}
```

#### 9.2 Widgets compartidos

| Widget | Archivo | Descripción |
|---|---|---|
| `PrimaryButton` | `ui/shared/primary_button.dart` | ElevatedButton con loading state |
| `LoadingOverlay` | `ui/shared/loading_overlay.dart` | Stack con spinner + mensaje |
| `ErrorView` | `ui/shared/error_view.dart` | Icono + mensaje + botón reintentar |
| `ConfirmDialog` | `ui/shared/confirm_dialog.dart` | AlertDialog reutilizable para confirmaciones destructivas |
| `EmptyStateView` | `ui/shared/empty_state_view.dart` | Ilustración SVG/Icon + texto + CTA opcional |

```dart
// lib/ui/shared/primary_button.dart
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                Text(label),
              ],
            ),
    );
  }
}
```

**Tareas específicas:**

- [ ] Crear `lib/ui/theme/app_theme.dart` con light y dark.
- [ ] Crear `lib/ui/shared/primary_button.dart`.
- [ ] Crear `lib/ui/shared/loading_overlay.dart`.
- [ ] Crear `lib/ui/shared/error_view.dart`.
- [ ] Crear `lib/ui/shared/confirm_dialog.dart`.
- [ ] Crear `lib/ui/shared/empty_state_view.dart`.
- [ ] Crear `lib/ui/shared/icons.dart` (iconos placeholder para proveedores, si no se usan assets).
- [ ] Tests: `test/ui/shared/primary_button_test.dart`, `test/ui/shared/error_view_test.dart` usando `testWidgets`.

**Criterios de aceptación:**
- `PrimaryButton` muestra `CircularProgressIndicator` cuando `isLoading = true` y `onPressed` es null.
- `ErrorView` permite pasar un callback de reintentar (null = hide botón).
- `ConfirmDialog` recibe `title`, `message`, `confirmLabel` (default "Eliminar"), `isDestructive` (default true). Botón cancelar siempre presente.

---

### Fase 10 — Navegación con go_router

**Objetivo:** configurar `go_router` con todas las rutas, redirects, y deep links.

**Depende de:** Fase 7 (providers disponibles), Fase 9 (theme disponible).

```dart
// lib/ui/router/app_router.dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final hasAny = container.read(hasAnyCredentialProvider).valueOrNull ?? false;
          return hasAny ? '/sessions' : '/models';
        },
      ),
      GoRoute(
        path: '/models',
        builder: (context, state) => const ModelSelectorScreen(),
      ),
      GoRoute(
        path: '/token',
        builder: (context, state) {
          final modelId = state.uri.queryParameters['modelId'] ?? '';
          return TokenInputScreen(modelId: modelId);
        },
      ),
      GoRoute(
        path: '/sessions',
        builder: (context, state) {
          final modelId = state.uri.queryParameters['modelId'];
          return SessionsPanelScreen(initialModelId: modelId);
        },
      ),
      GoRoute(
        path: '/chat/:sessionId',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return ChatScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: ErrorView(
        message: 'Pagina no encontrada',
        onRetry: () => context.go('/'),
      ),
    ),
  );
});
```

**Tareas específicas:**

- [ ] Crear `lib/ui/router/app_router.dart` con todas las rutas.
- [ ] Verificar que el redirect de splash no produce loop infinito (usar `valueOrNull` en lugar de `value` para no bloquear en loading).
- [ ] Probar que `context.go('/chat/xxx')` y `context.push('/token?modelId=yyy')` funcionan desde cualquier pantalla.
- [ ] Crear test: `test/ui/router/app_router_test.dart` (verifica que las rutas están registradas y el redirect de splash es correcto con y sin credenciales).

**Criterios de aceptación:**
- Navegación programa (`context.go`, `context.push`) y deep link (`/chat/abc`) funcionan.
- El redirect en `/` consulta `hasAnyCredentialProvider` sin bloquear la UI.
- No hay loop de redirect entre `/` y ninguna otra ruta.

---

### Fase 11 — Splash + ModelSelector

**Objetivo:** implementar `SplashScreen` y `ModelSelectorScreen` con `availableModelsProvider` y `ModelCard`.

**Depende de:** Fase 10 (router), Fase 7 (providers).

#### 11.1 SplashScreen

```dart
// lib/ui/splash/splash_screen.dart
// Pantalla mínima de brand.
// No hace nada más que esperar el redirect del router.
// Se puede dejar vacía o con un logo centrado.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

#### 11.2 ModelSelectorScreen

```dart
// lib/ui/home/model_selector_screen.dart
// availableModelsProvider: FutureProvider<List<ModelDefinition>>
// Layout: AppBar + ListView de ModelCard
// ModelCard: icono proveedor, nombre, "200k tokens • streaming", badge
// Tap → context.push('/token?modelId=${model.id}')
// Long-press → bottom sheet "Deshabilitar"
```

**Tareas específicas:**

- [ ] Crear `lib/ui/splash/splash_screen.dart`.
- [ ] Crear `lib/ui/home/model_selector_screen.dart`.
- [ ] Crear `lib/ui/home/providers/available_models_provider.dart` (`FutureProvider` que delega a `modelCatalogRepositoryProvider`).
- [ ] Crear `lib/ui/home/widgets/model_card.dart`.
- [ ] Crear `lib/ui/home/widgets/disable_model_sheet.dart`.
- [ ] Implementar estado vacío (`EmptyStateView`) cuando no hay modelos habilitados.
- [ ] Implementar estado de error (`ErrorView`) cuando falla la carga del catálogo.
- [ ] Tests: `test/ui/home/model_selector_screen_test.dart` con `ProviderContainer` override.

**Criterios de aceptación:**
- La lista de modelos viene del catálogo local (`modelCatalogRepository`), no de la red.
- Deshabilitar un modelo actualiza `model_configs.enabled` y la lista se refresca.
- `EmptyStateView` tiene CTA "Ir a Ajustes" → `/settings`.
- Long-press en `ModelCard` muestra el bottom sheet sin navegar.

---

### Fase 12 — TokenInputScreen + ConnectionTestController

**Objetivo:** implementar la pantalla de ingreso y validación de API key con el `ConnectionTestController`.

**Depende de:** Fase 7 (providers), Fase 9 (widgets compartidos), Fase 10 (router).

#### 12.1 ConnectionTestController

```dart
// lib/ui/home/connection_test_controller.dart
class ConnectionTestController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  ConnectionTestController(this._ref) : super(const AsyncData(null));

  Future<String?> test({required String apiKey, required String modelId}) async {
    state = const AsyncLoading();
    // 1. Obtener definición del modelo.
    // 2. Construir provider vía LLMFactory.
    // 3. Llamar testConnection().
    // 4. Devolver null si éxito, mensaje de error si falla.
  }
}

final connectionTestProvider = StateNotifierProvider.autoDispose<
    ConnectionTestController, AsyncValue<void>>(
  (ref) => ConnectionTestController(ref),
);
```

#### 12.2 TokenInputScreen

```dart
// lib/ui/home/token_input_screen.dart
// TextField monoespaciado, password obscure, multilínea
// Switch "Recordar token" (default ON)
// Botón "Probar y continuar" → loading mientras test corre
// Éxito → guardar en secure storage + pushReplacement('/sessions')
// Error → SnackBar con mensaje
// Link "Dónde consigo mi token?" → url_launcher
```

**Tareas específicas:**

- [ ] Crear `lib/ui/home/connection_test_controller.dart`.
- [ ] Crear `lib/ui/home/token_input_screen.dart`.
- [ ] Crear `lib/ui/home/widgets/api_key_text_field.dart`.
- [ ] Crear `lib/ui/home/widgets/remember_token_switch.dart`.
- [ ] Crear `lib/ui/home/widgets/token_help_link.dart`.
- [ ] Integrar `url_launcher` para el link de ayuda.
- [ ] En `TokenInputScreen`: wrapear la llamada a `controller.test()` en try/catch y mostrar errores como `ScaffoldMessenger.showSnackBar(SnackBar(content: Text(error)))`.
- [ ] Guardar credencial en `CredentialRepository` si "Recordar" está ON.
- [ ] Tests: `test/ui/home/connection_test_controller_test.dart` con `ProviderContainer` override y `MockILLMProvider`.

**Criterios de aceptación:**
- El `TextField` es multilínea y monoespaciado.
- El botón está deshabilitado mientras el test corre (`isLoading = true`).
- Tras éxito, la credencial se guarda en `flutter_secure_storage` (no en SQLite).
- Si "Recordar" está OFF, el token se pasa directamente al provider sin persistir.
- El link de ayuda abre la URL del provider (para MiniMax: documentación del API token).

---

### Fase 13 — SessionsPanelScreen

**Objetivo:** implementar el CRUD de sesiones: listado, creación, renombrado, borrado.

**Depende de:** Fase 7 (providers), Fase 8 (casos de uso), Fase 10 (router).

#### 13.1 Estado

```dart
final activeModelIdProvider = StateProvider<String?>((_) => null);

final sessionsStreamProvider = StreamProvider<List<ChatSession>>((ref) {
  final modelId = ref.watch(activeModelIdProvider);
  if (modelId == null) return Stream.value([]);
  return ref.read(sessionsRepositoryProvider).watchByModel(modelId);
});
```

#### 13.2 SessionsPanelScreen

```dart
// lib/ui/sessions/sessions_panel_screen.dart
// AppBar: título del modelo activo, acciones: Modelos, Ajustes
// ListView.separated de SessionTile
// FAB "Nueva sesión" → CreateSession use case → navigate to /chat/:id
// SessionTile: título, subtítulo, PopupMenu (Renombrar, Borrar)
// Renombrar → AlertDialog con TextField
// Borrar → ConfirmDialog (destructivo)
// EmptyStateView cuando no hay sesiones
```

**Tareas específicas:**

- [ ] Crear `lib/ui/sessions/sessions_panel_screen.dart`.
- [ ] Crear `lib/ui/sessions/providers/active_model_id_provider.dart`.
- [ ] Crear `lib/ui/sessions/widgets/session_tile.dart`.
- [ ] Crear `lib/ui/sessions/widgets/rename_session_dialog.dart`.
- [ ] Crear `lib/ui/sessions/widgets/delete_session_dialog.dart` (usa `ConfirmDialog`).
- [ ] Conectar `CreateSession` use case al FAB.
- [ ] Inyectar `activeModelIdProvider` desde la query param `modelId` en la ruta.
- [ ] Tests: `test/ui/sessions/sessions_panel_screen_test.dart`.

**Criterios de aceptación:**
- El Stream de sesiones se actualiza en tiempo real cuando se crea/renombra/borra una sesión (sin hacer refresh manual).
- Crear una sesión nueva navega a `/chat/:newId` inmediatamente.
- Renombrar y borrar no navegan; solo actualizan el Stream.
- El FAB solo aparece si hay un `modelId` activo.

---

### Fase 14 — ChatScreen + ChatController + TokenMeter

**Objetivo:** implementar la pantalla de chat más compleja: streaming, `ChatController`, `ChatState`, `MessageBubble`, `PromptInput`, `TokenMeter`, y `projectedTokensProvider`.

**Depende de:** Fases 7, 8, 9, 10.

#### 14.1 ChatState

```dart
// lib/ui/chat/chat_state.dart
@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    required List<Message> messages,
    @Default(false) bool isStreaming,
    @Default(TokenUsage()) TokenUsage sessionUsage,
    required int contextBudget,
    @Default('') String draft,
    String? error,
  }) = _ChatState;
}
```

#### 14.2 ChatController

```dart
// lib/ui/chat/chat_controller.dart
class ChatController extends StateNotifier<ChatState> {
  final String sessionId;
  final SendMessage _sendMessage;
  CancelToken? _cancelToken;

  ChatController({required this.sessionId, required SendMessage sendMessage, ...})
      : _sendMessage = sendMessage,
        super(_initialState(ref, sessionId));

  Future<void> send(String text) async { /* ... */ }
  void abort() { _cancelToken?.cancel('user_aborted'); }
  void updateDraft(String draft) { state = state.copyWith(draft: draft); }
}
```

#### 14.3 ChatScreen

```dart
// lib/ui/chat/chat_screen.dart
// AppBar: título editable, acción Stop (visible si streaming), overflow menu
// TokenMeter (debajo del AppBar)
// Expanded ListView.builder (invertido) de MessageBubble
// PromptInput (al final)
// projectedTokensProvider para el TokenMeter en tiempo real
```

#### 14.4 MessageBubble

```dart
// lib/ui/chat/widgets/message_bubble.dart
// User: alineado a la derecha, color primario
// Assistant: alineado a la izquierda, color surface
// Status badge: streaming (caret parpadeante), failed (rojo), complete (check)
// Texto con flutter_markdown para respuestas con formato
// Semantics.liveRegion para lectores de pantalla
```

#### 14.5 PromptInput

```dart
// lib/ui/chat/prompt_input.dart
// TextField multilínea con autocrecimiento (max 6 líneas)
// Botón enviar: deshabilitado si isStreaming o draft vacío
// Hint: "Escribí tu mensaje…"
// Sin maxLength (requisito explícito)
```

#### 14.6 TokenMeter

```dart
// lib/message/presentation/widgets/token_meter.dart
// LinearProgressIndicator: verde < 60%, amarillo 60-85%, rojo > 85%
// Texto: "X / Y tokens"
// Tooltip con números exactos
// Warning banner si projectedRatio > 85%
```

#### 14.7 projectedTokensProvider

```dart
// lib/ui/chat/providers/projected_tokens_provider.dart
final projectedTokensProvider = Provider.autoDispose<int>((ref) {
  // Calcula: historial + draft + systemPrompt + maxOutput
  // Usa provider.calculateTokens() del ILLMProvider activo
});
```

**Tareas específicas:**

- [ ] Crear `lib/ui/chat/chat_state.dart` (freezed).
- [ ] Crear `lib/ui/chat/chat_controller.dart`.
- [ ] Crear `lib/ui/chat/chat_screen.dart`.
- [ ] Crear `lib/ui/chat/providers/chat_providers.dart` (messagesStreamProvider, sessionProvider, chatControllerProvider).
- [ ] Crear `lib/ui/chat/providers/projected_tokens_provider.dart`.
- [ ] Crear `lib/ui/chat/widgets/message_bubble.dart`.
- [ ] Crear `lib/ui/chat/widgets/prompt_input.dart`.
- [ ] Crear `lib/ui/chat/widgets/streaming_indicator.dart`.
- [ ] Crear `lib/message/presentation/widgets/token_meter.dart` (reutilizable en Settings).
- [ ] Crear `lib/ui/chat/widgets/context_warning_banner.dart`.
- [ ] Tests: `test/ui/chat/chat_controller_test.dart` (con `MockSendMessage`, `MockILLMProvider`).
- [ ] Tests: `test/ui/chat/message_bubble_test.dart`.
- [ ] Tests: `test/message/presentation/widgets/token_meter_test.dart`.

**Criterios de aceptación:**
- Los mensajes aparecen en el ListView en orden cronológico (más antiguo arriba, más nuevo abajo).
- Al enviar, el mensaje del usuario aparece inmediatamente con `status = complete`; el del assistant con `status = streaming` y se actualiza token a token.
- El botón "Stop" aborta el stream y deja el texto parcial.
- `TokenMeter` se actualiza en tiempo real mientras se escribe el draft (sin enviar).
- `MessageBubble` de assistant con `status = streaming` muestra un caret parpadeante.
- `MessageBubble` con `status = failed` muestra badge rojo y el mensaje de error.
- No hay `maxLength` en el `PromptInput`.
- `SemanticLiveRegion` announce la respuesta completa del assistant al finalizar.

---

### Fase 15 — SettingsScreen

**Objetivo:** implementar la pantalla de ajustes con gestión de credenciales, modelos, tema, e idioma.

**Depende de:** Fases 7, 9, 10.

```dart
// lib/ui/settings/settings_screen.dart
// Secciones:
// 1. Credenciales: lista de CredentialHandle. Tap → re-ingresar token.
//    Long-press → borrar (ConfirmDialog).
// 2. Modelos: ListView de ModelConfig con Switch on/off.
// 3. Apariencia: ThemeMode (light/dark/system).
// 4. Idioma: selector (es/en).
// 5. Avanzado: exportar datos, borrar todo.
// 6. Acerca de: versión, licencias.
```

**Tareas específicas:**

- [ ] Crear `lib/ui/settings/settings_screen.dart`.
- [ ] Crear `lib/ui/settings/widgets/credential_list_tile.dart`.
- [ ] Crear `lib/ui/settings/widgets/model_config_switch.dart`.
- [ ] Crear `lib/ui/settings/widgets/theme_selector.dart`.
- [ ] Crear `lib/ui/settings/widgets/language_selector.dart`.
- [ ] Crear `lib/ui/settings/widgets/advanced_section.dart`.
- [ ] Crear `lib/ui/settings/widgets/about_section.dart`.
- [ ] Conectar `ModelCatalogRepository.setEnabled` al toggle de cada modelo.
- [ ] Persistir `ThemeMode` en `shared_preferences` (solo la preferencia, no el token).
- [ ] Persistir locale en `shared_preferences`.
- [ ] Tests: `test/ui/settings/settings_screen_test.dart`.

**Criterios de aceptación:**
- Deshabilitar un modelo lo oculta del `ModelSelectorScreen` sin borrarlo de la DB.
- Borrar una credencial la elimina de `flutter_secure_storage` y de la tabla `credential_handles`.
- El tema seleccionado se aplica inmediatamente (sin restart de la app).
- No hay opción de exportar datos en MVP (se marca como "próximamente").

---

## 5. Fase Transversal

### Fase 16 — Localización

**Objetivo:** configurar `intl` con `.arb` files y las localizaciones generadas.

**Depende de:** Fase 9 (theme base).

#### 16.1 ARB files

```json
// lib/l10n/app_es.arb
{
  "@@locale": "es",
  "appTitle": "ChatWeaver",
  "modelSelectorTitle": "Elegí un modelo",
  "tokenInputTitle": "Pegá tu API key",
  "sessionsPanelTitle": "Conversaciones",
  "chatHint": "Escribí tu mensaje…",
  "newSession": "Nueva sesión",
  "settings": "Ajustes",
  "deleteSession": "Eliminar sesión",
  "deleteSessionConfirm": "¿Seguro que querés eliminar esta conversación?",
  "cancel": "Cancelar",
  "delete": "Eliminar",
  "retry": "Reintentar",
  "emptyModels": "No hay modelos habilitados. Andá a Ajustes.",
  "emptySessions": "Empezá tu primera conversación",
  "whereGetToken": "¿Dónde consigo mi token?",
  "rememberToken": "Recordar token",
  "testAndContinue": "Probar y continuar",
  "connectionSuccess": "Conectado",
  "stopGenerating": "Detener",
  "tokens": "tokens",
  "credentials": "Credenciales",
  "appearance": "Apariencia",
  "language": "Idioma",
  "advanced": "Avanzado",
  "about": "Acerca de",
  "version": "Versión",
  "contextWarning": "El próximo mensaje usará {percent}% del contexto",
  "@contextWarning": {
    "placeholders": {
      "percent": {"type": "int"}
    }
  }
}
```

```json
// lib/l10n/app_en.arb
{
  "@@locale": "en",
  "appTitle": "ChatWeaver",
  "modelSelectorTitle": "Choose a model",
  "tokenInputTitle": "Paste your API key",
  "sessionsPanelTitle": "Conversations",
  "chatHint": "Write your message…",
  "newSession": "New session",
  "settings": "Settings",
  "deleteSession": "Delete session",
  "deleteSessionConfirm": "Are you sure you want to delete this conversation?",
  "cancel": "Cancel",
  "delete": "Delete",
  "retry": "Retry",
  "emptyModels": "No models enabled. Go to Settings.",
  "emptySessions": "Start your first conversation",
  "whereGetToken": "Where do I get my token?",
  "rememberToken": "Remember token",
  "testAndContinue": "Test and continue",
  "connectionSuccess": "Connected",
  "stopGenerating": "Stop",
  "tokens": "tokens",
  "credentials": "Credentials",
  "appearance": "Appearance",
  "language": "Language",
  "advanced": "Advanced",
  "about": "About",
  "version": "Version",
  "contextWarning": "Next message will use {percent}% of context",
  "@contextWarning": {
    "placeholders": {
      "percent": {"type": "int"}
    }
  }
}
```

**Tareas específicas:**

- [ ] Crear `lib/l10n/app_es.arb` y `lib/l10n/app_en.arb` con todas las keys usadas en la UI.
- [ ] Ejecutar generador de localizations o configurar `l10n.yaml`.
- [ ] Reemplazar todos los strings hardcodeados en pantallas por `AppLocalizations.of(context).keyName`.
- [ ] Formatear números de tokens con `NumberFormat('#,###', locale)` (ej. `1.234` en español).
- [ ] Formatear fechas relativas con `intl.DateFormat.relative()`.
- [ ] Tests de localizacion: verificar que `app_es.arb` y `app_en.arb` tienen las mismas keys.

**Criterios de aceptación:**
- `flutter analyze` no reporta strings sin usar de `AppLocalizations`.
- Los numbers de tokens usan el separador correcto por locale (`.` en español, `,` en inglés).
- Todos los textos visibles en la app usan `AppLocalizations`, no literales.

---

### Fase 17 — Accesibilidad

**Objetivo:** garantizar accesibilidad WCAG AA en toda la app.

**Tareas específicas:**

- [ ] Agregar `Semantics` label a todos los botones que no tienen texto visible (iconos).
- [ ] Agregar `Semantics.liveRegion()` al `ListView` de mensajes para que el lector de pantalla anuncie cada chunk de streaming del assistant.
- [ ] Verificar ratio de contraste en `TokenMeter` (colores verde/amarillo/rojo sobre el fondo).
- [ ] Verificar que el `FocusTraversalGroup` funciona en tablet con teclado físico.
- [ ] Crear `test/ui/accessibility/smoke_test.dart` (usa `SemanticsTester`).
- [ ] Probar en dispositivo real (Android TalkBack, iOS VoiceOver) al menos una vez.

**Criterios de aceptación:**
- `SemanticsTester` pasa en los widgets principales (`MessageBubble`, `PromptInput`, `TokenMeter`).
- El lector de pantalla anuncia "Enviando…" cuando se manda un mensaje y "Respuesta completada" al terminar el stream.
- Todos los `InteractiveViewer` / `ListView` tienen dirección de scroll accesible.

---

### Fase 18 — Matriz de manejo de errores

**Objetivo:** verificar que cada estado vacío/error de cada pantalla está cubierto con el componente correcto.

| Pantalla | Estado | Componente | Implementado en |
|---|---|---|---|
| `ModelSelector` | sin modelos | `EmptyStateView` + "Ir a Ajustes" | Fase 11 |
| `ModelSelector` | error al cargar | `ErrorView` con "Reintentar" | Fase 11 |
| `TokenInput` | test fallido | `SnackBar` con mensaje del tester | Fase 12 |
| `SessionsPanel` | sin sesiones | `EmptyStateView` + CTA "Nueva sesión" | Fase 13 |
| `SessionsPanel` | error al cargar | `ErrorView` con "Reintentar" | Fase 13 |
| `Chat` | sin mensajes | Hint "Escribí tu primer mensaje abajo" | Fase 14 |
| `Chat` | envío fallido | `MessageBubble` con badge rojo + botón "Reintentar" | Fase 14 |
| `Chat` | context overflow | `Banner` amarillo + "Se descartaron N mensajes antiguos" | Fase 14 |
| `Settings` | sin credenciales | `EmptyStateView` con CTA "Agregar credencial" | Fase 15 |

**Tareas específicas:**

- [ ] Hacer revisión línea por línea de la matriz vs implementación real.
- [ ] Implementar `Banner` de context overflow en `ChatScreen` (no existe aún).
- [ ] Implementar botón "Reintentar" en `MessageBubble` con `status = failed`.
- [ ] Verificar que `ErrorView` con "Reintentar" se muestra en todas las pantallas que cargan datos de red o DB.
- [ ] Tests de integración: cada estado de error se puede alcanzar con la app en un estado conocido.

**Criterios de aceptación:**
- La matriz está completa y cada celda tiene un componente asignado.
- No hay `catch (e)` que silencie excepciones sin mostrar nada al usuario.
- Los errores de red muestran el `userMessage` de `LlmException`, nunca `DioException.message`.

---

### Fase 19 — Performance y memoria

**Objetivo:** garantizar que la app no tiene memory leaks, rebuilds innecesarios, ni bottlenecks de rendimiento.

#### 19.1 Rebuild scope

- [ ] `ChatScreen` usa `ref.watch` selectivo: `ref.watch(chatControllerProvider(sessionId))` solo escucha `ChatState` (todo el estado), pero `messagesStreamProvider` y `sessionProvider` se watchean por separado para evitar rebuilds cruzados.
- [ ] `TokenMeter` usa `ref.watch(projectedTokensProvider)` que es un `Provider.autoDispose` que solo se recalcula cuando cambia el draft o los messages.
- [ ] `PromptInput` usa `onChanged` (no `watch`) para actualizar el draft, evitando un rebuild del input mismo.

#### 19.2 ListView correctness

- [ ] `ChatScreen` usa `ListView.builder` con `itemCount` y `itemBuilder` (no `ListView` con children).
- [ ] El `ListView` de `ChatScreen` es invertido (`reverse: true`) para que los mensajes nuevos aparezcan abajo.
- [ ] `SessionsPanelScreen` usa `ListView.separated` con `itemCount` y `itemBuilder`.
- [ ] `ModelSelectorScreen` usa `ListView.builder`.

#### 19.3 Const discipline

- [ ] Todos los widgets que no dependen de estado variable usan `const` constructor.
- [ ] `ThemeData`, `ColorScheme`, `TextStyle` en el tema se declaran como `static const` donde es posible.

#### 19.4 Memory management

- [ ] `AppDatabase` se cierra en `onDispose` del `appDatabaseProvider`.
- [ ] Los `ScrollController` se disposen en `dispose()` de cada `StatefulWidget`.
- [ ] Los `CancelToken` de streams abortados se cancelan explicitamente en `abort()` del `ChatController`.
- [ ] No hay referencias estáticas a widgets ni contextos.
- [ ] Los `ProviderContainer` en tests se disposan al final del test.

#### 19.5 Image caching

- [ ] No hay imágenes de red en MVP. Si se añaden avatares de proveedor, usar `CachedNetworkImage`.

**Tareas específicas:**

- [ ] Run `flutter analyze` con `--observe` para detectar memory leaks en dev.
- [ ] Profiler de Flutter DevTools: verificar que `ChatScreen` no hace más de 2 rebuilds por keystroke en el prompt input.
- [ ] Verificar con `testWidgets` que `PromptInput` no hace rebuild del widget padre al escribir.

**Criterios de aceptación:**
- `ChatScreen` con 100 mensajes no hace scroll janky.
- Escribir en `PromptInput` no dispara rebuild de la lista de mensajes.
- `flutter analyze` sin leaks/warnings.
- Ningún controller (ScrollController, FocusNode, TextEditingController) se deja sin dispose.

---

### Fase 20 — Test final y release

**Objetivo:** test de integración del flujo completo happy path y preparación para release.

#### 20.1 Test de integración — Flujo happy path

```dart
// integration_test/first_use_flow_test.dart
testWidgets('primer uso: splash → modelo → token → sesión → chat',
  (tester) async {
  // 1. App arranca en splash
  // 2. Redirect a /models (sin credenciales)
  // 3. Tap en "MiniMax M"
  // 4. Navega a /token
  // 5. Ingresa API key válida (mock testConnection)
  // 6. Tap "Probar y continuar"
  // 7. Guarda credencial
  // 8. Navega a /sessions
  // 9. Tap FAB "Nueva sesión"
  // 10. Navega a /chat/:id
  // 11. Escribe mensaje
  // 12. Recibir respuesta streaming
  // 13. Cerrar app
  // 14. Volver a abrir → splash → redirect a /sessions (con credencial)
});
```

#### 20.2 Test de integración — Manejo de errores

```dart
// integration_test/error_flows_test.dart
testWidgets('token inválido muestra SnackBar de error', ...);
testWidgets('sesión no encontrada → redirect a /sessions', ...);
testWidgets('streaming abortado → mensaje parcial persiste', ...);
```

#### 20.3 Checklist de release

- [ ] `flutter pub upgrade --major-versions` y resolver conflictos.
- [ ] `flutter analyze` 0 errores, 0 warnings.
- [ ] `flutter test` pasa (unit + widget + integration).
- [ ] Build de debug: `flutter build apk --debug`.
- [ ] Build de release: `flutter build apk --release`.
- [ ] `dart run build_runner build --delete-conflicting-outputs` corriendo en CI.
- [ ] Revisar `CHANGELOG.md` (o crearlo).
- [ ] Revisar `pubspec.yaml` version para el release tag.
- [ ] Verificar que `secureStorageProvider` tiene `aOptions: AndroidOptions(encryptedSharedPreferences: true)` y `iOptions` equivalentes.
- [ ] Verificar que no hay `print` statements en release (analizador lo detecta con `avoid_print`).

---

## 6. Registro de Riesgos

### Riesgo 1 — build_runner y drift_dev

| Riesgo | Drift genera código asíncrono en `.drift.dart` que puede desincronizarse con cambios en tablas. |
|---|---|
| Probabilidad | Media (si se olvidan de regenerar tras cambiar una tabla) |
| Impacto | Alto (compilación rota, tests fallando) |
| Mitigación | Incluir `dart run build_runner build` en el pre-commit hook y en CI. Documentar que tras cambiar cualquier archivo en `db/tables/` o `db/daos/` se debe regenerar. |

### Riesgo 2 — freezed/json_serializable coupling

| Riesgo | Los archivos `.freezed.dart` y `.g.dart` pueden desincronizarse del fuente si no se regeneran. |
|---|---|
| Probabilidad | Media |
| Impacto | Medio (errores de compilación) |
| Mitigación | Misma disciplina de `build_runner` en pre-commit y CI. Los `.freezed.dart` accompany al source en git para que `flutter test` funcione sin regenerar. |

### Riesgo 3 — SSE parsing edge cases

| Riesgo | Characters multi-byte UTF-8 cortados entre chunks del stream. `[DONE]` llegue junto con datos. Líneas keep-alive `: comment` generen output espurio. |
|---|---|
| Probabilidad | Alta (es el caso más frágil del parser SSE) |
| Impacto | Alto (respuestas truncadas, caracteres corruptos, crashes) |
| Mitigación | Tests exhaustivos en `test/llm/providers/minimax/sse_parsing_test.dart` (Fase 5). Parser con try/catch que descarta líneas mal formadas sin abortar. |

### Riesgo 4 — Secure storage platform quirks

| Riesgo | `flutter_secure_storage` tiene comportamiento diferente entre Android (EncryptedSharedPreferences) y iOS (Keychain). En algunos dispositivos Android, la opción por defecto no funciona. |
|---|---|
| Probabilidad | Baja (la mayoría de dispositivos modernos lo soportan) |
| Impacto | Crítico (API keys no se persisten, app no funciona) |
| Mitigación | Configurar explícitamente `AndroidOptions(encryptedSharedPreferences: true)` en `secureStorageProvider`. Probar en emulador Android API 21+ y emulador iOS. |

### Riesgo 5 — CancelToken propagation

| Riesgo | Si `CancelToken` no se propaga correctamente a través de `SendMessage` → `ILLMProvider.generateStream()` → `MiniMaxApiClient.streamMessage()` → `Dio`, el stream sigue aunque el usuario haga abort. |
|---|---|
| Probabilidad | Media |
| Impacto | Medio (el stream se cierra pero la UI puede mostrar estado inconsistente) |
| Mitigación | Verificar que `cancelToken` se pasa en cada capa. Test en `send_message_test.dart` que al cancelar, el provider recibe `cancel()`. |

### Riesgo 6 — go_router redirect loops

| Riesgo | Si `hasAnyCredentialProvider` tarda en resolver (primera vez sin credenciales), puede haber un loop de redirect entre `/` y otra ruta. |
|---|---|
| Probabilidad | Baja (se usa `valueOrNull` con fallback `false`) |
| Impacto | Alto (app no inicia) |
| Mitigación | Usar `valueOrNull ?? false` en el redirect (no `.value`), evitando el wait por loading. Tests de redirect en `app_router_test.dart`. |

### Riesgo 7 — Drift migration on existing installs

| Riesgo | Cuando se hace un upgrade de la app con cambios de esquema (añadir columna, nueva tabla), la migración debe ejecutarse en dispositivos que ya tienen la DB. |
|---|---|
| Probabilidad | Alta (el esquema cambiará en futuras versiones) |
| Impacto | Alto (app crashea al abrir con DB vieja) |
| Mitigación | Todas las migraciones son aditivas (solo añadir, nunca quitar columnas). Cada migración se teste en `test/db/migration_test.dart` simulando upgrade desde `schemaVersion N` a `N+1`. |

### Riesgo 8 — Token estimation accuracy

| Riesgo | `calculateTokens` en MiniMax usa la aproximación `length / 4`. Esto es una estimación; el valor real de la API puede diferir significativamente. |
|---|---|
| Probabilidad | Alta (la aproximación es conocida por ser imprecisa para texto con tokens especiales) |
| Impacto | Medio (el context window puede excederse aunque la estimación diga que no) |
| Mitigación | Documentar que es una estimación. Reservar margen de seguridad del 10% en `SlidingWindowStrategy`. Permitir al usuario ajustar `maxOutputTokens` en Settings. |

---

## 7. Definición de Done

Cada fase debe cumplir todos los criterios antes de considerarse completa. El formato es un checklist que se revisa en el pull request.

### Checklist genérico de fase

```markdown
## Fase X — [Nombre]

### Código
- [ ] Todos los archivos creados en las rutas especificadas
- [ ] `flutter analyze` pasa con 0 errores, 0 warnings
- [ ] `dart format .` ejecutado
- [ ] `dart run build_runner build --delete-conflicting-outputs` completado (si hay code gen)

### Tests
- [ ] Tests unitarios creados para cada clase/módulo nuevo
- [ ] Tests de widget creados para cada pantalla/widget nuevo
- [ ] `flutter test` pasa al 100%
- [ ] Cobertura de `domain/` y `db/` >= 70% (medido con `coverage` package)

### Arquitectura
- [ ] Reglas de dependencia respetadas (ningún `domain/` importa Flutter/Drift/Dio)
- [ ] Ninguna clase fuera de `llm/providers/` importa implementaciones concretas de ILLMProvider
- [ ] Todos los strings visibles en la UI usan `AppLocalizations` (Fase 16+)
- [ ] Recursos (controllers, subscriptions) properly disposed en `dispose()`

### Documentación
- [ ] Comentarios de `// why` donde la decisión no es obvia
- [ ] Doc comments (`///`) en todas las clases públicas de `domain/`
- [ ] README del módulo actualizado si corresponde

### Integración
- [ ] Los providers de la fase se registran correctamente en `global_providers.dart`
- [ ] La navegación entre pantallas funciona correctamente
- [ ] Los estados de loading/error/empty se muestran correctamente
```

---

## 8. Fuera de Alcance para el MVP

Las siguientes features están explícitamente **excluidas** del MVP y no deben implementarse a menos que el equipo lo decida explícitamente:

| Feature | Motivo de exclusión |
|---|---|
| Reintentos automáticos tras fallo de red | Se guarda con `status = failed` y se permite reintentar manualmente |
| Search / FTS5 en historial de chat | Requiere UI de búsqueda y es independiente del core de chat |
| Múltiples credenciales por provider (ej. "Personal" + "Trabajo") | MVP: una sola credencial por provider |
| Exportar chat (PDF, Markdown, JSON) | Feature de polish post-MVP |
| Streaming de múltiples modelos simultáneos | Un modelo a la vez |
| Themes personalizados (colores custom) | Solo light/dark/system |
| Notificaciones push | No hay backend |
| Offline-first con sync | Local-only por diseño |
| i18n más allá de es/en | MVP: solo español (default) e inglés |
| Sesiones compartidas / multi-dispositivo | Local-only |
| OpenAI, Ollama, Anthropic providers | MVP: solo MiniMax |
| Métricas de coste ($) | Solo tokens en MVP |
| Agentes / tools / function calling | Chat puro |
| Web / Desktop | Solo Android e iOS en MVP |

---

## Anexo — Dependencias transient de build_runner

```
drift_dev       → drift
freezed         → freezed_annotation, json_annotation, source_gen
json_serializable → json_annotation, source_gen
build_runner     → las anteriores
```

**Regla:** cuando se actualiza `drift`, actualizar también `drift_dev` a la versión compatible. Verificar en `pub.dev` las constraints de versión.

---

## Appendix: Decisiones arquitectónicas (resueltas durante QA)

| ID | Decision | Racional |
|----|----------|----------|
| Q-1 | `get_session_messages.dart` se **ELIMINA** del plan. `SendMessage` llama `MessagesRepository.listBySession()` directamente. | Spec 04 §10 muestra que `SendMessage` usa el repositorio directamente; no hay caso de uso intermediario en `session/`. |
| Q-2 | Los providers de casos de uso viven en `providers.dart` centralizado dentro de cada modulo: `lib/session/domain/usecases/providers.dart` y `lib/message/domain/usecases/providers.dart`. | Consolida la creación de use cases en un solo archivo por modulo, facilitando lectura y mantenimiento. |
| Q-3 | El mapper solo tiene `toDomain()` (row → domain). Insert/update se hace via `Companion` de Drift directamente en el repositorio. | Spec 02 §4 muestra solo `toDomain()`. Insertar via `Companion` es el patron idiomático de Drift. |
| Q-4 | DAOs en singular: `SessionDao`, `MessageDao`, `ModelConfigDao`, `CredentialHandleDao`. | Consistencia con el patron de nomenclatura del resto del proyecto (modulos en singular). |

---

*Plan generado por flutter-architect agent. Fuente de verdad: `spec/` directory.*
*Última actualización: 2026-06-04*

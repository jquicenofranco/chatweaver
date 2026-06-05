# 01 — Arquitectura y Estructura de Carpetas

> Documento normativo. Define la arquitectura modular, los patrones de diseño (Strategy, Factory, Adapter), la inyección de dependencias, la estructura de carpetas y las reglas de dependencia entre módulos.

---

## 1. Vision general

ChatWeaver es un cliente movil **local-first** para interactuar con multiples proveedores de LLM. Principios fundacionales:

- **Sin backend propio.** No hay registro, no hay login, no hay servidor nuestro.
- **Persistencia local.** Toda la informacion (sesiones, mensajes, configuracion) vive en el dispositivo.
- **Proveedor-agnostico.** El MVP soporta MiniMax; la arquitectura esta disenada para anadir OpenAI, Ollama, Anthropic, etc., sin reescribir la logica de chat.
- **El cliente controla el contexto.** La app es responsable de mantener la ventana de conversacion y de calcular/limitar tokens.
- **Aislamiento total del proveedor LLM.** Todo el codigo especifico de un proveedor vive en su propio módulo; la UI y el dominio nunca ven tipos de proveedor.

---

## 2. Stack tecnologico

### 2.1 Lenguaje y framework

| Componente | Version objetivo | Notas |
|---|---|---|
| Flutter | stable (3.24+) | Soporte maduro de Material 3 e Impeller |
| Dart | 3.5+ | Records, sealed classes, patterns |
| `environment.sdk` en `pubspec.yaml` | segun `pubspec.lock` del proyecto | No introducir breaking changes |

### 2.2 Dependencias de produccion

| Paquete | Rol | Justificacion |
|---|---|---|
| `flutter_riverpod` | **State management + DI** | Compilacion chequeada, sin `BuildContext`, ideal para tests, sirve como contenedor de DI |
| `go_router` | Navegacion declarativa | Rutas type-safe, deep links, manejo de redirecciones |
| `drift` + `drift_flutter` + `sqlite3_flutter_libs` | ORM SQLite type-safe | Queries tipadas, migraciones versionadas, FTS5 para busqueda |
| `path_provider` | Resolucion de rutas del FS | Ubicacion multiplataforma de la DB |
| `flutter_secure_storage` | Almacenamiento del API key | Keychain (iOS) / Keystore (Android) |
| `dio` | Cliente HTTP | Interceptors, `CancelToken`, `ResponseType.stream` |
| `freezed` + `freezed_annotation` | Modelos inmutables | `copyWith`, sealed unions, JSON |
| `json_annotation` + `json_serializable` | (De)serializacion | Mapeo DTO JSON |
| `equatable` | Igualdad por valor | Utilidades para tests |
| `intl` | Fechas y numeros | Formato de tokens, fechas relativas |
| `flutter_markdown` | Render markdown en chat | Respuestas de modelos con formato |
| `url_launcher` | Abrir docs externas | Link "Donde consigo mi token?" |
| `uuid` | Generacion de IDs locales (v4) | Inyectado en casos de uso que crean entidades (sesiones, mensajes) |

### 2.3 Dependencias de desarrollo

| Paquete | Rol |
|---|---|
| `build_runner` | Code generation runner |
| `drift_dev` | Generador de Drift |
| `freezed` (dev) | Generador de freezed |
| `json_serializable` (dev) | Generador de JSON |
| `flutter_lints` | Reglas de lint (ya en el proyecto) |
| `mocktail` | Mocks para tests |
| `riverpod_test` / helpers de Riverpod | Tests de providers |

### 2.4 Justificacion de las decisiones clave

- **Riverpod sobre BLoC/Provider.** BLoC exige ceremonias (eventos, estados) para tareas simples. Provider es dinamico en runtime, no en compile time. Riverpod combina ambos mundos: ergonomia, compilacion chequeada, capacidad de ser sobreescrito en tests sin codigo de produccion.
- **Drift sobre Isar/Hive.** La data es **relacional** (Sesion → Mensajes). Drift permite SQL nativo (joins, FTS5, paginacion eficiente), migraciones explicitas, y esta activamente mantenido. Isar 3.x esta en pausa; Hive es clave-valor y no es apto para el modelo relacional de un chat.
- **Dio sobre `http`.** Necesitamos interceptors (para inyectar `Authorization` por llamada), `CancelToken` (para abortar streams), y `ResponseType.stream` (para SSE). `http` no soporta esto sin parches.
- **`flutter_secure_storage` para el token.** El API key **nunca** debe persistirse en SQLite, en logs, ni en `shared_preferences`. Va al llavero del SO.
- **freezed para modelos.** Evita boilerplate de `copyWith`, igualdad, `toString`, y permite sealed unions para `Result<T>`.

---

## 3. Los tres patrones de diseno

La arquitectura de ChatWeaver se sostiene sobre tres patrones que operan en conjunto para lograr el aislamiento completo de los proveedores LLM. Esta seccion es el eje central de la especificacion; el resto del documento es material de soporte.

### 3.1 Cadena de interaccion

Cuando el usuario selecciona un modelo y envia un mensaje, la cadena de responsabilidad es:

```
Usuario selecciona modelo
        │
        ▼
Factory crea la estrategia (provider concreto)
        │
        ▼
Estrategia (ILLMProvider) envia mensaje via Adapter
        │
        ▼
Adapter normaliza respuesta DTO → ChatMessage (entidad de dominio)
        │
        ▼
Caso de uso (SendMessage) procesa ChatMessage
        │
        ▼
Resultado llega a la UI sin conocer al provider
```

### 3.2 Strategy Pattern — ILLMProvider como estrategia intercambiable

**Problema:** `SendMessage` (caso de uso de chat) necesita ejecutar logica de generacion de texto sin importarle que proveedor/modelo esta activo.

**Solucion:** `ILLMProvider` es la interfaz que define el comportamiento intercambiable. `MiniMaxProvider`, `OpenAiProvider`, `OllamaProvider` son las implementaciones concretas ("estrategias").

El caso de uso consume **solo la interfaz**. Ejemplo simplificado (la implementacion completa esta en [04_UI_State_And_Flow.md §10](04_UI_State_And_Flow.md#10-el-caso-de-uso-sendmessage)):

```dart
// session/domain/usecases/send_message.dart
class SendMessage {
  final ILLMProvider _provider;     // Strategy: abstraccion, no implementacion concreta
  final ContextWindowManager _context;
  final SessionsRepository _sessions;
  final MessagesRepository _messages;

  SendMessage({required ILLMProvider provider, ...}) : _provider = provider, ...;

  Future<void> call({required String sessionId, required String userText, CancelToken? cancelToken}) async {
    // 1. Carga historial desde DB.
    // 2. _context.trimHistory(...) trunca usando _provider.calculateTokens().
    // 3. Construye GenerateRequest.
    // 4. await for (final chunk in _provider.generateStream(...)) { persistir }
  }
}
```

**Por que es importante:** anadir un nuevo proveedor no requiere modificar `SendMessage`. Solo se registra un nuevo builder en el Factory y se crea la clase. El caso de uso sigue funcionando sin cambios.

**Regla:** ninguna clase fuera del modulo `llm/` importa `MiniMaxProvider`, `OpenAiProvider`, ni ninguna otra implementacion concreta de `ILLMProvider`.

### 3.3 Factory Pattern — Registro y creacion de providers

**Problema:** ¿Como se instancia el provider correcto sin hardcodear un switch/if en toda la app?

**Solucion:** `LLMFactory` mantiene un mapa de builders registrados. Cada provider se auto-registra. El factory solo conoce la interfaz, no las implementaciones concretas.

```dart
// lib/llm/llm_factory.dart
typedef LlmProviderBuilder = ILLMProvider Function({
  required String apiKey,
  required String modelId,
  required int contextWindow,
  required Dio dio,
});

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

**Registro de MiniMax (explícito, NO por side-effect de import):**

```dart
// lib/llm/providers/minimax/minimax_provider.dart
class MiniMaxProvider implements ILLMProvider {
  // ... implementacion ...

  /// Auto-registro explicito. Llamado una sola vez desde
  /// [global_providers.dart].
  /// No se ejecuta en top-level del archivo (eso seria side-effect
  /// fragil: no se ejecuta hasta que se importe el archivo,
  /// y Dart no garantiza orden de imports).
  static void registerSelf(LLMFactory factory) {
    factory.register('MiniMax', ({
      required String apiKey,
      required String modelId,
      required int contextWindow,
      required Dio dio,
    }) =>
      MiniMaxProvider(
        apiKey: apiKey,
        modelId: modelId,
        contextWindow: contextWindow,
        dio: dio,
      ),
    );
  }
}
```

**Inyeccion en Riverpod:**

```dart
// lib/di/global_providers.dart
import '../../llm/providers/minimax/minimax_provider.dart';

final llmProviderFactoryProvider = Provider<LLMFactory>((ref) {
  final factory = LLMFactory();
  // Registro explicito por provider. Anadir un nuevo provider = una linea.
  MiniMaxProvider.registerSelf(factory);
  // OpenAiProvider.registerSelf(factory);   // futuro
  // OllamaProvider.registerSelf(factory);   // futuro
  return factory;
});

/// Consumer del factory. Construye un [ILLMProvider] para una sesion concreta.
/// Usado por [activeLlmProviderProvider] (ver seccion 11).
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

/// Argumentos para construir un [ILLMProvider] especifico.
class LlmProviderArgs {
  final String providerId;
  final String modelId;
  final String apiKey;
  final int contextWindow;
  const LlmProviderArgs({
    required this.providerId,
    required this.modelId,
    required this.apiKey,
    required this.contextWindow,
  });

  @override
  bool operator ==(Object other) =>
      other is LlmProviderArgs &&
      other.providerId == providerId &&
      other.modelId == modelId &&
      other.apiKey == apiKey &&
      other.contextWindow == contextWindow;

  @override
  int get hashCode =>
      Object.hash(providerId, modelId, apiKey, contextWindow);
}
```

### 3.4 Adapter Pattern — Traduccion de DTOs nativos a entidades de dominio

**Problema:** cada API de proveedor tiene su propia estructura de respuesta JSON. MiniMax puede devolver un formato diferente a OpenAI. El caso de uso no puede depender de estructuras nativas.

**Solucion:** cada provider tiene su propio `Mapper` que traduce el DTO nativo a la entidad de dominio compartida (`ChatMessage`, `GenerateResponseChunk`). El caso de uso solo conoce las entidades.

```
┌─────────────────────────────────────────────────────────────┐
│  API nativa MiniMax (DTO JSON)                              │
│  { "choices": [{ "delta": { "content": "..." } }] }        │
└─────────────────────┬───────────────────────────────────────┘
                      │ MiniMaxAdapter.toDomain()
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  Entidad de dominio comun                                  │
│  GenerateResponseChunk { textDelta, usage, finishReason }   │
└─────────────────────────────────────────────────────────────┘
```

El mapper es responsabilidad del provider, no del caso de uso.

---

## 4. Arquitectura modular (top-level)

La app se organiza en **módulos top-level** en lugar de la estructura `core/` + `features/`. Cada módulo es autocontenido: puede tener su propia estructura interna `domain/data/presentation`. Los módulos se comunican **exclusivamente** via interfaces declaradas en su `domain/`.

### 4.1 Modulos

| Modulo | Responsabilidad | Puede depender de |
|---|---|---|
| `llm/` | Proveedores LLM (interfaz ILLMProvider + implementaciones) | `di/` |
| `session/` | Sesiones de chat, casos de uso de sesion | `llm/`, `db/`, `message/` |
| `message/` | Mensajes persistidos | `db/` |
| `db/` | Base de datos Drift, secure storage | ninguno (infraestructura) |
| `context/` | Strategy Pattern para gestión de contexto (truncado) | `llm/` |
| `ui/` | Pantallas, widgets compartidos, navegación | `session/`, `message/`, `llm/` |
| `di/` | Inyección de dependencias global (Riverpod providers) | todos |
| `l10n/` | Localización (archivos .arb) | ninguno |

### 4.2 Reglas de dependencia (estrictas)

- Un módulo puede importar **solo** módulos de los que depende segun la tabla 4.1.
- Dentro de un módulo, se aplica Clean Architecture interna: `presentation` → `domain` ← `data`.
- `domain` de cualquier módulo **NO** importa Flutter, Drift, Dio, ni implementaciones concretas. Solo `dart:*` y paquetes neutros (`equatable`, `freezed_annotation`).
- **No existe `core/` transversal.** La logica cross-cutting (errores, network, storage) va en `db/` (storage) y `di/` (DI). El manejo de errores de red vive en `llm/llm_exception.dart` porque es especifico del proveedor.
- Los módulos `session/` y `message/` son **pares**: `session` depende de `message` para orquestar, pero `message` no sabe de `session`.

### 4.3 Principios SOLID aplicados

- **S** — Single Responsibility: `MiniMaxProvider` solo envia/recibe mensajes, no sabe de UI ni de storage.
- **O** — Open/Closed: anadir un nuevo proveedor es **crear un directorio** en `llm/providers/`. No se modifica codigo existente.
- **L** — Liskov: cualquier `ILLMProvider` es intercambiable.
- **I** — Interface Segregation: los metodos de `ILLMProvider` (`testConnection`, `generateStream`, `calculateTokens`, `parseNetworkError`) son cohesivos — todos pertenecen a la misma responsabilidad (hablar con un LLM concreto).
- **D** — Dependency Inversion: los módulos dependen de **abstracciones** declaradas en `domain/` de cada módulo, no de implementaciones concretas.

---

## 5. Estructura de carpetas

```
lib/
├── main.dart                          # Entry point: bootstrap + runApp
├── app.dart                           # MaterialApp.router + theming
├── bootstrap.dart                     # Inicializaciones (DB, errores, logs)
│
├── llm/                               # Modulo LLM (aislamiento total)
│   ├── illm_provider.dart             # Interfaz abstracta (Strategy)
│   ├── llm_factory.dart                # Factory + registry
│   ├── llm_exception.dart              # Excepciones y parser de errores de red
│   ├── chat_message.dart              # Entidad de dominio estandar (ChatRole, ChatMessage)
│   ├── generate_request.dart          # GenerateRequest value object
│   ├── generate_response.dart          # GenerateResponseChunk value object
│   └── providers/
│       └── minimax/
│           ├── minimax_provider.dart          # Implementa ILLMProvider
│           ├── minimax_api_client.dart        # Cliente HTTP especifico
│           ├── minimax_adapter.dart           # DTO -> ChatMessage (Adapter Pattern)
│           └── dto/
│               ├── minimax_request_dto.dart
│               └── minimax_response_dto.dart
│
├── session/                           # Modulo de sesiones de chat
│   ├── domain/
│   │   ├── entities/
│   │   │   └── chat_session.dart
│   │   ├── repositories/
│   │   │   └── sessions_repository.dart
│   │   └── usecases/
│   │       ├── create_session.dart
│   │       ├── list_sessions.dart
│   │       ├── rename_session.dart
│   │       ├── delete_session.dart
│   │       └── send_message.dart     # Strategy: usa ILLMProvider
│   ├── data/
│   │   ├── sessions_repository_impl.dart
│   │   └── mappers/
│   └── presentation/
│       ├── providers/
│       └── screens/
│
├── message/                           # Modulo de mensajes persistidos
│   ├── domain/
│   │   ├── entities/
│   │   │   └── message.dart
│   │   ├── repositories/
│   │   │   └── messages_repository.dart
│   │   └── usecases/
│   │       ├── get_session_messages.dart
│   │       └── append_message.dart
│   ├── data/
│   │   ├── messages_repository_impl.dart
│   │   └── mappers/
│   └── presentation/
│       ├── providers/
│       └── widgets/
│           ├── message_bubble.dart
│           └── token_meter.dart
│
├── db/                                # Modulo de base de datos local
│   ├── app_database.dart
│   ├── tables/
│   │   ├── sessions_table.dart
│   │   ├── messages_table.dart
│   │   ├── model_configs_table.dart
│   │   └── credential_handles_table.dart
│   ├── daos/
│   └── secure_credential_store.dart
│
├── context/                           # Inyeccion de contexto (Strategy Pattern)
│   ├── context_window_manager.dart    # Recibe ILLMProvider como estrategia
│   └── context_strategy.dart          # Interfaz ContextStrategy + SlidingWindowStrategy
│
├── ui/                                # Pantallas principales y navegacion
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
│   └── shared/
│       ├── primary_button.dart
│       ├── loading_overlay.dart
│       └── error_view.dart
│
├── di/                                # Inyeccion de dependencias (Riverpod)
│   └── global_providers.dart
│
└── l10n/
    ├── app_es.arb
    └── app_en.arb
```

---

## 6. Justificacion del prefijo `I` en `ILLMProvider`

**Decision:** la interfaz abstracta del proveedor se llama `ILLMProvider` (con prefijo `I`), no `LlmProvider`.

**Justificacion:**

Aunque la convencion habitual de Dart **no** recomienda prefijos `I` (se prefiere `LlmProvider` o `LlmClient`), en este proyecto se adopto el prefijo por las siguientes razones:

1. **Senalamiento visual deliberado.** En una arquitectura con multiples módulos y muchos archivos, el prefijo `I` comunica instantaneamente que `ILLMProvider` es un contrato abstracto y no una implementacion concreta. Con `LlmProvider` es imposible distinguir a simple vista si es interfaz o implementacion.
2. **Contrast con `MiniMaxProvider` que tiene sufijo.** La convencion del proyecto usa sufijo para implementaciones concretas (`MiniMaxProvider`, `OpenAiProvider`) y prefijo `I` para interfaces. Esta asimetria deliberada reinforce la regla arquitectonica: "la UI y los casos de uso solo ven la interfaz".
3. **Contexto del equipo.** Este diseno fue solicitado explicitamente por el usuario para este proyecto. La convencion Dart general es un buenas practicas generales, no una regla inquebrantable; la consistencia con las decisiones del equipo prima sobre la convencion general.

**Regla:** cualquier nueva interfaz de provider en este proyecto debe seguir la convencion `I<Nombre>Provider` (ej. `IOllamaProvider`, `IAnthropicProvider`).

---

## 7. Convenciones de codigo

### 7.1 Naming

- **Archivos:** `snake_case.dart`.
- **Clases:** `PascalCase`.
- **Providers Riverpod:** sufijo `Provider` (`sessionsRepositoryProvider`).
- **Notifiers/Controllers:** sufijo `Notifier` o `Controller` (`ChatController`).
- **Modulos:** en singular (`llm`, `session`, `message`, `db`).
- **Interfaces de provider:** prefijo `I`, sufijo `Provider` (`ILLMProvider`).
- **Implementaciones concretas:** sufijo `Provider` (`MiniMaxProvider`).

### 7.2 Estilo y formato

- `dart format .` antes de cada commit.
- `flutter analyze` debe pasar sin warnings.
- `prefer_single_quotes: true` recomendado.
- Lineas menor o igual a 100 caracteres.
- Comentarios solo cuando explican **por que**, no que.

### 7.3 Code generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 8. Testing

| Tipo | Herramienta | Objetivo |
|---|---|---|
| Unit | `test` | Casos de uso, mappers, `ContextWindowManager`, providers |
| Widget | `flutter_test` | Pantallas, `MessageBubble`, `TokenMeter` |
| Integration | `integration_test` | Flujos completos de UI |
| Provider | `ProviderContainer` overrides | Notifiers y logica asincrona |

Cobertura objetivo minima: **70%** en capas `domain/` y `db/`.

Convenciones:

- Estructura: Arrange-Act-Assert.
- Mocks con `mocktail` (no `mockito`, evita code-gen adicional).
- Tests de los providers con `ProviderContainer` y `overrideWith`.

---

## 9. Anadir un nuevo proveedor LLM

1. Crear `lib/llm/providers/<provider_id>/` con la estructura minima:
   - `dto/`: DTOs nativos de la API.
   - `<provider_id>_adapter.dart`: Adapter DTO → ChatMessage / GenerateResponseChunk.
   - `<provider_id>_api_client.dart`: Cliente HTTP especifico (si lo necesita).
   - `<provider_id>_provider.dart`: implementacion de `ILLMProvider`.
2. En el archivo del provider, al final, ejecutar `registerSelf(LLMFactory)` explicitamente.
3. En `lib/di/global_providers.dart`, importar el provider y llamar a `registerSelf(factory)`.
4. No se toca codigo de `session/`, `message/`, ni ninguna otra feature. ✅

El factory es el unico punto de extension. Las features consumen la **interfaz** (`ILLMProvider`), no las implementaciones.

---

## 10. Proximos pasos

1. Implementar `db/` y la logica de contexto → ver [02_Local_Database_And_Context.md](02_Local_Database_And_Context.md).
2. Implementar `llm/` → ver [03_LLM_Module_And_MiniMax.md](03_LLM_Module_And_MiniMax.md).
3. Construir las pantallas y el estado Riverpod → ver [04_UI_State_And_Flow.md](04_UI_State_And_Flow.md).

---

## 11. Providers globales de DI (`lib/di/global_providers.dart`)

Ademas del `llmProviderFactoryProvider` mostrado en §3.3, el archivo `global_providers.dart` declara los providers transversales que la UI y los casos de uso consumen. Lista completa (referenciada desde multiples specs):

```dart
// lib/di/global_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../llm/llm_factory.dart';
import '../../llm/illm_provider.dart';
import '../../llm/providers/minimax/minimax_provider.dart';
import '../../db/credential_repository.dart';
import '../../db/secure_credential_store.dart';
import '../../db/credential_handle.dart';
import '../../session/domain/repositories/sessions_repository.dart';
import '../../message/domain/repositories/messages_repository.dart';
```

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

// ─── LLM factory + providers (ver §3.3) ────────────────────────

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

/// Provider activo para una sesion de chat. Resuelve el factory con
/// la credencial del provider del modelo activo. Async porque depende
/// de `sessionProvider` (FutureProvider) y de la carga de credencial.
final activeLlmProviderProvider =
    FutureProvider.family<ILLMProvider, String>((ref, sessionId) async {
  final session = await ref.watch(sessionProvider(sessionId).future);
  if (session == null) {
    throw StateError('Sesion $sessionId no encontrada');
  }
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

// ─── Credenciales ───────────────────────────────────────────────

final credentialStoreProvider = Provider<SecureCredentialStore>((ref) {
  return SecureCredentialStore(ref.read(secureStorageProvider));
});

final credentialRepositoryProvider = Provider<CredentialRepository>((ref) {
  return CredentialRepositoryImpl(ref.read(credentialStoreProvider));
});

/// Credencial activa (con el API key desencriptado) para un provider.
/// Usado por [activeLlmProviderProvider] y por la pantalla de token.
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

/// True si existe al menos una credencial guardada.
/// Usado por el redirect de splash de go_router (ver 04 §3.2).
final hasAnyCredentialProvider = FutureProvider<bool>((ref) async {
  return ref.watch(credentialRepositoryProvider).list().then((l) => l.isNotEmpty);
});

// ─── Repositorios (referencias) ────────────────────────────────

final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  // Implementacion en lib/session/data/sessions_repository_impl.dart
  throw UnimplementedError('Inyectar AppDatabase desde lib/db/');
});

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  // Implementacion en lib/message/data/messages_repository_impl.dart
  throw UnimplementedError('Inyectar AppDatabase desde lib/db/');
});

// ─── Utilidades ─────────────────────────────────────────────────

/// Generador de UUIDs v4. Inyectado en casos de uso (`CreateSession`,
/// `SendMessage`) que necesitan generar IDs locales para entidades nuevas.
final uuidProvider = Provider<Uuid>((ref) => const Uuid());
```

> **Nota:** los providers `sessionsRepositoryProvider` y `messagesRepositoryProvider` se muestran como placeholder. La implementacion concreta recibe `AppDatabase` (de `db/`) — se documenta completamente cuando se implemente `db/`.

**Regla:** ningun caso de uso o widget debe hacer `import 'package:dio/dio.dart'` o instanciar `LLMFactory` directamente. Todo se obtiene por `ref.read(...)` o `ref.watch(...)`.

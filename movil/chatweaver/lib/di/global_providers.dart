import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import 'package:chatweaver/context/context_window_manager.dart';
import 'package:chatweaver/db/app_database.dart';
import 'package:chatweaver/db/credential_handle.dart';
import 'package:chatweaver/db/credential_repository.dart';
import 'package:chatweaver/db/credential_repository_impl.dart';
import 'package:chatweaver/db/secure_credential_store.dart';
import 'package:chatweaver/llm/illm_provider.dart';
import 'package:chatweaver/llm/llm_factory.dart';
import 'package:chatweaver/llm/providers/minimax/minimax_provider.dart';
import 'package:chatweaver/message/data/messages_repository_impl.dart';
import 'package:chatweaver/message/domain/entities/message.dart';
import 'package:chatweaver/message/domain/repositories/messages_repository.dart';
import 'package:chatweaver/message/domain/usecases/append_message.dart';
import 'package:chatweaver/message/domain/usecases/get_session_messages.dart';
import 'package:chatweaver/session/data/model_catalog_repository_impl.dart';
import 'package:chatweaver/session/data/sessions_repository_impl.dart';
import 'package:chatweaver/session/domain/entities/chat_session.dart';
import 'package:chatweaver/session/domain/entities/model_definition.dart';
import 'package:chatweaver/session/domain/repositories/model_catalog_repository.dart';
import 'package:chatweaver/session/domain/repositories/sessions_repository.dart';
import 'package:chatweaver/session/domain/usecases/create_session.dart';
import 'package:chatweaver/session/domain/usecases/delete_session.dart';
import 'package:chatweaver/session/domain/usecases/list_sessions.dart';
import 'package:chatweaver/session/domain/usecases/rename_session.dart';
import 'package:chatweaver/session/domain/usecases/send_message.dart';

// ─── Infraestructura ────────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 30),
      // receiveTimeout: 0 = sin timeout (importante para streams).
    ),
  );
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final uuidProvider = Provider<Uuid>((ref) => const Uuid());

// ─── Credenciales ───────────────────────────────────────────────

final credentialStoreProvider = Provider<SecureCredentialStore>((ref) {
  return SecureCredentialStore(ref.read(secureStorageProvider));
});

final credentialRepositoryProvider = Provider<CredentialRepository>((ref) {
  return CredentialRepositoryImpl(
    db: ref.read(appDatabaseProvider),
    store: ref.read(credentialStoreProvider),
  );
});

/// Wrapper con el API key desencriptado. Vive solo en memoria.
class ActiveCredential {
  const ActiveCredential({required this.handle, required this.apiKey});

  final CredentialHandle handle;
  final String apiKey;
}

/// Credencial activa (con el API key) para un provider. Async porque
/// lee secure storage.
final activeCredentialForProviderProvider =
    FutureProvider.family<ActiveCredential?, String>((ref, providerId) async {
  final repo = ref.read(credentialRepositoryProvider);
  final handle = await repo.activeFor(providerId);
  if (handle == null) return null;
  final apiKey = await repo.read(handle.id);
  if (apiKey == null) return null;
  return ActiveCredential(handle: handle, apiKey: apiKey);
});

/// True si existe al menos una credencial guardada.
/// Usado por el redirect de splash.
final hasAnyCredentialProvider = FutureProvider<bool>((ref) async {
  final handles = await ref.read(credentialRepositoryProvider).list();
  return handles.isNotEmpty;
});

// ─── LLM factory + providers ────────────────────────────────────

final llmProviderFactoryProvider = Provider<LLMFactory>((ref) {
  final factory = LLMFactory();
  MiniMaxProvider.registerSelf(factory);
  return factory;
});

/// Argumentos para construir un [ILLMProvider] especifico.
class LlmProviderArgs {
  const LlmProviderArgs({
    required this.providerId,
    required this.modelId,
    required this.apiKey,
    required this.contextWindow,
  });

  final String providerId;
  final String modelId;
  final String apiKey;
  final int contextWindow;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LlmProviderArgs &&
          providerId == other.providerId &&
          modelId == other.modelId &&
          apiKey == other.apiKey &&
          contextWindow == other.contextWindow;

  @override
  int get hashCode =>
      Object.hash(providerId, modelId, apiKey, contextWindow);
}

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

// ─── Repositorios ───────────────────────────────────────────────

final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  return SessionsRepositoryImpl(ref.read(appDatabaseProvider));
});

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepositoryImpl(ref.read(appDatabaseProvider));
});

final modelCatalogRepositoryProvider = Provider<ModelCatalogRepository>((ref) {
  return ModelCatalogRepositoryImpl(ref.read(appDatabaseProvider));
});

// ─── Sesiones / Mensajes ────────────────────────────────────────

/// Stream de una sesion por id.
final sessionProvider =
    FutureProvider.family<ChatSession?, String>((ref, sessionId) async {
  return ref.read(sessionsRepositoryProvider).getById(sessionId);
});

/// Stream de mensajes de una sesion.
final messagesStreamProvider =
    StreamProvider.family<List<Message>, String>((ref, sessionId) {
  return ref.read(messagesRepositoryProvider).watchBySession(sessionId);
});

/// Provider activo para una sesion de chat.
final activeLlmProviderProvider =
    FutureProvider.family<ILLMProvider, String>((ref, sessionId) async {
  final session = await ref.watch(sessionProvider(sessionId).future);
  if (session == null) {
    throw StateError('Sesion $sessionId no encontrada');
  }
  final model = await ref.read(modelCatalogRepositoryProvider).getById(
        session.modelId,
      );
  if (model == null) {
    throw StateError('Modelo ${session.modelId} no encontrado en catalogo');
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
        contextWindow: model.contextWindow,
        dio: ref.read(dioProvider),
      );
});

// ─── Casos de uso (CQRS) ────────────────────────────────────────

final createSessionProvider = Provider<CreateSession>((ref) {
  return CreateSession(
    sessions: ref.read(sessionsRepositoryProvider),
    uuid: ref.read(uuidProvider),
  );
});

final listSessionsProvider = Provider<ListSessions>((ref) {
  return ListSessions(ref.read(sessionsRepositoryProvider));
});

final renameSessionProvider = Provider<RenameSession>((ref) {
  return RenameSession(ref.read(sessionsRepositoryProvider));
});

final deleteSessionProvider = Provider<DeleteSession>((ref) {
  return DeleteSession(ref.read(sessionsRepositoryProvider));
});

final getSessionMessagesProvider = Provider<GetSessionMessages>((ref) {
  return GetSessionMessages(ref.read(messagesRepositoryProvider));
});

final appendMessageProvider = Provider<AppendMessage>((ref) {
  return AppendMessage(ref.read(messagesRepositoryProvider));
});

/// Use case [SendMessage] pre-construido para una sesion.
/// Resuelve el provider activo, el context manager y los repos.
final sendMessageProvider =
    Provider.family<SendMessage, String>((ref, sessionId) {
  final providerAsync = ref.watch(activeLlmProviderProvider(sessionId));
  final provider = providerAsync.valueOrNull;
  if (provider == null) {
    throw StateError('No se pudo resolver el provider LLM para $sessionId');
  }
  return SendMessage(
    provider: provider,
    sessions: ref.read(sessionsRepositoryProvider),
    messages: ref.read(messagesRepositoryProvider),
    context: ContextWindowManager(
      provider: provider,
      contextWindow: provider.contextWindow,
    ),
    uuid: ref.read(uuidProvider),
  );
});

/// Lista de modelos habilitados. Usado por el selector de modelo
/// y por la pantalla de settings.
final availableModelsProvider = FutureProvider<List<ModelDefinition>>((ref) {
  return ref.read(modelCatalogRepositoryProvider).listEnabled();
});

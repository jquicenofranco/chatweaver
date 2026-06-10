import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatweaver/context/context_window_manager.dart';
import 'package:chatweaver/di/global_providers.dart';
import 'package:chatweaver/llm/illm_provider.dart';
import 'package:chatweaver/llm/llm_exception.dart';
import 'package:chatweaver/message/domain/entities/message.dart';
import 'package:chatweaver/message/domain/entities/token_usage.dart';
import 'package:chatweaver/session/domain/usecases/send_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_controller.freezed.dart';

/// Estado del chat. **Spec 05 (T-22)**: `reasoningByMessageId` es
/// un espejo incremental del `Message.reasoning` para que la UI
/// pueda acceder al trace de un mensaje por id sin re-iterar la
/// lista completa. La fuente canonica sigue siendo `Message.reasoning`
/// desde el `messagesStreamProvider`; este map es un derivado.
@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default(<Message>[]) List<Message> messages,
    @Default(false) bool isStreaming,
    @Default(TokenUsage()) TokenUsage sessionUsage,
    @Default(<String, String>{}) Map<String, String> reasoningByMessageId,
    @Default('') String draft,
    String? error,
  }) = _ChatState;
}

/// Controller principal de la pantalla de chat.
///
/// Sigue el patron StateNotifier (no Notifier) para conservar
/// la firma exacta de spec 04 §4.4.
///
/// Importante: el caso de uso [SendMessage] se resuelve **lazy** dentro
/// de [send], no en el constructor. Esto evita el race condition donde
/// `activeLlmProviderProvider(sessionId)` todavia esta en loading al
/// construir el controller (sucede al entrar a un chat de sesion
/// recien creada) y un `ref.read(...).valueOrNull` sincrono lanzaba
/// `StateError("No se pudo resolver el provider LLM para ...")`.
/// Los errores se propagan a [ChatState.error] en vez de throwear.
class ChatController extends StateNotifier<ChatState> {
  ChatController({required this.sessionId, required this.ref})
    : super(const ChatState());

  final String sessionId;
  final Ref ref;
  CancelToken? _cancelToken;

  /// Resuelve el caso de uso [SendMessage] para la sesion activa.
  ///
  /// await-ea el `activeLlmProviderProvider` (que puede estar loading
  /// al entrar a un chat de sesion nueva) y propaga cualquier
  /// excepcion al caller para que la convierta en [ChatState.error].
  ///
  /// No se cachea: si el usuario cambia la credencial activa en
  /// Ajustes, queremos que el siguiente `send` use la nueva. El
  /// `autoDispose` del provider garantiza que el controller se
  /// reconstruye si la sesion cambia.
  ///
  /// **Spec 05 (T-16)**: inyecta `ModelCatalogRepository` para que
  /// `SendMessage` pueda resolver `supportsReasoning` del modelo
  /// activo.
  Future<SendMessage> _resolveSendMessage() async {
    final ILLMProvider provider = await ref.read(
      activeLlmProviderProvider(sessionId).future,
    );
    return SendMessage(
      provider: provider,
      sessions: ref.read(sessionsRepositoryProvider),
      messages: ref.read(messagesRepositoryProvider),
      models: ref.read(modelCatalogRepositoryProvider),
      context: ContextWindowManager(
        provider: provider,
        contextWindow: provider.contextWindow,
      ),
      uuid: ref.read(uuidProvider),
    );
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    _cancelToken = CancelToken();
    state = state.copyWith(isStreaming: true, error: null);
    try {
      final sendMessage = await _resolveSendMessage();
      await sendMessage(
        sessionId: sessionId,
        userText: text,
        cancelToken: _cancelToken,
      );
    } on LlmException catch (e) {
      state = state.copyWith(error: e.userMessage);
    } catch (e) {
      // Cubre errores de resolucion del provider (sesion borrada,
      // modelo removido del catalogo, sin credencial, etc.) y
      // cualquier otra excepcion inesperada. Antes esto throweaba
      // sin control y reventaba la UI.
      state = state.copyWith(error: 'Error al enviar: $e');
    } finally {
      state = state.copyWith(isStreaming: false);
    }
  }

  void abort() => _cancelToken?.cancel('user_aborted');

  void updateDraft(String draft) {
    state = state.copyWith(draft: draft);
  }

  void refreshUsage(int inputTokens, int outputTokens) {
    state = state.copyWith(
      sessionUsage: TokenUsage(
        inputTokens: inputTokens,
        outputTokens: outputTokens,
      ),
    );
  }

  /// **Spec 05 (T-22)**: sincroniza el map `reasoningByMessageId`
  /// desde la lista de mensajes. Llamado por la UI despues de cada
  /// `messagesStreamProvider` emit (el `ChatScreen` puede hacer
  /// `controller.syncFromMessages(messages)` en un listener).
  ///
  /// Se usa `mapEquals` para evitar rebuilds innecesarios cuando el
  /// contenido no cambio (ej. un update de status de un mensaje
  /// que no es del assistant).
  void syncFromMessages(List<Message> messages) {
    final next = <String, String>{};
    for (final m in messages) {
      if (m.reasoning != null && m.reasoning!.isNotEmpty) {
        next[m.id] = m.reasoning!;
      }
    }
    if (!mapEquals(state.reasoningByMessageId, next)) {
      state = state.copyWith(reasoningByMessageId: next);
    }
  }
}

final chatControllerProvider = StateNotifierProvider.autoDispose
    .family<ChatController, ChatState, String>(
      (ref, sessionId) => ChatController(sessionId: sessionId, ref: ref),
    );

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatweaver/di/global_providers.dart';
import 'package:chatweaver/llm/llm_exception.dart';
import 'package:chatweaver/message/domain/entities/message.dart';
import 'package:chatweaver/message/domain/entities/token_usage.dart';
import 'package:chatweaver/session/domain/usecases/send_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_controller.freezed.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default(<Message>[]) List<Message> messages,
    @Default(false) bool isStreaming,
    @Default(TokenUsage()) TokenUsage sessionUsage,
    @Default('') String draft,
    String? error,
  }) = _ChatState;
}

/// Controller principal de la pantalla de chat.
///
/// Sigue el patron StateNotifier (no Notifier) para conservar
/// la firma exacta de spec 04 §4.4.
class ChatController extends StateNotifier<ChatState> {
  ChatController({
    required this.sessionId,
    required SendMessage sendMessage,
  })  : _sendMessage = sendMessage,
        super(const ChatState());

  final String sessionId;
  final SendMessage _sendMessage;
  CancelToken? _cancelToken;

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

  void refreshUsage(int inputTokens, int outputTokens) {
    state = state.copyWith(
      sessionUsage: TokenUsage(
        inputTokens: inputTokens,
        outputTokens: outputTokens,
      ),
    );
  }
}

final chatControllerProvider = StateNotifierProvider.autoDispose
    .family<ChatController, ChatState, String>(
  (ref, sessionId) => ChatController(
    sessionId: sessionId,
    sendMessage: ref.read(sendMessageProvider(sessionId)),
  ),
);

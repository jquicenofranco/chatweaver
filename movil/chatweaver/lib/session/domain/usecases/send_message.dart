import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'package:chatweaver/context/context_window_manager.dart';
import 'package:chatweaver/llm/chat_message.dart';
import 'package:chatweaver/llm/generate_request.dart';
import 'package:chatweaver/llm/illm_provider.dart';
import 'package:chatweaver/llm/llm_exception.dart';
import 'package:chatweaver/message/domain/entities/message.dart';
import 'package:chatweaver/message/domain/repositories/messages_repository.dart';
import 'package:chatweaver/session/domain/exceptions/session_not_found_exception.dart';
import 'package:chatweaver/session/domain/repositories/sessions_repository.dart';

/// Caso de uso principal: enviar un mensaje del usuario y streamear
/// la respuesta del LLM activo.
///
/// Implementa el Strategy Pattern: el provider concreto
/// ([MiniMaxProvider], etc.) se inyecta via [ILLMProvider].
class SendMessage {
  const SendMessage({
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

  final ILLMProvider _provider;
  final SessionsRepository _sessions;
  final MessagesRepository _messages;
  final ContextWindowManager _context;
  final Uuid _uuid;

  Future<void> call({
    required String sessionId,
    required String userText,
    CancelToken? cancelToken,
  }) async {
    final session = await _sessions.getById(sessionId);
    if (session == null) throw SessionNotFoundException(sessionId);

    final history = await _messages.listBySession(sessionId);
    final historyAsChat = history
        .map(
          (m) => ChatMessage(
            id: m.id,
            role: _toChatRole(m.role),
            content: m.content,
            timestamp: m.createdAt,
          ),
        )
        .toList(growable: false);

    final trimmed = _context.trimHistory(
      historyAsChat,
      systemPrompt: session.systemPrompt,
    );

    final userMsgId = _uuid.v4();
    await _messages.append(
      Message(
        id: userMsgId,
        sessionId: sessionId,
        role: MessageRole.user,
        content: userText,
        status: MessageStatus.complete,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      ),
    );
    await _sessions.touch(sessionId, DateTime.now());

    final request = GenerateRequest(
      messages: [
        ...trimmed,
        ChatMessage(
          id: userMsgId,
          role: ChatRole.user,
          content: userText,
          timestamp: DateTime.now(),
        ),
      ],
      systemPrompt: session.systemPrompt,
    );

    final assistantMsgId = _uuid.v4();
    await _messages.append(
      Message(
        id: assistantMsgId,
        sessionId: sessionId,
        role: MessageRole.assistant,
        content: '',
        status: MessageStatus.streaming,
        createdAt: DateTime.now(),
      ),
    );

    final buffer = StringBuffer();
    try {
      await for (final chunk in _provider.generateStream(
        request: request,
        cancelToken: cancelToken,
      )) {
        if (chunk.errorMessage != null) {
          await _messages.updateStatus(
            assistantMsgId,
            MessageStatus.failed,
            error: chunk.errorMessage,
          );
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
          await _messages.updateStatus(assistantMsgId, MessageStatus.complete);
          await _messages.patch(assistantMsgId, completedAt: DateTime.now());
        }
      }
    } on CancelToken {
      // Usuario aborto. Texto parcial queda persistido.
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

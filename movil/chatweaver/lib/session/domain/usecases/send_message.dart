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
import 'package:chatweaver/session/domain/repositories/model_catalog_repository.dart';
import 'package:chatweaver/session/domain/repositories/sessions_repository.dart';

/// Caso de uso principal: enviar un mensaje del usuario y streamear
/// la respuesta del LLM activo.
///
/// Implementa el Strategy Pattern: el provider concreto
/// ([MiniMaxProvider], etc.) se inyecta via [ILLMProvider].
///
/// **Spec 05 (T-14, T-15, T-16)**: cuando el modelo activo tiene
/// `supportsReasoning = true`, el caso de uso:
/// 1. Envia `enableReasoning: true` al [GenerateRequest].
/// 2. Mantiene un `reasoningBuffer` paralelo al `contentBuffer`.
/// 3. Persiste el reasoning incrementalmente (un write por chunk
///    de `reasoningDelta`) en `Message.reasoning`.
/// 4. Persiste los `thinkingTokens` en `Message.thinkingTokens`.
/// 5. Si el provider no devuelve `thinkingTokens` (OQ-02 fallback),
///    estima como `length(reasoningBuffer) / 4`.
class SendMessage {
  const SendMessage({
    required ILLMProvider provider,
    required SessionsRepository sessions,
    required MessagesRepository messages,
    required ModelCatalogRepository models,
    required ContextWindowManager context,
    required Uuid uuid,
  }) : _provider = provider,
       _sessions = sessions,
       _messages = messages,
       _models = models,
       _context = context,
       _uuid = uuid;

  final ILLMProvider _provider;
  final SessionsRepository _sessions;
  final MessagesRepository _messages;
  final ModelCatalogRepository _models;
  final ContextWindowManager _context;
  final Uuid _uuid;

  Future<void> call({
    required String sessionId,
    required String userText,
    CancelToken? cancelToken,
  }) async {
    final session = await _sessions.getById(sessionId);
    if (session == null) throw SessionNotFoundException(sessionId);

    // **Spec 05 (T-16)**: resolver `supportsReasoning` desde el
    // catalogo. Si el modelo no existe o no soporta reasoning,
    // `enableReasoning` queda en false y la feature se desactiva
    // silenciosamente (C-BIZ-02).
    final modelDef = await _models.getById(session.modelId);
    final enableReasoning = modelDef?.supportsReasoning ?? false;

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
      enableReasoning: enableReasoning,
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

    // **Spec 05 (T-14)**: dos buffers paralelos para que la UI vea
    // el reasoning aparecer progresivamente (no solo al final).
    final contentBuffer = StringBuffer();
    final reasoningBuffer = StringBuffer();
    // Flag para evitar doble `updateStatus(complete)`: si el
    // stream cerro con `finishReason`, ya se actualizo; si
    // cerro sin finishReason (stream truncado, cancel del
    // usuario via `on CancelToken`, etc.), el bloque
    // post-loop lo hace.
    var markedComplete = false;
    try {
      await for (final chunk in _provider.generateStream(
        request: request,
        cancelToken: cancelToken,
      )) {
        if (chunk.errorMessage != null) {
          // Persistir el reasoning parcial ANTES de marcar failed,
          // para que no se pierda lo que el modelo ya razono.
          if (reasoningBuffer.isNotEmpty) {
            await _messages.updateReasoning(
              assistantMsgId,
              reasoningBuffer.toString(),
            );
          }
          await _messages.updateStatus(
            assistantMsgId,
            MessageStatus.failed,
            error: chunk.errorMessage,
          );
          throw ProviderException(chunk.errorMessage!);
        }
        if (chunk.textDelta != null) {
          contentBuffer.write(chunk.textDelta);
          await _messages.updateContent(
            assistantMsgId,
            contentBuffer.toString(),
          );
        }
        // **Spec 05 (T-15)**: persistir el reasoning incremental.
        if (chunk.reasoningDelta != null) {
          reasoningBuffer.write(chunk.reasoningDelta);
          await _messages.updateReasoning(
            assistantMsgId,
            reasoningBuffer.toString(),
          );
        }
        if (chunk.usage != null) {
          // **Spec 05 (OQ-02)**: si el provider no devuelve
          // thinking tokens, estimamos por longitud del buffer.
          // Es un fallback; la precisión es suficiente para el
          // `TokenMeter` (feedback, no facturación).
          final reported = chunk.usage!.thinkingTokens;
          final estimated = reasoningBuffer.isEmpty
              ? 0
              : (reasoningBuffer.length / 4).ceil();
          final thinkingTokens = reported > 0 ? reported : estimated;
          await _messages.updateTokenUsage(
            assistantMsgId,
            inputTokens: chunk.usage!.inputTokens,
            outputTokens: chunk.usage!.outputTokens,
            thinkingTokens: thinkingTokens,
          );
          await _sessions.accumulateTokens(
            sessionId,
            input: chunk.usage!.inputTokens,
            output: chunk.usage!.outputTokens,
            // thinking NO se acumula en la sesion (MVP): el
            // TokenMeter lo consume desde la lista de mensajes.
          );
        }
        if (chunk.finishReason != null) {
          await _messages.updateStatus(assistantMsgId, MessageStatus.complete);
          await _messages.patch(assistantMsgId, completedAt: DateTime.now());
          markedComplete = true;
        }
      }
      // **Stream cerro normalmente (sin error, sin cancel, sin
      // finishReason explicito)**: el provider aborto el stream
      // o no envio el chunk final. Marcamos el mensaje como
      // complete para que la UI no quede en "streaming" forever.
      // El texto + reasoning parciales ya estan persistidos
      // incrementalmente durante el loop.
      if (!markedComplete) {
        await _messages.updateStatus(assistantMsgId, MessageStatus.complete);
        await _messages.patch(assistantMsgId, completedAt: DateTime.now());
      }
    } on CancelToken {
      // Usuario aborto. Texto + reasoning parciales quedan persistidos.
      // El reasoning es valioso: el usuario queria verlo.
      if (reasoningBuffer.isNotEmpty) {
        await _messages.updateReasoning(
          assistantMsgId,
          reasoningBuffer.toString(),
        );
      }
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

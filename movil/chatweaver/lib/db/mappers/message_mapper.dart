import 'package:chatweaver/db/app_database.dart';
import 'package:chatweaver/message/domain/entities/message.dart';

/// Mapea `MessageRow` (Drift) ↔ `Message` (dominio).
///
/// **Spec 05 (T-11)**: `reasoning` y `thinkingTokens` viajan
/// nullable. Mensajes pre-v3 quedan con `null` (la UI los trata
/// como no-thinking). Mensajes con reasoning se persisten
/// incrementalmente durante el streaming.
extension MessageMapper on MessageRow {
  Message toDomain() => Message(
    id: id,
    sessionId: sessionId,
    role: _toDomainRole(role),
    content: content,
    reasoning: reasoning,
    inputTokens: inputTokens,
    outputTokens: outputTokens,
    thinkingTokens: thinkingTokens,
    status: _toDomainStatus(status),
    errorMessage: errorMessage,
    createdAt: createdAt,
    completedAt: completedAt,
  );

  static MessageRole _toDomainRole(String r) => switch (r) {
    'system' => MessageRole.system,
    'user' => MessageRole.user,
    'assistant' => MessageRole.assistant,
    _ => MessageRole.user,
  };

  static MessageStatus _toDomainStatus(String s) => switch (s) {
    'sending' => MessageStatus.sending,
    'streaming' => MessageStatus.streaming,
    'complete' => MessageStatus.complete,
    'failed' => MessageStatus.failed,
    _ => MessageStatus.complete,
  };
}

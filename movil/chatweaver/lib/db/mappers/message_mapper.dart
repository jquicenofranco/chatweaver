import 'package:chatweaver/db/app_database.dart';
import 'package:chatweaver/message/domain/entities/message.dart';

extension MessageMapper on MessageRow {
  Message toDomain() => Message(
        id: id,
        sessionId: sessionId,
        role: _toDomainRole(role),
        content: content,
        inputTokens: inputTokens,
        outputTokens: outputTokens,
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

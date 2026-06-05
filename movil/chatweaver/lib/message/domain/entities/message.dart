import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';

enum MessageRole { system, user, assistant }

enum MessageStatus { sending, streaming, complete, failed }

/// Mensaje persistido de una sesion.
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

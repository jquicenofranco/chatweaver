import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_session.freezed.dart';

/// Sesion de chat: una conversacion (thread) del usuario.
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

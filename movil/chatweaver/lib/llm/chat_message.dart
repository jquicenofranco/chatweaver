import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';

enum ChatRole { system, user, assistant }

/// Mensaje normalizado que cruza capas (DB -> dominio -> provider).
///
/// Es la unica representacion de mensaje que el caso de uso
/// SendMessage conoce. Los DTOs nativos de cada provider
/// (MiniMax, OpenAI, etc.) se traducen a este tipo via el
/// Adapter Pattern.
@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required ChatRole role,
    required String content,
    int? inputTokens,
    int? outputTokens,
    String? finishReason,
    String? errorMessage,
    DateTime? timestamp,
  }) = _ChatMessage;
}

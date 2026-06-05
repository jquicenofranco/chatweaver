import 'package:chatweaver/llm/chat_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generate_request.freezed.dart';

/// Request normalizado que el caso de uso envia al provider activo.
@freezed
class GenerateRequest with _$GenerateRequest {
  const factory GenerateRequest({
    required List<ChatMessage> messages,
    String? systemPrompt,
    @Default(0.7) double temperature,
    @Default(1024) int maxOutputTokens,
  }) = _GenerateRequest;
}

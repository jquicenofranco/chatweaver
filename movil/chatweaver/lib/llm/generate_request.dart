import 'package:chatweaver/llm/chat_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generate_request.freezed.dart';

/// Request normalizado que el caso de uso envia al provider activo.
///
/// **Spec 05 (T-16)**: [enableReasoning] es opt-in. El caso de uso
/// `SendMessage` lo setea en `true` cuando el `ModelDefinition` del
/// modelo activo tiene `supportsReasoning = true`. Providers que no
/// entiendan el flag lo ignoran (no rompe backward-compat).
@freezed
class GenerateRequest with _$GenerateRequest {
  const factory GenerateRequest({
    required List<ChatMessage> messages,
    String? systemPrompt,
    @Default(0.7) double temperature,
    @Default(1024) int maxOutputTokens,

    /// Pide al provider que exponga el reasoning trace separado del
    /// answer. Solo tiene efecto en providers que lo soporten.
    @Default(false) bool enableReasoning,
  }) = _GenerateRequest;
}

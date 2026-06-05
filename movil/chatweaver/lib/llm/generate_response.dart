import 'package:freezed_annotation/freezed_annotation.dart';

part 'generate_response.freezed.dart';

/// Chunk individual emitido por un [ILLMProvider] durante streaming.
///
/// El caso de uso SendMessage consume estos chunks para ir
/// persistiendo la respuesta incrementalmente.
@freezed
class GenerateResponseChunk with _$GenerateResponseChunk {
  const factory GenerateResponseChunk({
    String? textDelta,
    LlmUsage? usage,
    String? finishReason,
    String? errorMessage,
  }) = _GenerateResponseChunk;
}

@freezed
class LlmUsage with _$LlmUsage {
  const factory LlmUsage({
    required int inputTokens,
    required int outputTokens,
  }) = _LlmUsage;

  const LlmUsage._();

  int get total => inputTokens + outputTokens;
}

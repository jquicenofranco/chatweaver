import 'package:freezed_annotation/freezed_annotation.dart';

part 'generate_response.freezed.dart';

/// Chunk individual emitido por un [ILLMProvider] durante streaming.
///
/// El caso de uso SendMessage consume estos chunks para ir
/// persistiendo la respuesta incrementalmente.
///
/// **Spec 05 (T-01)**: `reasoningDelta` lleva el trace de
/// razonamiento de modelos pensantes, separado del `textDelta` de
/// la respuesta final. Nunca se mezclan; la UI los renderiza en
/// widgets distintos ([ReasoningPanel] vs. bubble del assistant).
@freezed
class GenerateResponseChunk with _$GenerateResponseChunk {
  const factory GenerateResponseChunk({
    String? textDelta,

    /// Incremental de reasoning trace. Solo presente en modelos que
    /// producen chain-of-thought (MiniMax M3, o1, DeepSeek-R1, etc.)
    /// y cuando el provider lo expone como stream separado.
    /// Null para modelos no-thinking y para providers sin soporte.
    String? reasoningDelta,
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

    /// Thinking tokens (spec 05 T-02): autoritativos del provider si
    /// el API los expone en `usage.reasoning_tokens`; 0 si no.
    /// Distinto de `outputTokens` (respuesta final). C-TECH-06.
    @Default(0) int thinkingTokens,
  }) = _LlmUsage;

  const LlmUsage._();

  /// Suma los tres flujos. Backward-compat: con `thinkingTokens = 0`
  /// (default) coincide con el `total` previo a spec 05.
  int get total => inputTokens + outputTokens + thinkingTokens;
}

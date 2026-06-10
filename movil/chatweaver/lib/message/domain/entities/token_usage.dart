import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_usage.freezed.dart';

/// Acumulado de tokens de la sesion.
///
/// Refleja lo que el provider reporta como autoritativo; el
/// cliente solo estima (ver `ContextWindowManager`).
///
/// **Spec 05 (T-03)**: `thinkingTokens` es una tercera categoria
/// independiente de `inputTokens` y `outputTokens` (C-TECH-06). El
/// `TokenMeter` los renderiza como segmento aparte para que el
/// usuario vea cuanto del context window consume el razonamiento.
@freezed
class TokenUsage with _$TokenUsage {
  const factory TokenUsage({
    @Default(0) int inputTokens,
    @Default(0) int outputTokens,
    @Default(0) int thinkingTokens,
  }) = _TokenUsage;

  const TokenUsage._();

  /// Suma los tres flujos. Backward-compat: con `thinkingTokens = 0`
  /// (default) coincide con el `total` previo a spec 05.
  int get total => inputTokens + outputTokens + thinkingTokens;
}

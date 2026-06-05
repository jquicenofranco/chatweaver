import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_usage.freezed.dart';

/// Acumulado de tokens de la sesion.
///
/// Refleja lo que el provider reporta como autoritativo; el
/// cliente solo estima (ver `ContextWindowManager`).
@freezed
class TokenUsage with _$TokenUsage {
  const factory TokenUsage({
    @Default(0) int inputTokens,
    @Default(0) int outputTokens,
  }) = _TokenUsage;

  const TokenUsage._();

  int get total => inputTokens + outputTokens;
}

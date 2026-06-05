import 'package:freezed_annotation/freezed_annotation.dart';

part 'model_definition.freezed.dart';

/// Catalogo de un modelo LLM disponible localmente.
///
/// Sembrado en el primer arranque (`_seedModelConfigs`).
@freezed
class ModelDefinition with _$ModelDefinition {
  const factory ModelDefinition({
    required String id,
    required String providerId,
    required String displayName,
    required int contextWindow,
    @Default(true) bool supportsStreaming,
    String? apiBaseUrl,
    @Default(true) bool enabled,
  }) = _ModelDefinition;
}

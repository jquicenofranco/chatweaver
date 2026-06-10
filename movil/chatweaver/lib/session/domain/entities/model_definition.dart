import 'package:freezed_annotation/freezed_annotation.dart';

part 'model_definition.freezed.dart';

/// Catalogo de un modelo LLM disponible localmente.
///
/// Sembrado en el primer arranque (`_seedModelConfigs`).
///
/// **Spec 05 (T-25)**: `supportsReasoning` indica si el modelo
/// produce un trace de razonamiento separado del answer (ej. M3).
/// Default `false` para backward-compat con providers/modelos que
/// no lo exponen. La UI consulta este flag para decidir si mostrar
/// el `ReasoningPanel`; el caso de uso lo consulta para enviar
/// `reasoning_split: true` en el request.
@freezed
class ModelDefinition with _$ModelDefinition {
  const factory ModelDefinition({
    required String id,
    required String providerId,
    required String displayName,
    required int contextWindow,
    @Default(true) bool supportsStreaming,
    @Default(false) bool supportsReasoning,
    String? apiBaseUrl,
    @Default(true) bool enabled,
  }) = _ModelDefinition;
}

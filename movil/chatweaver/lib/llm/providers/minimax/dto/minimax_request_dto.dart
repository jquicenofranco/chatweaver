import 'package:freezed_annotation/freezed_annotation.dart';

part 'minimax_request_dto.freezed.dart';
part 'minimax_request_dto.g.dart';

// freezed genera el campo desde el parametro del factory;
// el analyzer no lo sabe, asi que ignoramos la advertencia.
// ignore_for_file: invalid_annotation_target

@freezed
class MiniMaxRequestDTO with _$MiniMaxRequestDTO {
  const factory MiniMaxRequestDTO({
    required String model,
    required List<MiniMaxMessageDTO> messages,
    @Default(true) bool stream,
    @Default(0.7) double temperature,
    @JsonKey(name: 'max_tokens') @Default(1024) int maxTokens,

    /// **Spec 05 (T-07)**: pide al API separar `reasoning_content`
    /// de `content` en el delta. Solo se envia en `true` cuando el
    /// `ModelDefinition.supportsReasoning == true` (resuelto por el
    /// caso de uso y propagado via [GenerateRequest.enableReasoning]).
    @JsonKey(name: 'reasoning_split') @Default(false) bool reasoningSplit,

    /// **Spec 05 (T-07 / OQ-05)**: habilita thinking adaptativo en
    /// modelos como M3. Se omite del JSON si es null (json_serializable
    /// lo maneja con `includeIfNull: false`). Se envia como
    /// `{"type": "adaptive"}` cuando el provider lo soporta.
    @JsonKey(includeIfNull: false) Map<String, dynamic>? thinking,
  }) = _MiniMaxRequestDTO;

  factory MiniMaxRequestDTO.fromJson(Map<String, dynamic> json) =>
      _$MiniMaxRequestDTOFromJson(json);
}

@freezed
class MiniMaxMessageDTO with _$MiniMaxMessageDTO {
  const factory MiniMaxMessageDTO({
    required String role,
    required String content,
  }) = _MiniMaxMessageDTO;

  factory MiniMaxMessageDTO.fromJson(Map<String, dynamic> json) =>
      _$MiniMaxMessageDTOFromJson(json);
}

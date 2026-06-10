import 'package:freezed_annotation/freezed_annotation.dart';

part 'minimax_response_dto.freezed.dart';
part 'minimax_response_dto.g.dart';

// freezed genera el campo desde el parametro del factory;
// el analyzer no lo sabe, asi que ignoramos la advertencia.
// ignore_for_file: invalid_annotation_target

@freezed
class MiniMaxResponseDTO with _$MiniMaxResponseDTO {
  const factory MiniMaxResponseDTO({
    required String id,
    String? object,
    int? created,
    String? model,
    List<MiniMaxChoiceDTO>? choices,
    MiniMaxUsageDTO? usage,
    @JsonKey(name: 'finish_reason') String? finishReason,
  }) = _MiniMaxResponseDTO;

  factory MiniMaxResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$MiniMaxResponseDTOFromJson(json);
}

@freezed
class MiniMaxChoiceDTO with _$MiniMaxChoiceDTO {
  const factory MiniMaxChoiceDTO({
    MiniMaxDeltaDTO? delta,
    @JsonKey(name: 'finish_reason') String? finishReason,
    int? index,
  }) = _MiniMaxChoiceDTO;

  factory MiniMaxChoiceDTO.fromJson(Map<String, dynamic> json) =>
      _$MiniMaxChoiceDTOFromJson(json);
}

/// Delta incremental de un choice.
///
/// **OQ-01 RESUELTO (empirico)**: MiniMax **no** expone el
/// reasoning en un campo separado. Lo emite inline en `content`
/// delimitado por tags `<think>...</think>`. La separacion se
/// hace en el cliente via [ThinkingStreamParser] dentro de
/// [MiniMaxProvider]. Este DTO queda con `content` y `role`
/// (formato OpenAI-compatible).
@freezed
class MiniMaxDeltaDTO with _$MiniMaxDeltaDTO {
  const factory MiniMaxDeltaDTO({String? content, String? role}) =
      _MiniMaxDeltaDTO;

  factory MiniMaxDeltaDTO.fromJson(Map<String, dynamic> json) =>
      _$MiniMaxDeltaDTOFromJson(json);
}

/// Usage reportado por MiniMax al final del stream.
///
/// **OQ-02 TBD**: `reasoningTokens` puede o no venir segun la
/// version de la API. Si viene, el adapter lo usa autoritativamente.
/// Si no, el caso de uso [SendMessage] estima via length/4 del
/// reasoning buffer.
@freezed
class MiniMaxUsageDTO with _$MiniMaxUsageDTO {
  const factory MiniMaxUsageDTO({
    @JsonKey(name: 'prompt_tokens') int? promptTokens,
    @JsonKey(name: 'completion_tokens') int? completionTokens,
    @JsonKey(name: 'total_tokens') int? totalTokens,
    @JsonKey(name: 'reasoning_tokens') int? reasoningTokens,
  }) = _MiniMaxUsageDTO;

  factory MiniMaxUsageDTO.fromJson(Map<String, dynamic> json) =>
      _$MiniMaxUsageDTOFromJson(json);
}

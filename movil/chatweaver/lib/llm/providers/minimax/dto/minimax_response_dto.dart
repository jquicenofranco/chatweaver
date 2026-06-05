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

@freezed
class MiniMaxDeltaDTO with _$MiniMaxDeltaDTO {
  const factory MiniMaxDeltaDTO({
    String? content,
    String? role,
  }) = _MiniMaxDeltaDTO;

  factory MiniMaxDeltaDTO.fromJson(Map<String, dynamic> json) =>
      _$MiniMaxDeltaDTOFromJson(json);
}

@freezed
class MiniMaxUsageDTO with _$MiniMaxUsageDTO {
  const factory MiniMaxUsageDTO({
    @JsonKey(name: 'prompt_tokens') int? promptTokens,
    @JsonKey(name: 'completion_tokens') int? completionTokens,
    @JsonKey(name: 'total_tokens') int? totalTokens,
  }) = _MiniMaxUsageDTO;

  factory MiniMaxUsageDTO.fromJson(Map<String, dynamic> json) =>
      _$MiniMaxUsageDTOFromJson(json);
}

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

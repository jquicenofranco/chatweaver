// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'minimax_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MiniMaxRequestDTOImpl _$$MiniMaxRequestDTOImplFromJson(
  Map<String, dynamic> json,
) => _$MiniMaxRequestDTOImpl(
  model: json['model'] as String,
  messages: (json['messages'] as List<dynamic>)
      .map((e) => MiniMaxMessageDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  stream: json['stream'] as bool? ?? true,
  temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
  maxTokens: (json['max_tokens'] as num?)?.toInt() ?? 1024,
);

Map<String, dynamic> _$$MiniMaxRequestDTOImplToJson(
  _$MiniMaxRequestDTOImpl instance,
) => <String, dynamic>{
  'model': instance.model,
  'messages': instance.messages,
  'stream': instance.stream,
  'temperature': instance.temperature,
  'max_tokens': instance.maxTokens,
};

_$MiniMaxMessageDTOImpl _$$MiniMaxMessageDTOImplFromJson(
  Map<String, dynamic> json,
) => _$MiniMaxMessageDTOImpl(
  role: json['role'] as String,
  content: json['content'] as String,
);

Map<String, dynamic> _$$MiniMaxMessageDTOImplToJson(
  _$MiniMaxMessageDTOImpl instance,
) => <String, dynamic>{'role': instance.role, 'content': instance.content};

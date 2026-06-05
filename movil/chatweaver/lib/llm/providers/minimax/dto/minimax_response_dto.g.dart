// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'minimax_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MiniMaxResponseDTOImpl _$$MiniMaxResponseDTOImplFromJson(
  Map<String, dynamic> json,
) => _$MiniMaxResponseDTOImpl(
  id: json['id'] as String,
  object: json['object'] as String?,
  created: (json['created'] as num?)?.toInt(),
  model: json['model'] as String?,
  choices: (json['choices'] as List<dynamic>?)
      ?.map((e) => MiniMaxChoiceDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  usage: json['usage'] == null
      ? null
      : MiniMaxUsageDTO.fromJson(json['usage'] as Map<String, dynamic>),
  finishReason: json['finish_reason'] as String?,
);

Map<String, dynamic> _$$MiniMaxResponseDTOImplToJson(
  _$MiniMaxResponseDTOImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'object': instance.object,
  'created': instance.created,
  'model': instance.model,
  'choices': instance.choices,
  'usage': instance.usage,
  'finish_reason': instance.finishReason,
};

_$MiniMaxChoiceDTOImpl _$$MiniMaxChoiceDTOImplFromJson(
  Map<String, dynamic> json,
) => _$MiniMaxChoiceDTOImpl(
  delta: json['delta'] == null
      ? null
      : MiniMaxDeltaDTO.fromJson(json['delta'] as Map<String, dynamic>),
  finishReason: json['finish_reason'] as String?,
  index: (json['index'] as num?)?.toInt(),
);

Map<String, dynamic> _$$MiniMaxChoiceDTOImplToJson(
  _$MiniMaxChoiceDTOImpl instance,
) => <String, dynamic>{
  'delta': instance.delta,
  'finish_reason': instance.finishReason,
  'index': instance.index,
};

_$MiniMaxDeltaDTOImpl _$$MiniMaxDeltaDTOImplFromJson(
  Map<String, dynamic> json,
) => _$MiniMaxDeltaDTOImpl(
  content: json['content'] as String?,
  role: json['role'] as String?,
);

Map<String, dynamic> _$$MiniMaxDeltaDTOImplToJson(
  _$MiniMaxDeltaDTOImpl instance,
) => <String, dynamic>{'content': instance.content, 'role': instance.role};

_$MiniMaxUsageDTOImpl _$$MiniMaxUsageDTOImplFromJson(
  Map<String, dynamic> json,
) => _$MiniMaxUsageDTOImpl(
  promptTokens: (json['prompt_tokens'] as num?)?.toInt(),
  completionTokens: (json['completion_tokens'] as num?)?.toInt(),
  totalTokens: (json['total_tokens'] as num?)?.toInt(),
);

Map<String, dynamic> _$$MiniMaxUsageDTOImplToJson(
  _$MiniMaxUsageDTOImpl instance,
) => <String, dynamic>{
  'prompt_tokens': instance.promptTokens,
  'completion_tokens': instance.completionTokens,
  'total_tokens': instance.totalTokens,
};

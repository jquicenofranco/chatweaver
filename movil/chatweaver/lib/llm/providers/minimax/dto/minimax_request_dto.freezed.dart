// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'minimax_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MiniMaxRequestDTO _$MiniMaxRequestDTOFromJson(Map<String, dynamic> json) {
  return _MiniMaxRequestDTO.fromJson(json);
}

/// @nodoc
mixin _$MiniMaxRequestDTO {
  String get model => throw _privateConstructorUsedError;
  List<MiniMaxMessageDTO> get messages => throw _privateConstructorUsedError;
  bool get stream => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_tokens')
  int get maxTokens => throw _privateConstructorUsedError;

  /// **Spec 05 (T-07)**: pide al API separar `reasoning_content`
  /// de `content` en el delta. Solo se envia en `true` cuando el
  /// `ModelDefinition.supportsReasoning == true` (resuelto por el
  /// caso de uso y propagado via [GenerateRequest.enableReasoning]).
  @JsonKey(name: 'reasoning_split')
  bool get reasoningSplit => throw _privateConstructorUsedError;

  /// **Spec 05 (T-07 / OQ-05)**: habilita thinking adaptativo en
  /// modelos como M3. Se omite del JSON si es null (json_serializable
  /// lo maneja con `includeIfNull: false`). Se envia como
  /// `{"type": "adaptive"}` cuando el provider lo soporta.
  @JsonKey(includeIfNull: false)
  Map<String, dynamic>? get thinking => throw _privateConstructorUsedError;

  /// Serializes this MiniMaxRequestDTO to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MiniMaxRequestDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MiniMaxRequestDTOCopyWith<MiniMaxRequestDTO> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MiniMaxRequestDTOCopyWith<$Res> {
  factory $MiniMaxRequestDTOCopyWith(
    MiniMaxRequestDTO value,
    $Res Function(MiniMaxRequestDTO) then,
  ) = _$MiniMaxRequestDTOCopyWithImpl<$Res, MiniMaxRequestDTO>;
  @useResult
  $Res call({
    String model,
    List<MiniMaxMessageDTO> messages,
    bool stream,
    double temperature,
    @JsonKey(name: 'max_tokens') int maxTokens,
    @JsonKey(name: 'reasoning_split') bool reasoningSplit,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? thinking,
  });
}

/// @nodoc
class _$MiniMaxRequestDTOCopyWithImpl<$Res, $Val extends MiniMaxRequestDTO>
    implements $MiniMaxRequestDTOCopyWith<$Res> {
  _$MiniMaxRequestDTOCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MiniMaxRequestDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? model = null,
    Object? messages = null,
    Object? stream = null,
    Object? temperature = null,
    Object? maxTokens = null,
    Object? reasoningSplit = null,
    Object? thinking = freezed,
  }) {
    return _then(
      _value.copyWith(
            model: null == model
                ? _value.model
                : model // ignore: cast_nullable_to_non_nullable
                      as String,
            messages: null == messages
                ? _value.messages
                : messages // ignore: cast_nullable_to_non_nullable
                      as List<MiniMaxMessageDTO>,
            stream: null == stream
                ? _value.stream
                : stream // ignore: cast_nullable_to_non_nullable
                      as bool,
            temperature: null == temperature
                ? _value.temperature
                : temperature // ignore: cast_nullable_to_non_nullable
                      as double,
            maxTokens: null == maxTokens
                ? _value.maxTokens
                : maxTokens // ignore: cast_nullable_to_non_nullable
                      as int,
            reasoningSplit: null == reasoningSplit
                ? _value.reasoningSplit
                : reasoningSplit // ignore: cast_nullable_to_non_nullable
                      as bool,
            thinking: freezed == thinking
                ? _value.thinking
                : thinking // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MiniMaxRequestDTOImplCopyWith<$Res>
    implements $MiniMaxRequestDTOCopyWith<$Res> {
  factory _$$MiniMaxRequestDTOImplCopyWith(
    _$MiniMaxRequestDTOImpl value,
    $Res Function(_$MiniMaxRequestDTOImpl) then,
  ) = __$$MiniMaxRequestDTOImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String model,
    List<MiniMaxMessageDTO> messages,
    bool stream,
    double temperature,
    @JsonKey(name: 'max_tokens') int maxTokens,
    @JsonKey(name: 'reasoning_split') bool reasoningSplit,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? thinking,
  });
}

/// @nodoc
class __$$MiniMaxRequestDTOImplCopyWithImpl<$Res>
    extends _$MiniMaxRequestDTOCopyWithImpl<$Res, _$MiniMaxRequestDTOImpl>
    implements _$$MiniMaxRequestDTOImplCopyWith<$Res> {
  __$$MiniMaxRequestDTOImplCopyWithImpl(
    _$MiniMaxRequestDTOImpl _value,
    $Res Function(_$MiniMaxRequestDTOImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MiniMaxRequestDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? model = null,
    Object? messages = null,
    Object? stream = null,
    Object? temperature = null,
    Object? maxTokens = null,
    Object? reasoningSplit = null,
    Object? thinking = freezed,
  }) {
    return _then(
      _$MiniMaxRequestDTOImpl(
        model: null == model
            ? _value.model
            : model // ignore: cast_nullable_to_non_nullable
                  as String,
        messages: null == messages
            ? _value._messages
            : messages // ignore: cast_nullable_to_non_nullable
                  as List<MiniMaxMessageDTO>,
        stream: null == stream
            ? _value.stream
            : stream // ignore: cast_nullable_to_non_nullable
                  as bool,
        temperature: null == temperature
            ? _value.temperature
            : temperature // ignore: cast_nullable_to_non_nullable
                  as double,
        maxTokens: null == maxTokens
            ? _value.maxTokens
            : maxTokens // ignore: cast_nullable_to_non_nullable
                  as int,
        reasoningSplit: null == reasoningSplit
            ? _value.reasoningSplit
            : reasoningSplit // ignore: cast_nullable_to_non_nullable
                  as bool,
        thinking: freezed == thinking
            ? _value._thinking
            : thinking // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MiniMaxRequestDTOImpl implements _MiniMaxRequestDTO {
  const _$MiniMaxRequestDTOImpl({
    required this.model,
    required final List<MiniMaxMessageDTO> messages,
    this.stream = true,
    this.temperature = 0.7,
    @JsonKey(name: 'max_tokens') this.maxTokens = 1024,
    @JsonKey(name: 'reasoning_split') this.reasoningSplit = false,
    @JsonKey(includeIfNull: false) final Map<String, dynamic>? thinking,
  }) : _messages = messages,
       _thinking = thinking;

  factory _$MiniMaxRequestDTOImpl.fromJson(Map<String, dynamic> json) =>
      _$$MiniMaxRequestDTOImplFromJson(json);

  @override
  final String model;
  final List<MiniMaxMessageDTO> _messages;
  @override
  List<MiniMaxMessageDTO> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  @JsonKey()
  final bool stream;
  @override
  @JsonKey()
  final double temperature;
  @override
  @JsonKey(name: 'max_tokens')
  final int maxTokens;

  /// **Spec 05 (T-07)**: pide al API separar `reasoning_content`
  /// de `content` en el delta. Solo se envia en `true` cuando el
  /// `ModelDefinition.supportsReasoning == true` (resuelto por el
  /// caso de uso y propagado via [GenerateRequest.enableReasoning]).
  @override
  @JsonKey(name: 'reasoning_split')
  final bool reasoningSplit;

  /// **Spec 05 (T-07 / OQ-05)**: habilita thinking adaptativo en
  /// modelos como M3. Se omite del JSON si es null (json_serializable
  /// lo maneja con `includeIfNull: false`). Se envia como
  /// `{"type": "adaptive"}` cuando el provider lo soporta.
  final Map<String, dynamic>? _thinking;

  /// **Spec 05 (T-07 / OQ-05)**: habilita thinking adaptativo en
  /// modelos como M3. Se omite del JSON si es null (json_serializable
  /// lo maneja con `includeIfNull: false`). Se envia como
  /// `{"type": "adaptive"}` cuando el provider lo soporta.
  @override
  @JsonKey(includeIfNull: false)
  Map<String, dynamic>? get thinking {
    final value = _thinking;
    if (value == null) return null;
    if (_thinking is EqualUnmodifiableMapView) return _thinking;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'MiniMaxRequestDTO(model: $model, messages: $messages, stream: $stream, temperature: $temperature, maxTokens: $maxTokens, reasoningSplit: $reasoningSplit, thinking: $thinking)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MiniMaxRequestDTOImpl &&
            (identical(other.model, model) || other.model == model) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.stream, stream) || other.stream == stream) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.maxTokens, maxTokens) ||
                other.maxTokens == maxTokens) &&
            (identical(other.reasoningSplit, reasoningSplit) ||
                other.reasoningSplit == reasoningSplit) &&
            const DeepCollectionEquality().equals(other._thinking, _thinking));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    model,
    const DeepCollectionEquality().hash(_messages),
    stream,
    temperature,
    maxTokens,
    reasoningSplit,
    const DeepCollectionEquality().hash(_thinking),
  );

  /// Create a copy of MiniMaxRequestDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MiniMaxRequestDTOImplCopyWith<_$MiniMaxRequestDTOImpl> get copyWith =>
      __$$MiniMaxRequestDTOImplCopyWithImpl<_$MiniMaxRequestDTOImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MiniMaxRequestDTOImplToJson(this);
  }
}

abstract class _MiniMaxRequestDTO implements MiniMaxRequestDTO {
  const factory _MiniMaxRequestDTO({
    required final String model,
    required final List<MiniMaxMessageDTO> messages,
    final bool stream,
    final double temperature,
    @JsonKey(name: 'max_tokens') final int maxTokens,
    @JsonKey(name: 'reasoning_split') final bool reasoningSplit,
    @JsonKey(includeIfNull: false) final Map<String, dynamic>? thinking,
  }) = _$MiniMaxRequestDTOImpl;

  factory _MiniMaxRequestDTO.fromJson(Map<String, dynamic> json) =
      _$MiniMaxRequestDTOImpl.fromJson;

  @override
  String get model;
  @override
  List<MiniMaxMessageDTO> get messages;
  @override
  bool get stream;
  @override
  double get temperature;
  @override
  @JsonKey(name: 'max_tokens')
  int get maxTokens;

  /// **Spec 05 (T-07)**: pide al API separar `reasoning_content`
  /// de `content` en el delta. Solo se envia en `true` cuando el
  /// `ModelDefinition.supportsReasoning == true` (resuelto por el
  /// caso de uso y propagado via [GenerateRequest.enableReasoning]).
  @override
  @JsonKey(name: 'reasoning_split')
  bool get reasoningSplit;

  /// **Spec 05 (T-07 / OQ-05)**: habilita thinking adaptativo en
  /// modelos como M3. Se omite del JSON si es null (json_serializable
  /// lo maneja con `includeIfNull: false`). Se envia como
  /// `{"type": "adaptive"}` cuando el provider lo soporta.
  @override
  @JsonKey(includeIfNull: false)
  Map<String, dynamic>? get thinking;

  /// Create a copy of MiniMaxRequestDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MiniMaxRequestDTOImplCopyWith<_$MiniMaxRequestDTOImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MiniMaxMessageDTO _$MiniMaxMessageDTOFromJson(Map<String, dynamic> json) {
  return _MiniMaxMessageDTO.fromJson(json);
}

/// @nodoc
mixin _$MiniMaxMessageDTO {
  String get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;

  /// Serializes this MiniMaxMessageDTO to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MiniMaxMessageDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MiniMaxMessageDTOCopyWith<MiniMaxMessageDTO> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MiniMaxMessageDTOCopyWith<$Res> {
  factory $MiniMaxMessageDTOCopyWith(
    MiniMaxMessageDTO value,
    $Res Function(MiniMaxMessageDTO) then,
  ) = _$MiniMaxMessageDTOCopyWithImpl<$Res, MiniMaxMessageDTO>;
  @useResult
  $Res call({String role, String content});
}

/// @nodoc
class _$MiniMaxMessageDTOCopyWithImpl<$Res, $Val extends MiniMaxMessageDTO>
    implements $MiniMaxMessageDTOCopyWith<$Res> {
  _$MiniMaxMessageDTOCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MiniMaxMessageDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? role = null, Object? content = null}) {
    return _then(
      _value.copyWith(
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MiniMaxMessageDTOImplCopyWith<$Res>
    implements $MiniMaxMessageDTOCopyWith<$Res> {
  factory _$$MiniMaxMessageDTOImplCopyWith(
    _$MiniMaxMessageDTOImpl value,
    $Res Function(_$MiniMaxMessageDTOImpl) then,
  ) = __$$MiniMaxMessageDTOImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String role, String content});
}

/// @nodoc
class __$$MiniMaxMessageDTOImplCopyWithImpl<$Res>
    extends _$MiniMaxMessageDTOCopyWithImpl<$Res, _$MiniMaxMessageDTOImpl>
    implements _$$MiniMaxMessageDTOImplCopyWith<$Res> {
  __$$MiniMaxMessageDTOImplCopyWithImpl(
    _$MiniMaxMessageDTOImpl _value,
    $Res Function(_$MiniMaxMessageDTOImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MiniMaxMessageDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? role = null, Object? content = null}) {
    return _then(
      _$MiniMaxMessageDTOImpl(
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MiniMaxMessageDTOImpl implements _MiniMaxMessageDTO {
  const _$MiniMaxMessageDTOImpl({required this.role, required this.content});

  factory _$MiniMaxMessageDTOImpl.fromJson(Map<String, dynamic> json) =>
      _$$MiniMaxMessageDTOImplFromJson(json);

  @override
  final String role;
  @override
  final String content;

  @override
  String toString() {
    return 'MiniMaxMessageDTO(role: $role, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MiniMaxMessageDTOImpl &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, role, content);

  /// Create a copy of MiniMaxMessageDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MiniMaxMessageDTOImplCopyWith<_$MiniMaxMessageDTOImpl> get copyWith =>
      __$$MiniMaxMessageDTOImplCopyWithImpl<_$MiniMaxMessageDTOImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MiniMaxMessageDTOImplToJson(this);
  }
}

abstract class _MiniMaxMessageDTO implements MiniMaxMessageDTO {
  const factory _MiniMaxMessageDTO({
    required final String role,
    required final String content,
  }) = _$MiniMaxMessageDTOImpl;

  factory _MiniMaxMessageDTO.fromJson(Map<String, dynamic> json) =
      _$MiniMaxMessageDTOImpl.fromJson;

  @override
  String get role;
  @override
  String get content;

  /// Create a copy of MiniMaxMessageDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MiniMaxMessageDTOImplCopyWith<_$MiniMaxMessageDTOImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

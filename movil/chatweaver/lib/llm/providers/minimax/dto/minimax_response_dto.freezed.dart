// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'minimax_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MiniMaxResponseDTO _$MiniMaxResponseDTOFromJson(Map<String, dynamic> json) {
  return _MiniMaxResponseDTO.fromJson(json);
}

/// @nodoc
mixin _$MiniMaxResponseDTO {
  String get id => throw _privateConstructorUsedError;
  String? get object => throw _privateConstructorUsedError;
  int? get created => throw _privateConstructorUsedError;
  String? get model => throw _privateConstructorUsedError;
  List<MiniMaxChoiceDTO>? get choices => throw _privateConstructorUsedError;
  MiniMaxUsageDTO? get usage => throw _privateConstructorUsedError;
  @JsonKey(name: 'finish_reason')
  String? get finishReason => throw _privateConstructorUsedError;

  /// Serializes this MiniMaxResponseDTO to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MiniMaxResponseDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MiniMaxResponseDTOCopyWith<MiniMaxResponseDTO> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MiniMaxResponseDTOCopyWith<$Res> {
  factory $MiniMaxResponseDTOCopyWith(
    MiniMaxResponseDTO value,
    $Res Function(MiniMaxResponseDTO) then,
  ) = _$MiniMaxResponseDTOCopyWithImpl<$Res, MiniMaxResponseDTO>;
  @useResult
  $Res call({
    String id,
    String? object,
    int? created,
    String? model,
    List<MiniMaxChoiceDTO>? choices,
    MiniMaxUsageDTO? usage,
    @JsonKey(name: 'finish_reason') String? finishReason,
  });

  $MiniMaxUsageDTOCopyWith<$Res>? get usage;
}

/// @nodoc
class _$MiniMaxResponseDTOCopyWithImpl<$Res, $Val extends MiniMaxResponseDTO>
    implements $MiniMaxResponseDTOCopyWith<$Res> {
  _$MiniMaxResponseDTOCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MiniMaxResponseDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? object = freezed,
    Object? created = freezed,
    Object? model = freezed,
    Object? choices = freezed,
    Object? usage = freezed,
    Object? finishReason = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            object: freezed == object
                ? _value.object
                : object // ignore: cast_nullable_to_non_nullable
                      as String?,
            created: freezed == created
                ? _value.created
                : created // ignore: cast_nullable_to_non_nullable
                      as int?,
            model: freezed == model
                ? _value.model
                : model // ignore: cast_nullable_to_non_nullable
                      as String?,
            choices: freezed == choices
                ? _value.choices
                : choices // ignore: cast_nullable_to_non_nullable
                      as List<MiniMaxChoiceDTO>?,
            usage: freezed == usage
                ? _value.usage
                : usage // ignore: cast_nullable_to_non_nullable
                      as MiniMaxUsageDTO?,
            finishReason: freezed == finishReason
                ? _value.finishReason
                : finishReason // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of MiniMaxResponseDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MiniMaxUsageDTOCopyWith<$Res>? get usage {
    if (_value.usage == null) {
      return null;
    }

    return $MiniMaxUsageDTOCopyWith<$Res>(_value.usage!, (value) {
      return _then(_value.copyWith(usage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MiniMaxResponseDTOImplCopyWith<$Res>
    implements $MiniMaxResponseDTOCopyWith<$Res> {
  factory _$$MiniMaxResponseDTOImplCopyWith(
    _$MiniMaxResponseDTOImpl value,
    $Res Function(_$MiniMaxResponseDTOImpl) then,
  ) = __$$MiniMaxResponseDTOImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? object,
    int? created,
    String? model,
    List<MiniMaxChoiceDTO>? choices,
    MiniMaxUsageDTO? usage,
    @JsonKey(name: 'finish_reason') String? finishReason,
  });

  @override
  $MiniMaxUsageDTOCopyWith<$Res>? get usage;
}

/// @nodoc
class __$$MiniMaxResponseDTOImplCopyWithImpl<$Res>
    extends _$MiniMaxResponseDTOCopyWithImpl<$Res, _$MiniMaxResponseDTOImpl>
    implements _$$MiniMaxResponseDTOImplCopyWith<$Res> {
  __$$MiniMaxResponseDTOImplCopyWithImpl(
    _$MiniMaxResponseDTOImpl _value,
    $Res Function(_$MiniMaxResponseDTOImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MiniMaxResponseDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? object = freezed,
    Object? created = freezed,
    Object? model = freezed,
    Object? choices = freezed,
    Object? usage = freezed,
    Object? finishReason = freezed,
  }) {
    return _then(
      _$MiniMaxResponseDTOImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        object: freezed == object
            ? _value.object
            : object // ignore: cast_nullable_to_non_nullable
                  as String?,
        created: freezed == created
            ? _value.created
            : created // ignore: cast_nullable_to_non_nullable
                  as int?,
        model: freezed == model
            ? _value.model
            : model // ignore: cast_nullable_to_non_nullable
                  as String?,
        choices: freezed == choices
            ? _value._choices
            : choices // ignore: cast_nullable_to_non_nullable
                  as List<MiniMaxChoiceDTO>?,
        usage: freezed == usage
            ? _value.usage
            : usage // ignore: cast_nullable_to_non_nullable
                  as MiniMaxUsageDTO?,
        finishReason: freezed == finishReason
            ? _value.finishReason
            : finishReason // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MiniMaxResponseDTOImpl implements _MiniMaxResponseDTO {
  const _$MiniMaxResponseDTOImpl({
    required this.id,
    this.object,
    this.created,
    this.model,
    final List<MiniMaxChoiceDTO>? choices,
    this.usage,
    @JsonKey(name: 'finish_reason') this.finishReason,
  }) : _choices = choices;

  factory _$MiniMaxResponseDTOImpl.fromJson(Map<String, dynamic> json) =>
      _$$MiniMaxResponseDTOImplFromJson(json);

  @override
  final String id;
  @override
  final String? object;
  @override
  final int? created;
  @override
  final String? model;
  final List<MiniMaxChoiceDTO>? _choices;
  @override
  List<MiniMaxChoiceDTO>? get choices {
    final value = _choices;
    if (value == null) return null;
    if (_choices is EqualUnmodifiableListView) return _choices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final MiniMaxUsageDTO? usage;
  @override
  @JsonKey(name: 'finish_reason')
  final String? finishReason;

  @override
  String toString() {
    return 'MiniMaxResponseDTO(id: $id, object: $object, created: $created, model: $model, choices: $choices, usage: $usage, finishReason: $finishReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MiniMaxResponseDTOImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.object, object) || other.object == object) &&
            (identical(other.created, created) || other.created == created) &&
            (identical(other.model, model) || other.model == model) &&
            const DeepCollectionEquality().equals(other._choices, _choices) &&
            (identical(other.usage, usage) || other.usage == usage) &&
            (identical(other.finishReason, finishReason) ||
                other.finishReason == finishReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    object,
    created,
    model,
    const DeepCollectionEquality().hash(_choices),
    usage,
    finishReason,
  );

  /// Create a copy of MiniMaxResponseDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MiniMaxResponseDTOImplCopyWith<_$MiniMaxResponseDTOImpl> get copyWith =>
      __$$MiniMaxResponseDTOImplCopyWithImpl<_$MiniMaxResponseDTOImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MiniMaxResponseDTOImplToJson(this);
  }
}

abstract class _MiniMaxResponseDTO implements MiniMaxResponseDTO {
  const factory _MiniMaxResponseDTO({
    required final String id,
    final String? object,
    final int? created,
    final String? model,
    final List<MiniMaxChoiceDTO>? choices,
    final MiniMaxUsageDTO? usage,
    @JsonKey(name: 'finish_reason') final String? finishReason,
  }) = _$MiniMaxResponseDTOImpl;

  factory _MiniMaxResponseDTO.fromJson(Map<String, dynamic> json) =
      _$MiniMaxResponseDTOImpl.fromJson;

  @override
  String get id;
  @override
  String? get object;
  @override
  int? get created;
  @override
  String? get model;
  @override
  List<MiniMaxChoiceDTO>? get choices;
  @override
  MiniMaxUsageDTO? get usage;
  @override
  @JsonKey(name: 'finish_reason')
  String? get finishReason;

  /// Create a copy of MiniMaxResponseDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MiniMaxResponseDTOImplCopyWith<_$MiniMaxResponseDTOImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MiniMaxChoiceDTO _$MiniMaxChoiceDTOFromJson(Map<String, dynamic> json) {
  return _MiniMaxChoiceDTO.fromJson(json);
}

/// @nodoc
mixin _$MiniMaxChoiceDTO {
  MiniMaxDeltaDTO? get delta => throw _privateConstructorUsedError;
  @JsonKey(name: 'finish_reason')
  String? get finishReason => throw _privateConstructorUsedError;
  int? get index => throw _privateConstructorUsedError;

  /// Serializes this MiniMaxChoiceDTO to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MiniMaxChoiceDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MiniMaxChoiceDTOCopyWith<MiniMaxChoiceDTO> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MiniMaxChoiceDTOCopyWith<$Res> {
  factory $MiniMaxChoiceDTOCopyWith(
    MiniMaxChoiceDTO value,
    $Res Function(MiniMaxChoiceDTO) then,
  ) = _$MiniMaxChoiceDTOCopyWithImpl<$Res, MiniMaxChoiceDTO>;
  @useResult
  $Res call({
    MiniMaxDeltaDTO? delta,
    @JsonKey(name: 'finish_reason') String? finishReason,
    int? index,
  });

  $MiniMaxDeltaDTOCopyWith<$Res>? get delta;
}

/// @nodoc
class _$MiniMaxChoiceDTOCopyWithImpl<$Res, $Val extends MiniMaxChoiceDTO>
    implements $MiniMaxChoiceDTOCopyWith<$Res> {
  _$MiniMaxChoiceDTOCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MiniMaxChoiceDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? delta = freezed,
    Object? finishReason = freezed,
    Object? index = freezed,
  }) {
    return _then(
      _value.copyWith(
            delta: freezed == delta
                ? _value.delta
                : delta // ignore: cast_nullable_to_non_nullable
                      as MiniMaxDeltaDTO?,
            finishReason: freezed == finishReason
                ? _value.finishReason
                : finishReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            index: freezed == index
                ? _value.index
                : index // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }

  /// Create a copy of MiniMaxChoiceDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MiniMaxDeltaDTOCopyWith<$Res>? get delta {
    if (_value.delta == null) {
      return null;
    }

    return $MiniMaxDeltaDTOCopyWith<$Res>(_value.delta!, (value) {
      return _then(_value.copyWith(delta: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MiniMaxChoiceDTOImplCopyWith<$Res>
    implements $MiniMaxChoiceDTOCopyWith<$Res> {
  factory _$$MiniMaxChoiceDTOImplCopyWith(
    _$MiniMaxChoiceDTOImpl value,
    $Res Function(_$MiniMaxChoiceDTOImpl) then,
  ) = __$$MiniMaxChoiceDTOImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    MiniMaxDeltaDTO? delta,
    @JsonKey(name: 'finish_reason') String? finishReason,
    int? index,
  });

  @override
  $MiniMaxDeltaDTOCopyWith<$Res>? get delta;
}

/// @nodoc
class __$$MiniMaxChoiceDTOImplCopyWithImpl<$Res>
    extends _$MiniMaxChoiceDTOCopyWithImpl<$Res, _$MiniMaxChoiceDTOImpl>
    implements _$$MiniMaxChoiceDTOImplCopyWith<$Res> {
  __$$MiniMaxChoiceDTOImplCopyWithImpl(
    _$MiniMaxChoiceDTOImpl _value,
    $Res Function(_$MiniMaxChoiceDTOImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MiniMaxChoiceDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? delta = freezed,
    Object? finishReason = freezed,
    Object? index = freezed,
  }) {
    return _then(
      _$MiniMaxChoiceDTOImpl(
        delta: freezed == delta
            ? _value.delta
            : delta // ignore: cast_nullable_to_non_nullable
                  as MiniMaxDeltaDTO?,
        finishReason: freezed == finishReason
            ? _value.finishReason
            : finishReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        index: freezed == index
            ? _value.index
            : index // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MiniMaxChoiceDTOImpl implements _MiniMaxChoiceDTO {
  const _$MiniMaxChoiceDTOImpl({
    this.delta,
    @JsonKey(name: 'finish_reason') this.finishReason,
    this.index,
  });

  factory _$MiniMaxChoiceDTOImpl.fromJson(Map<String, dynamic> json) =>
      _$$MiniMaxChoiceDTOImplFromJson(json);

  @override
  final MiniMaxDeltaDTO? delta;
  @override
  @JsonKey(name: 'finish_reason')
  final String? finishReason;
  @override
  final int? index;

  @override
  String toString() {
    return 'MiniMaxChoiceDTO(delta: $delta, finishReason: $finishReason, index: $index)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MiniMaxChoiceDTOImpl &&
            (identical(other.delta, delta) || other.delta == delta) &&
            (identical(other.finishReason, finishReason) ||
                other.finishReason == finishReason) &&
            (identical(other.index, index) || other.index == index));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, delta, finishReason, index);

  /// Create a copy of MiniMaxChoiceDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MiniMaxChoiceDTOImplCopyWith<_$MiniMaxChoiceDTOImpl> get copyWith =>
      __$$MiniMaxChoiceDTOImplCopyWithImpl<_$MiniMaxChoiceDTOImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MiniMaxChoiceDTOImplToJson(this);
  }
}

abstract class _MiniMaxChoiceDTO implements MiniMaxChoiceDTO {
  const factory _MiniMaxChoiceDTO({
    final MiniMaxDeltaDTO? delta,
    @JsonKey(name: 'finish_reason') final String? finishReason,
    final int? index,
  }) = _$MiniMaxChoiceDTOImpl;

  factory _MiniMaxChoiceDTO.fromJson(Map<String, dynamic> json) =
      _$MiniMaxChoiceDTOImpl.fromJson;

  @override
  MiniMaxDeltaDTO? get delta;
  @override
  @JsonKey(name: 'finish_reason')
  String? get finishReason;
  @override
  int? get index;

  /// Create a copy of MiniMaxChoiceDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MiniMaxChoiceDTOImplCopyWith<_$MiniMaxChoiceDTOImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MiniMaxDeltaDTO _$MiniMaxDeltaDTOFromJson(Map<String, dynamic> json) {
  return _MiniMaxDeltaDTO.fromJson(json);
}

/// @nodoc
mixin _$MiniMaxDeltaDTO {
  String? get content => throw _privateConstructorUsedError;
  String? get role => throw _privateConstructorUsedError;

  /// Serializes this MiniMaxDeltaDTO to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MiniMaxDeltaDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MiniMaxDeltaDTOCopyWith<MiniMaxDeltaDTO> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MiniMaxDeltaDTOCopyWith<$Res> {
  factory $MiniMaxDeltaDTOCopyWith(
    MiniMaxDeltaDTO value,
    $Res Function(MiniMaxDeltaDTO) then,
  ) = _$MiniMaxDeltaDTOCopyWithImpl<$Res, MiniMaxDeltaDTO>;
  @useResult
  $Res call({String? content, String? role});
}

/// @nodoc
class _$MiniMaxDeltaDTOCopyWithImpl<$Res, $Val extends MiniMaxDeltaDTO>
    implements $MiniMaxDeltaDTOCopyWith<$Res> {
  _$MiniMaxDeltaDTOCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MiniMaxDeltaDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? content = freezed, Object? role = freezed}) {
    return _then(
      _value.copyWith(
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
            role: freezed == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MiniMaxDeltaDTOImplCopyWith<$Res>
    implements $MiniMaxDeltaDTOCopyWith<$Res> {
  factory _$$MiniMaxDeltaDTOImplCopyWith(
    _$MiniMaxDeltaDTOImpl value,
    $Res Function(_$MiniMaxDeltaDTOImpl) then,
  ) = __$$MiniMaxDeltaDTOImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? content, String? role});
}

/// @nodoc
class __$$MiniMaxDeltaDTOImplCopyWithImpl<$Res>
    extends _$MiniMaxDeltaDTOCopyWithImpl<$Res, _$MiniMaxDeltaDTOImpl>
    implements _$$MiniMaxDeltaDTOImplCopyWith<$Res> {
  __$$MiniMaxDeltaDTOImplCopyWithImpl(
    _$MiniMaxDeltaDTOImpl _value,
    $Res Function(_$MiniMaxDeltaDTOImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MiniMaxDeltaDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? content = freezed, Object? role = freezed}) {
    return _then(
      _$MiniMaxDeltaDTOImpl(
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        role: freezed == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MiniMaxDeltaDTOImpl implements _MiniMaxDeltaDTO {
  const _$MiniMaxDeltaDTOImpl({this.content, this.role});

  factory _$MiniMaxDeltaDTOImpl.fromJson(Map<String, dynamic> json) =>
      _$$MiniMaxDeltaDTOImplFromJson(json);

  @override
  final String? content;
  @override
  final String? role;

  @override
  String toString() {
    return 'MiniMaxDeltaDTO(content: $content, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MiniMaxDeltaDTOImpl &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, content, role);

  /// Create a copy of MiniMaxDeltaDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MiniMaxDeltaDTOImplCopyWith<_$MiniMaxDeltaDTOImpl> get copyWith =>
      __$$MiniMaxDeltaDTOImplCopyWithImpl<_$MiniMaxDeltaDTOImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MiniMaxDeltaDTOImplToJson(this);
  }
}

abstract class _MiniMaxDeltaDTO implements MiniMaxDeltaDTO {
  const factory _MiniMaxDeltaDTO({final String? content, final String? role}) =
      _$MiniMaxDeltaDTOImpl;

  factory _MiniMaxDeltaDTO.fromJson(Map<String, dynamic> json) =
      _$MiniMaxDeltaDTOImpl.fromJson;

  @override
  String? get content;
  @override
  String? get role;

  /// Create a copy of MiniMaxDeltaDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MiniMaxDeltaDTOImplCopyWith<_$MiniMaxDeltaDTOImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MiniMaxUsageDTO _$MiniMaxUsageDTOFromJson(Map<String, dynamic> json) {
  return _MiniMaxUsageDTO.fromJson(json);
}

/// @nodoc
mixin _$MiniMaxUsageDTO {
  @JsonKey(name: 'prompt_tokens')
  int? get promptTokens => throw _privateConstructorUsedError;
  @JsonKey(name: 'completion_tokens')
  int? get completionTokens => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_tokens')
  int? get totalTokens => throw _privateConstructorUsedError;

  /// Serializes this MiniMaxUsageDTO to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MiniMaxUsageDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MiniMaxUsageDTOCopyWith<MiniMaxUsageDTO> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MiniMaxUsageDTOCopyWith<$Res> {
  factory $MiniMaxUsageDTOCopyWith(
    MiniMaxUsageDTO value,
    $Res Function(MiniMaxUsageDTO) then,
  ) = _$MiniMaxUsageDTOCopyWithImpl<$Res, MiniMaxUsageDTO>;
  @useResult
  $Res call({
    @JsonKey(name: 'prompt_tokens') int? promptTokens,
    @JsonKey(name: 'completion_tokens') int? completionTokens,
    @JsonKey(name: 'total_tokens') int? totalTokens,
  });
}

/// @nodoc
class _$MiniMaxUsageDTOCopyWithImpl<$Res, $Val extends MiniMaxUsageDTO>
    implements $MiniMaxUsageDTOCopyWith<$Res> {
  _$MiniMaxUsageDTOCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MiniMaxUsageDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? promptTokens = freezed,
    Object? completionTokens = freezed,
    Object? totalTokens = freezed,
  }) {
    return _then(
      _value.copyWith(
            promptTokens: freezed == promptTokens
                ? _value.promptTokens
                : promptTokens // ignore: cast_nullable_to_non_nullable
                      as int?,
            completionTokens: freezed == completionTokens
                ? _value.completionTokens
                : completionTokens // ignore: cast_nullable_to_non_nullable
                      as int?,
            totalTokens: freezed == totalTokens
                ? _value.totalTokens
                : totalTokens // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MiniMaxUsageDTOImplCopyWith<$Res>
    implements $MiniMaxUsageDTOCopyWith<$Res> {
  factory _$$MiniMaxUsageDTOImplCopyWith(
    _$MiniMaxUsageDTOImpl value,
    $Res Function(_$MiniMaxUsageDTOImpl) then,
  ) = __$$MiniMaxUsageDTOImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'prompt_tokens') int? promptTokens,
    @JsonKey(name: 'completion_tokens') int? completionTokens,
    @JsonKey(name: 'total_tokens') int? totalTokens,
  });
}

/// @nodoc
class __$$MiniMaxUsageDTOImplCopyWithImpl<$Res>
    extends _$MiniMaxUsageDTOCopyWithImpl<$Res, _$MiniMaxUsageDTOImpl>
    implements _$$MiniMaxUsageDTOImplCopyWith<$Res> {
  __$$MiniMaxUsageDTOImplCopyWithImpl(
    _$MiniMaxUsageDTOImpl _value,
    $Res Function(_$MiniMaxUsageDTOImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MiniMaxUsageDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? promptTokens = freezed,
    Object? completionTokens = freezed,
    Object? totalTokens = freezed,
  }) {
    return _then(
      _$MiniMaxUsageDTOImpl(
        promptTokens: freezed == promptTokens
            ? _value.promptTokens
            : promptTokens // ignore: cast_nullable_to_non_nullable
                  as int?,
        completionTokens: freezed == completionTokens
            ? _value.completionTokens
            : completionTokens // ignore: cast_nullable_to_non_nullable
                  as int?,
        totalTokens: freezed == totalTokens
            ? _value.totalTokens
            : totalTokens // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MiniMaxUsageDTOImpl implements _MiniMaxUsageDTO {
  const _$MiniMaxUsageDTOImpl({
    @JsonKey(name: 'prompt_tokens') this.promptTokens,
    @JsonKey(name: 'completion_tokens') this.completionTokens,
    @JsonKey(name: 'total_tokens') this.totalTokens,
  });

  factory _$MiniMaxUsageDTOImpl.fromJson(Map<String, dynamic> json) =>
      _$$MiniMaxUsageDTOImplFromJson(json);

  @override
  @JsonKey(name: 'prompt_tokens')
  final int? promptTokens;
  @override
  @JsonKey(name: 'completion_tokens')
  final int? completionTokens;
  @override
  @JsonKey(name: 'total_tokens')
  final int? totalTokens;

  @override
  String toString() {
    return 'MiniMaxUsageDTO(promptTokens: $promptTokens, completionTokens: $completionTokens, totalTokens: $totalTokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MiniMaxUsageDTOImpl &&
            (identical(other.promptTokens, promptTokens) ||
                other.promptTokens == promptTokens) &&
            (identical(other.completionTokens, completionTokens) ||
                other.completionTokens == completionTokens) &&
            (identical(other.totalTokens, totalTokens) ||
                other.totalTokens == totalTokens));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, promptTokens, completionTokens, totalTokens);

  /// Create a copy of MiniMaxUsageDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MiniMaxUsageDTOImplCopyWith<_$MiniMaxUsageDTOImpl> get copyWith =>
      __$$MiniMaxUsageDTOImplCopyWithImpl<_$MiniMaxUsageDTOImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MiniMaxUsageDTOImplToJson(this);
  }
}

abstract class _MiniMaxUsageDTO implements MiniMaxUsageDTO {
  const factory _MiniMaxUsageDTO({
    @JsonKey(name: 'prompt_tokens') final int? promptTokens,
    @JsonKey(name: 'completion_tokens') final int? completionTokens,
    @JsonKey(name: 'total_tokens') final int? totalTokens,
  }) = _$MiniMaxUsageDTOImpl;

  factory _MiniMaxUsageDTO.fromJson(Map<String, dynamic> json) =
      _$MiniMaxUsageDTOImpl.fromJson;

  @override
  @JsonKey(name: 'prompt_tokens')
  int? get promptTokens;
  @override
  @JsonKey(name: 'completion_tokens')
  int? get completionTokens;
  @override
  @JsonKey(name: 'total_tokens')
  int? get totalTokens;

  /// Create a copy of MiniMaxUsageDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MiniMaxUsageDTOImplCopyWith<_$MiniMaxUsageDTOImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

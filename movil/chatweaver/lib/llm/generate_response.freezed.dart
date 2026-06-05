// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generate_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GenerateResponseChunk {
  String? get textDelta => throw _privateConstructorUsedError;
  LlmUsage? get usage => throw _privateConstructorUsedError;
  String? get finishReason => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of GenerateResponseChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GenerateResponseChunkCopyWith<GenerateResponseChunk> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GenerateResponseChunkCopyWith<$Res> {
  factory $GenerateResponseChunkCopyWith(
    GenerateResponseChunk value,
    $Res Function(GenerateResponseChunk) then,
  ) = _$GenerateResponseChunkCopyWithImpl<$Res, GenerateResponseChunk>;
  @useResult
  $Res call({
    String? textDelta,
    LlmUsage? usage,
    String? finishReason,
    String? errorMessage,
  });

  $LlmUsageCopyWith<$Res>? get usage;
}

/// @nodoc
class _$GenerateResponseChunkCopyWithImpl<
  $Res,
  $Val extends GenerateResponseChunk
>
    implements $GenerateResponseChunkCopyWith<$Res> {
  _$GenerateResponseChunkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GenerateResponseChunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? textDelta = freezed,
    Object? usage = freezed,
    Object? finishReason = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            textDelta: freezed == textDelta
                ? _value.textDelta
                : textDelta // ignore: cast_nullable_to_non_nullable
                      as String?,
            usage: freezed == usage
                ? _value.usage
                : usage // ignore: cast_nullable_to_non_nullable
                      as LlmUsage?,
            finishReason: freezed == finishReason
                ? _value.finishReason
                : finishReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of GenerateResponseChunk
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LlmUsageCopyWith<$Res>? get usage {
    if (_value.usage == null) {
      return null;
    }

    return $LlmUsageCopyWith<$Res>(_value.usage!, (value) {
      return _then(_value.copyWith(usage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GenerateResponseChunkImplCopyWith<$Res>
    implements $GenerateResponseChunkCopyWith<$Res> {
  factory _$$GenerateResponseChunkImplCopyWith(
    _$GenerateResponseChunkImpl value,
    $Res Function(_$GenerateResponseChunkImpl) then,
  ) = __$$GenerateResponseChunkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? textDelta,
    LlmUsage? usage,
    String? finishReason,
    String? errorMessage,
  });

  @override
  $LlmUsageCopyWith<$Res>? get usage;
}

/// @nodoc
class __$$GenerateResponseChunkImplCopyWithImpl<$Res>
    extends
        _$GenerateResponseChunkCopyWithImpl<$Res, _$GenerateResponseChunkImpl>
    implements _$$GenerateResponseChunkImplCopyWith<$Res> {
  __$$GenerateResponseChunkImplCopyWithImpl(
    _$GenerateResponseChunkImpl _value,
    $Res Function(_$GenerateResponseChunkImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GenerateResponseChunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? textDelta = freezed,
    Object? usage = freezed,
    Object? finishReason = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$GenerateResponseChunkImpl(
        textDelta: freezed == textDelta
            ? _value.textDelta
            : textDelta // ignore: cast_nullable_to_non_nullable
                  as String?,
        usage: freezed == usage
            ? _value.usage
            : usage // ignore: cast_nullable_to_non_nullable
                  as LlmUsage?,
        finishReason: freezed == finishReason
            ? _value.finishReason
            : finishReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$GenerateResponseChunkImpl implements _GenerateResponseChunk {
  const _$GenerateResponseChunkImpl({
    this.textDelta,
    this.usage,
    this.finishReason,
    this.errorMessage,
  });

  @override
  final String? textDelta;
  @override
  final LlmUsage? usage;
  @override
  final String? finishReason;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'GenerateResponseChunk(textDelta: $textDelta, usage: $usage, finishReason: $finishReason, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenerateResponseChunkImpl &&
            (identical(other.textDelta, textDelta) ||
                other.textDelta == textDelta) &&
            (identical(other.usage, usage) || other.usage == usage) &&
            (identical(other.finishReason, finishReason) ||
                other.finishReason == finishReason) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, textDelta, usage, finishReason, errorMessage);

  /// Create a copy of GenerateResponseChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GenerateResponseChunkImplCopyWith<_$GenerateResponseChunkImpl>
  get copyWith =>
      __$$GenerateResponseChunkImplCopyWithImpl<_$GenerateResponseChunkImpl>(
        this,
        _$identity,
      );
}

abstract class _GenerateResponseChunk implements GenerateResponseChunk {
  const factory _GenerateResponseChunk({
    final String? textDelta,
    final LlmUsage? usage,
    final String? finishReason,
    final String? errorMessage,
  }) = _$GenerateResponseChunkImpl;

  @override
  String? get textDelta;
  @override
  LlmUsage? get usage;
  @override
  String? get finishReason;
  @override
  String? get errorMessage;

  /// Create a copy of GenerateResponseChunk
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GenerateResponseChunkImplCopyWith<_$GenerateResponseChunkImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LlmUsage {
  int get inputTokens => throw _privateConstructorUsedError;
  int get outputTokens => throw _privateConstructorUsedError;

  /// Create a copy of LlmUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LlmUsageCopyWith<LlmUsage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LlmUsageCopyWith<$Res> {
  factory $LlmUsageCopyWith(LlmUsage value, $Res Function(LlmUsage) then) =
      _$LlmUsageCopyWithImpl<$Res, LlmUsage>;
  @useResult
  $Res call({int inputTokens, int outputTokens});
}

/// @nodoc
class _$LlmUsageCopyWithImpl<$Res, $Val extends LlmUsage>
    implements $LlmUsageCopyWith<$Res> {
  _$LlmUsageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LlmUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? inputTokens = null, Object? outputTokens = null}) {
    return _then(
      _value.copyWith(
            inputTokens: null == inputTokens
                ? _value.inputTokens
                : inputTokens // ignore: cast_nullable_to_non_nullable
                      as int,
            outputTokens: null == outputTokens
                ? _value.outputTokens
                : outputTokens // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LlmUsageImplCopyWith<$Res>
    implements $LlmUsageCopyWith<$Res> {
  factory _$$LlmUsageImplCopyWith(
    _$LlmUsageImpl value,
    $Res Function(_$LlmUsageImpl) then,
  ) = __$$LlmUsageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int inputTokens, int outputTokens});
}

/// @nodoc
class __$$LlmUsageImplCopyWithImpl<$Res>
    extends _$LlmUsageCopyWithImpl<$Res, _$LlmUsageImpl>
    implements _$$LlmUsageImplCopyWith<$Res> {
  __$$LlmUsageImplCopyWithImpl(
    _$LlmUsageImpl _value,
    $Res Function(_$LlmUsageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LlmUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? inputTokens = null, Object? outputTokens = null}) {
    return _then(
      _$LlmUsageImpl(
        inputTokens: null == inputTokens
            ? _value.inputTokens
            : inputTokens // ignore: cast_nullable_to_non_nullable
                  as int,
        outputTokens: null == outputTokens
            ? _value.outputTokens
            : outputTokens // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$LlmUsageImpl extends _LlmUsage {
  const _$LlmUsageImpl({required this.inputTokens, required this.outputTokens})
    : super._();

  @override
  final int inputTokens;
  @override
  final int outputTokens;

  @override
  String toString() {
    return 'LlmUsage(inputTokens: $inputTokens, outputTokens: $outputTokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LlmUsageImpl &&
            (identical(other.inputTokens, inputTokens) ||
                other.inputTokens == inputTokens) &&
            (identical(other.outputTokens, outputTokens) ||
                other.outputTokens == outputTokens));
  }

  @override
  int get hashCode => Object.hash(runtimeType, inputTokens, outputTokens);

  /// Create a copy of LlmUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LlmUsageImplCopyWith<_$LlmUsageImpl> get copyWith =>
      __$$LlmUsageImplCopyWithImpl<_$LlmUsageImpl>(this, _$identity);
}

abstract class _LlmUsage extends LlmUsage {
  const factory _LlmUsage({
    required final int inputTokens,
    required final int outputTokens,
  }) = _$LlmUsageImpl;
  const _LlmUsage._() : super._();

  @override
  int get inputTokens;
  @override
  int get outputTokens;

  /// Create a copy of LlmUsage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LlmUsageImplCopyWith<_$LlmUsageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

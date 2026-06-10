// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_usage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TokenUsage {
  int get inputTokens => throw _privateConstructorUsedError;
  int get outputTokens => throw _privateConstructorUsedError;
  int get thinkingTokens => throw _privateConstructorUsedError;

  /// Create a copy of TokenUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenUsageCopyWith<TokenUsage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenUsageCopyWith<$Res> {
  factory $TokenUsageCopyWith(
    TokenUsage value,
    $Res Function(TokenUsage) then,
  ) = _$TokenUsageCopyWithImpl<$Res, TokenUsage>;
  @useResult
  $Res call({int inputTokens, int outputTokens, int thinkingTokens});
}

/// @nodoc
class _$TokenUsageCopyWithImpl<$Res, $Val extends TokenUsage>
    implements $TokenUsageCopyWith<$Res> {
  _$TokenUsageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inputTokens = null,
    Object? outputTokens = null,
    Object? thinkingTokens = null,
  }) {
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
            thinkingTokens: null == thinkingTokens
                ? _value.thinkingTokens
                : thinkingTokens // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TokenUsageImplCopyWith<$Res>
    implements $TokenUsageCopyWith<$Res> {
  factory _$$TokenUsageImplCopyWith(
    _$TokenUsageImpl value,
    $Res Function(_$TokenUsageImpl) then,
  ) = __$$TokenUsageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int inputTokens, int outputTokens, int thinkingTokens});
}

/// @nodoc
class __$$TokenUsageImplCopyWithImpl<$Res>
    extends _$TokenUsageCopyWithImpl<$Res, _$TokenUsageImpl>
    implements _$$TokenUsageImplCopyWith<$Res> {
  __$$TokenUsageImplCopyWithImpl(
    _$TokenUsageImpl _value,
    $Res Function(_$TokenUsageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TokenUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inputTokens = null,
    Object? outputTokens = null,
    Object? thinkingTokens = null,
  }) {
    return _then(
      _$TokenUsageImpl(
        inputTokens: null == inputTokens
            ? _value.inputTokens
            : inputTokens // ignore: cast_nullable_to_non_nullable
                  as int,
        outputTokens: null == outputTokens
            ? _value.outputTokens
            : outputTokens // ignore: cast_nullable_to_non_nullable
                  as int,
        thinkingTokens: null == thinkingTokens
            ? _value.thinkingTokens
            : thinkingTokens // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$TokenUsageImpl extends _TokenUsage {
  const _$TokenUsageImpl({
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.thinkingTokens = 0,
  }) : super._();

  @override
  @JsonKey()
  final int inputTokens;
  @override
  @JsonKey()
  final int outputTokens;
  @override
  @JsonKey()
  final int thinkingTokens;

  @override
  String toString() {
    return 'TokenUsage(inputTokens: $inputTokens, outputTokens: $outputTokens, thinkingTokens: $thinkingTokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenUsageImpl &&
            (identical(other.inputTokens, inputTokens) ||
                other.inputTokens == inputTokens) &&
            (identical(other.outputTokens, outputTokens) ||
                other.outputTokens == outputTokens) &&
            (identical(other.thinkingTokens, thinkingTokens) ||
                other.thinkingTokens == thinkingTokens));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, inputTokens, outputTokens, thinkingTokens);

  /// Create a copy of TokenUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenUsageImplCopyWith<_$TokenUsageImpl> get copyWith =>
      __$$TokenUsageImplCopyWithImpl<_$TokenUsageImpl>(this, _$identity);
}

abstract class _TokenUsage extends TokenUsage {
  const factory _TokenUsage({
    final int inputTokens,
    final int outputTokens,
    final int thinkingTokens,
  }) = _$TokenUsageImpl;
  const _TokenUsage._() : super._();

  @override
  int get inputTokens;
  @override
  int get outputTokens;
  @override
  int get thinkingTokens;

  /// Create a copy of TokenUsage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenUsageImplCopyWith<_$TokenUsageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

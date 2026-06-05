// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generate_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GenerateRequest {
  List<ChatMessage> get messages => throw _privateConstructorUsedError;
  String? get systemPrompt => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  int get maxOutputTokens => throw _privateConstructorUsedError;

  /// Create a copy of GenerateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GenerateRequestCopyWith<GenerateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GenerateRequestCopyWith<$Res> {
  factory $GenerateRequestCopyWith(
    GenerateRequest value,
    $Res Function(GenerateRequest) then,
  ) = _$GenerateRequestCopyWithImpl<$Res, GenerateRequest>;
  @useResult
  $Res call({
    List<ChatMessage> messages,
    String? systemPrompt,
    double temperature,
    int maxOutputTokens,
  });
}

/// @nodoc
class _$GenerateRequestCopyWithImpl<$Res, $Val extends GenerateRequest>
    implements $GenerateRequestCopyWith<$Res> {
  _$GenerateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GenerateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? systemPrompt = freezed,
    Object? temperature = null,
    Object? maxOutputTokens = null,
  }) {
    return _then(
      _value.copyWith(
            messages: null == messages
                ? _value.messages
                : messages // ignore: cast_nullable_to_non_nullable
                      as List<ChatMessage>,
            systemPrompt: freezed == systemPrompt
                ? _value.systemPrompt
                : systemPrompt // ignore: cast_nullable_to_non_nullable
                      as String?,
            temperature: null == temperature
                ? _value.temperature
                : temperature // ignore: cast_nullable_to_non_nullable
                      as double,
            maxOutputTokens: null == maxOutputTokens
                ? _value.maxOutputTokens
                : maxOutputTokens // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GenerateRequestImplCopyWith<$Res>
    implements $GenerateRequestCopyWith<$Res> {
  factory _$$GenerateRequestImplCopyWith(
    _$GenerateRequestImpl value,
    $Res Function(_$GenerateRequestImpl) then,
  ) = __$$GenerateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<ChatMessage> messages,
    String? systemPrompt,
    double temperature,
    int maxOutputTokens,
  });
}

/// @nodoc
class __$$GenerateRequestImplCopyWithImpl<$Res>
    extends _$GenerateRequestCopyWithImpl<$Res, _$GenerateRequestImpl>
    implements _$$GenerateRequestImplCopyWith<$Res> {
  __$$GenerateRequestImplCopyWithImpl(
    _$GenerateRequestImpl _value,
    $Res Function(_$GenerateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GenerateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? systemPrompt = freezed,
    Object? temperature = null,
    Object? maxOutputTokens = null,
  }) {
    return _then(
      _$GenerateRequestImpl(
        messages: null == messages
            ? _value._messages
            : messages // ignore: cast_nullable_to_non_nullable
                  as List<ChatMessage>,
        systemPrompt: freezed == systemPrompt
            ? _value.systemPrompt
            : systemPrompt // ignore: cast_nullable_to_non_nullable
                  as String?,
        temperature: null == temperature
            ? _value.temperature
            : temperature // ignore: cast_nullable_to_non_nullable
                  as double,
        maxOutputTokens: null == maxOutputTokens
            ? _value.maxOutputTokens
            : maxOutputTokens // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$GenerateRequestImpl implements _GenerateRequest {
  const _$GenerateRequestImpl({
    required final List<ChatMessage> messages,
    this.systemPrompt,
    this.temperature = 0.7,
    this.maxOutputTokens = 1024,
  }) : _messages = messages;

  final List<ChatMessage> _messages;
  @override
  List<ChatMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final String? systemPrompt;
  @override
  @JsonKey()
  final double temperature;
  @override
  @JsonKey()
  final int maxOutputTokens;

  @override
  String toString() {
    return 'GenerateRequest(messages: $messages, systemPrompt: $systemPrompt, temperature: $temperature, maxOutputTokens: $maxOutputTokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenerateRequestImpl &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.systemPrompt, systemPrompt) ||
                other.systemPrompt == systemPrompt) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.maxOutputTokens, maxOutputTokens) ||
                other.maxOutputTokens == maxOutputTokens));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_messages),
    systemPrompt,
    temperature,
    maxOutputTokens,
  );

  /// Create a copy of GenerateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GenerateRequestImplCopyWith<_$GenerateRequestImpl> get copyWith =>
      __$$GenerateRequestImplCopyWithImpl<_$GenerateRequestImpl>(
        this,
        _$identity,
      );
}

abstract class _GenerateRequest implements GenerateRequest {
  const factory _GenerateRequest({
    required final List<ChatMessage> messages,
    final String? systemPrompt,
    final double temperature,
    final int maxOutputTokens,
  }) = _$GenerateRequestImpl;

  @override
  List<ChatMessage> get messages;
  @override
  String? get systemPrompt;
  @override
  double get temperature;
  @override
  int get maxOutputTokens;

  /// Create a copy of GenerateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GenerateRequestImplCopyWith<_$GenerateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

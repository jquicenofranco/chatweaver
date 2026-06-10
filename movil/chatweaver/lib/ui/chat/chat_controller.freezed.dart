// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ChatState {
  List<Message> get messages => throw _privateConstructorUsedError;
  bool get isStreaming => throw _privateConstructorUsedError;
  TokenUsage get sessionUsage => throw _privateConstructorUsedError;
  Map<String, String> get reasoningByMessageId =>
      throw _privateConstructorUsedError;
  String get draft => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatStateCopyWith<ChatState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatStateCopyWith<$Res> {
  factory $ChatStateCopyWith(ChatState value, $Res Function(ChatState) then) =
      _$ChatStateCopyWithImpl<$Res, ChatState>;
  @useResult
  $Res call({
    List<Message> messages,
    bool isStreaming,
    TokenUsage sessionUsage,
    Map<String, String> reasoningByMessageId,
    String draft,
    String? error,
  });

  $TokenUsageCopyWith<$Res> get sessionUsage;
}

/// @nodoc
class _$ChatStateCopyWithImpl<$Res, $Val extends ChatState>
    implements $ChatStateCopyWith<$Res> {
  _$ChatStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? isStreaming = null,
    Object? sessionUsage = null,
    Object? reasoningByMessageId = null,
    Object? draft = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            messages: null == messages
                ? _value.messages
                : messages // ignore: cast_nullable_to_non_nullable
                      as List<Message>,
            isStreaming: null == isStreaming
                ? _value.isStreaming
                : isStreaming // ignore: cast_nullable_to_non_nullable
                      as bool,
            sessionUsage: null == sessionUsage
                ? _value.sessionUsage
                : sessionUsage // ignore: cast_nullable_to_non_nullable
                      as TokenUsage,
            reasoningByMessageId: null == reasoningByMessageId
                ? _value.reasoningByMessageId
                : reasoningByMessageId // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            draft: null == draft
                ? _value.draft
                : draft // ignore: cast_nullable_to_non_nullable
                      as String,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TokenUsageCopyWith<$Res> get sessionUsage {
    return $TokenUsageCopyWith<$Res>(_value.sessionUsage, (value) {
      return _then(_value.copyWith(sessionUsage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatStateImplCopyWith<$Res>
    implements $ChatStateCopyWith<$Res> {
  factory _$$ChatStateImplCopyWith(
    _$ChatStateImpl value,
    $Res Function(_$ChatStateImpl) then,
  ) = __$$ChatStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Message> messages,
    bool isStreaming,
    TokenUsage sessionUsage,
    Map<String, String> reasoningByMessageId,
    String draft,
    String? error,
  });

  @override
  $TokenUsageCopyWith<$Res> get sessionUsage;
}

/// @nodoc
class __$$ChatStateImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$ChatStateImpl>
    implements _$$ChatStateImplCopyWith<$Res> {
  __$$ChatStateImplCopyWithImpl(
    _$ChatStateImpl _value,
    $Res Function(_$ChatStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? isStreaming = null,
    Object? sessionUsage = null,
    Object? reasoningByMessageId = null,
    Object? draft = null,
    Object? error = freezed,
  }) {
    return _then(
      _$ChatStateImpl(
        messages: null == messages
            ? _value._messages
            : messages // ignore: cast_nullable_to_non_nullable
                  as List<Message>,
        isStreaming: null == isStreaming
            ? _value.isStreaming
            : isStreaming // ignore: cast_nullable_to_non_nullable
                  as bool,
        sessionUsage: null == sessionUsage
            ? _value.sessionUsage
            : sessionUsage // ignore: cast_nullable_to_non_nullable
                  as TokenUsage,
        reasoningByMessageId: null == reasoningByMessageId
            ? _value._reasoningByMessageId
            : reasoningByMessageId // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        draft: null == draft
            ? _value.draft
            : draft // ignore: cast_nullable_to_non_nullable
                  as String,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ChatStateImpl with DiagnosticableTreeMixin implements _ChatState {
  const _$ChatStateImpl({
    final List<Message> messages = const <Message>[],
    this.isStreaming = false,
    this.sessionUsage = const TokenUsage(),
    final Map<String, String> reasoningByMessageId = const <String, String>{},
    this.draft = '',
    this.error,
  }) : _messages = messages,
       _reasoningByMessageId = reasoningByMessageId;

  final List<Message> _messages;
  @override
  @JsonKey()
  List<Message> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  @JsonKey()
  final bool isStreaming;
  @override
  @JsonKey()
  final TokenUsage sessionUsage;
  final Map<String, String> _reasoningByMessageId;
  @override
  @JsonKey()
  Map<String, String> get reasoningByMessageId {
    if (_reasoningByMessageId is EqualUnmodifiableMapView)
      return _reasoningByMessageId;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_reasoningByMessageId);
  }

  @override
  @JsonKey()
  final String draft;
  @override
  final String? error;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ChatState(messages: $messages, isStreaming: $isStreaming, sessionUsage: $sessionUsage, reasoningByMessageId: $reasoningByMessageId, draft: $draft, error: $error)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ChatState'))
      ..add(DiagnosticsProperty('messages', messages))
      ..add(DiagnosticsProperty('isStreaming', isStreaming))
      ..add(DiagnosticsProperty('sessionUsage', sessionUsage))
      ..add(DiagnosticsProperty('reasoningByMessageId', reasoningByMessageId))
      ..add(DiagnosticsProperty('draft', draft))
      ..add(DiagnosticsProperty('error', error));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStateImpl &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.isStreaming, isStreaming) ||
                other.isStreaming == isStreaming) &&
            (identical(other.sessionUsage, sessionUsage) ||
                other.sessionUsage == sessionUsage) &&
            const DeepCollectionEquality().equals(
              other._reasoningByMessageId,
              _reasoningByMessageId,
            ) &&
            (identical(other.draft, draft) || other.draft == draft) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_messages),
    isStreaming,
    sessionUsage,
    const DeepCollectionEquality().hash(_reasoningByMessageId),
    draft,
    error,
  );

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatStateImplCopyWith<_$ChatStateImpl> get copyWith =>
      __$$ChatStateImplCopyWithImpl<_$ChatStateImpl>(this, _$identity);
}

abstract class _ChatState implements ChatState {
  const factory _ChatState({
    final List<Message> messages,
    final bool isStreaming,
    final TokenUsage sessionUsage,
    final Map<String, String> reasoningByMessageId,
    final String draft,
    final String? error,
  }) = _$ChatStateImpl;

  @override
  List<Message> get messages;
  @override
  bool get isStreaming;
  @override
  TokenUsage get sessionUsage;
  @override
  Map<String, String> get reasoningByMessageId;
  @override
  String get draft;
  @override
  String? get error;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStateImplCopyWith<_$ChatStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

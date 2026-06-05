// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credential_handle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CredentialHandle {
  String get id => throw _privateConstructorUsedError;
  String get providerId => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get secureKey => throw _privateConstructorUsedError;
  DateTime? get lastUsedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of CredentialHandle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CredentialHandleCopyWith<CredentialHandle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CredentialHandleCopyWith<$Res> {
  factory $CredentialHandleCopyWith(
    CredentialHandle value,
    $Res Function(CredentialHandle) then,
  ) = _$CredentialHandleCopyWithImpl<$Res, CredentialHandle>;
  @useResult
  $Res call({
    String id,
    String providerId,
    String label,
    String secureKey,
    DateTime? lastUsedAt,
    DateTime createdAt,
  });
}

/// @nodoc
class _$CredentialHandleCopyWithImpl<$Res, $Val extends CredentialHandle>
    implements $CredentialHandleCopyWith<$Res> {
  _$CredentialHandleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CredentialHandle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? providerId = null,
    Object? label = null,
    Object? secureKey = null,
    Object? lastUsedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            providerId: null == providerId
                ? _value.providerId
                : providerId // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            secureKey: null == secureKey
                ? _value.secureKey
                : secureKey // ignore: cast_nullable_to_non_nullable
                      as String,
            lastUsedAt: freezed == lastUsedAt
                ? _value.lastUsedAt
                : lastUsedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CredentialHandleImplCopyWith<$Res>
    implements $CredentialHandleCopyWith<$Res> {
  factory _$$CredentialHandleImplCopyWith(
    _$CredentialHandleImpl value,
    $Res Function(_$CredentialHandleImpl) then,
  ) = __$$CredentialHandleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String providerId,
    String label,
    String secureKey,
    DateTime? lastUsedAt,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$CredentialHandleImplCopyWithImpl<$Res>
    extends _$CredentialHandleCopyWithImpl<$Res, _$CredentialHandleImpl>
    implements _$$CredentialHandleImplCopyWith<$Res> {
  __$$CredentialHandleImplCopyWithImpl(
    _$CredentialHandleImpl _value,
    $Res Function(_$CredentialHandleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CredentialHandle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? providerId = null,
    Object? label = null,
    Object? secureKey = null,
    Object? lastUsedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$CredentialHandleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        providerId: null == providerId
            ? _value.providerId
            : providerId // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        secureKey: null == secureKey
            ? _value.secureKey
            : secureKey // ignore: cast_nullable_to_non_nullable
                  as String,
        lastUsedAt: freezed == lastUsedAt
            ? _value.lastUsedAt
            : lastUsedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$CredentialHandleImpl implements _CredentialHandle {
  const _$CredentialHandleImpl({
    required this.id,
    required this.providerId,
    required this.label,
    required this.secureKey,
    this.lastUsedAt,
    required this.createdAt,
  });

  @override
  final String id;
  @override
  final String providerId;
  @override
  final String label;
  @override
  final String secureKey;
  @override
  final DateTime? lastUsedAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CredentialHandle(id: $id, providerId: $providerId, label: $label, secureKey: $secureKey, lastUsedAt: $lastUsedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CredentialHandleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.secureKey, secureKey) ||
                other.secureKey == secureKey) &&
            (identical(other.lastUsedAt, lastUsedAt) ||
                other.lastUsedAt == lastUsedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    providerId,
    label,
    secureKey,
    lastUsedAt,
    createdAt,
  );

  /// Create a copy of CredentialHandle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CredentialHandleImplCopyWith<_$CredentialHandleImpl> get copyWith =>
      __$$CredentialHandleImplCopyWithImpl<_$CredentialHandleImpl>(
        this,
        _$identity,
      );
}

abstract class _CredentialHandle implements CredentialHandle {
  const factory _CredentialHandle({
    required final String id,
    required final String providerId,
    required final String label,
    required final String secureKey,
    final DateTime? lastUsedAt,
    required final DateTime createdAt,
  }) = _$CredentialHandleImpl;

  @override
  String get id;
  @override
  String get providerId;
  @override
  String get label;
  @override
  String get secureKey;
  @override
  DateTime? get lastUsedAt;
  @override
  DateTime get createdAt;

  /// Create a copy of CredentialHandle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CredentialHandleImplCopyWith<_$CredentialHandleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

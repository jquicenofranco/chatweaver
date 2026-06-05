// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model_definition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ModelDefinition {
  String get id => throw _privateConstructorUsedError;
  String get providerId => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  int get contextWindow => throw _privateConstructorUsedError;
  bool get supportsStreaming => throw _privateConstructorUsedError;
  String? get apiBaseUrl => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;

  /// Create a copy of ModelDefinition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModelDefinitionCopyWith<ModelDefinition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModelDefinitionCopyWith<$Res> {
  factory $ModelDefinitionCopyWith(
    ModelDefinition value,
    $Res Function(ModelDefinition) then,
  ) = _$ModelDefinitionCopyWithImpl<$Res, ModelDefinition>;
  @useResult
  $Res call({
    String id,
    String providerId,
    String displayName,
    int contextWindow,
    bool supportsStreaming,
    String? apiBaseUrl,
    bool enabled,
  });
}

/// @nodoc
class _$ModelDefinitionCopyWithImpl<$Res, $Val extends ModelDefinition>
    implements $ModelDefinitionCopyWith<$Res> {
  _$ModelDefinitionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModelDefinition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? providerId = null,
    Object? displayName = null,
    Object? contextWindow = null,
    Object? supportsStreaming = null,
    Object? apiBaseUrl = freezed,
    Object? enabled = null,
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
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            contextWindow: null == contextWindow
                ? _value.contextWindow
                : contextWindow // ignore: cast_nullable_to_non_nullable
                      as int,
            supportsStreaming: null == supportsStreaming
                ? _value.supportsStreaming
                : supportsStreaming // ignore: cast_nullable_to_non_nullable
                      as bool,
            apiBaseUrl: freezed == apiBaseUrl
                ? _value.apiBaseUrl
                : apiBaseUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ModelDefinitionImplCopyWith<$Res>
    implements $ModelDefinitionCopyWith<$Res> {
  factory _$$ModelDefinitionImplCopyWith(
    _$ModelDefinitionImpl value,
    $Res Function(_$ModelDefinitionImpl) then,
  ) = __$$ModelDefinitionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String providerId,
    String displayName,
    int contextWindow,
    bool supportsStreaming,
    String? apiBaseUrl,
    bool enabled,
  });
}

/// @nodoc
class __$$ModelDefinitionImplCopyWithImpl<$Res>
    extends _$ModelDefinitionCopyWithImpl<$Res, _$ModelDefinitionImpl>
    implements _$$ModelDefinitionImplCopyWith<$Res> {
  __$$ModelDefinitionImplCopyWithImpl(
    _$ModelDefinitionImpl _value,
    $Res Function(_$ModelDefinitionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ModelDefinition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? providerId = null,
    Object? displayName = null,
    Object? contextWindow = null,
    Object? supportsStreaming = null,
    Object? apiBaseUrl = freezed,
    Object? enabled = null,
  }) {
    return _then(
      _$ModelDefinitionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        providerId: null == providerId
            ? _value.providerId
            : providerId // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        contextWindow: null == contextWindow
            ? _value.contextWindow
            : contextWindow // ignore: cast_nullable_to_non_nullable
                  as int,
        supportsStreaming: null == supportsStreaming
            ? _value.supportsStreaming
            : supportsStreaming // ignore: cast_nullable_to_non_nullable
                  as bool,
        apiBaseUrl: freezed == apiBaseUrl
            ? _value.apiBaseUrl
            : apiBaseUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$ModelDefinitionImpl implements _ModelDefinition {
  const _$ModelDefinitionImpl({
    required this.id,
    required this.providerId,
    required this.displayName,
    required this.contextWindow,
    this.supportsStreaming = true,
    this.apiBaseUrl,
    this.enabled = true,
  });

  @override
  final String id;
  @override
  final String providerId;
  @override
  final String displayName;
  @override
  final int contextWindow;
  @override
  @JsonKey()
  final bool supportsStreaming;
  @override
  final String? apiBaseUrl;
  @override
  @JsonKey()
  final bool enabled;

  @override
  String toString() {
    return 'ModelDefinition(id: $id, providerId: $providerId, displayName: $displayName, contextWindow: $contextWindow, supportsStreaming: $supportsStreaming, apiBaseUrl: $apiBaseUrl, enabled: $enabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelDefinitionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.contextWindow, contextWindow) ||
                other.contextWindow == contextWindow) &&
            (identical(other.supportsStreaming, supportsStreaming) ||
                other.supportsStreaming == supportsStreaming) &&
            (identical(other.apiBaseUrl, apiBaseUrl) ||
                other.apiBaseUrl == apiBaseUrl) &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    providerId,
    displayName,
    contextWindow,
    supportsStreaming,
    apiBaseUrl,
    enabled,
  );

  /// Create a copy of ModelDefinition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelDefinitionImplCopyWith<_$ModelDefinitionImpl> get copyWith =>
      __$$ModelDefinitionImplCopyWithImpl<_$ModelDefinitionImpl>(
        this,
        _$identity,
      );
}

abstract class _ModelDefinition implements ModelDefinition {
  const factory _ModelDefinition({
    required final String id,
    required final String providerId,
    required final String displayName,
    required final int contextWindow,
    final bool supportsStreaming,
    final String? apiBaseUrl,
    final bool enabled,
  }) = _$ModelDefinitionImpl;

  @override
  String get id;
  @override
  String get providerId;
  @override
  String get displayName;
  @override
  int get contextWindow;
  @override
  bool get supportsStreaming;
  @override
  String? get apiBaseUrl;
  @override
  bool get enabled;

  /// Create a copy of ModelDefinition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModelDefinitionImplCopyWith<_$ModelDefinitionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

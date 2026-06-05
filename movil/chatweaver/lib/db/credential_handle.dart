import 'package:freezed_annotation/freezed_annotation.dart';

part 'credential_handle.freezed.dart';

/// Metadatos de una credencial. NO contiene el API key real.
///
/// El token vive en [flutter_secure_storage] bajo [secureKey] y se lee
/// bajo demanda. Persistir el token en SQLite romperia la regla
/// "nunca en almacenamiento plano".
@freezed
class CredentialHandle with _$CredentialHandle {
  const factory CredentialHandle({
    required String id,
    required String providerId,
    required String label,
    required String secureKey,
    DateTime? lastUsedAt,
    required DateTime createdAt,
  }) = _CredentialHandle;
}

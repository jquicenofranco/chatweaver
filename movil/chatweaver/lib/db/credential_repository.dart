import 'credential_handle.dart';

/// Repositorio de credenciales.
///
/// Coordina el handle persistido en SQLite (metadatos) y el token
/// en [flutter_secure_storage] (valor). Los callers nunca tocan
/// el secure storage directamente — siempre van por esta interfaz.
abstract class CredentialRepository {
  /// Persiste un handle y su API key.
  Future<void> save(CredentialHandle handle, String apiKey);

  /// Lee el API key asociado a [handleId]. Devuelve null si no existe.
  Future<String?> read(String handleId);

  /// Borra el handle y su token.
  Future<void> delete(String handleId);

  /// Lista todos los handles (sin el token).
  Future<List<CredentialHandle>> list();

  /// Handle activo (mas recientemente usado) para un provider.
  Future<CredentialHandle?> activeFor(String providerId);

  /// Marca un handle como usado.
  Future<void> setActive(String handleId);
}

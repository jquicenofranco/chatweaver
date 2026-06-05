import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper delgado sobre [FlutterSecureStorage].
///
/// Es el unico punto donde se lee/escribe el API key. El token
/// nunca aparece en logs, en SQLite, ni en [shared_preferences].
class SecureCredentialStore {
  SecureCredentialStore(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);
}

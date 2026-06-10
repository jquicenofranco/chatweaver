import 'package:drift/drift.dart';

import 'app_database.dart';
import 'credential_handle.dart';
import 'credential_repository.dart';
import 'secure_credential_store.dart';

/// Implementacion de [CredentialRepository] que combina Drift
/// (metadatos del handle) y [SecureCredentialStore] (API key).
class CredentialRepositoryImpl implements CredentialRepository {
  CredentialRepositoryImpl({
    required AppDatabase db,
    required SecureCredentialStore store,
  }) : _db = db,
       _store = store;

  final AppDatabase _db;
  final SecureCredentialStore _store;

  @override
  Future<void> save(CredentialHandle handle, String apiKey) async {
    await _db.credentialHandlesDao.insertRow(
      CredentialHandlesCompanion.insert(
        id: handle.id,
        providerId: handle.providerId,
        label: handle.label,
        secureKey: handle.secureKey,
        createdAt: handle.createdAt,
        lastUsedAt: Value(handle.lastUsedAt),
      ),
    );
    await _store.write(handle.secureKey, apiKey);
  }

  @override
  Future<String?> read(String handleId) async {
    final row = await _db.credentialHandlesDao.getById(handleId);
    if (row == null) return null;
    return _store.read(row.secureKey);
  }

  @override
  Future<void> delete(String handleId) async {
    final row = await _db.credentialHandlesDao.getById(handleId);
    if (row == null) return;
    await _store.delete(row.secureKey);
    await _db.credentialHandlesDao.deleteById(handleId);
  }

  @override
  Future<List<CredentialHandle>> list() async {
    final rows = await _db.credentialHandlesDao.list();
    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Future<CredentialHandle?> activeFor(String providerId) async {
    final row = await _db.credentialHandlesDao.firstForProvider(providerId);
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> setActive(String handleId) async {
    await _db.credentialHandlesDao.touch(handleId, DateTime.now());
  }

  CredentialHandle _toDomain(CredentialHandleRow row) => CredentialHandle(
    id: row.id,
    providerId: row.providerId,
    label: row.label,
    secureKey: row.secureKey,
    lastUsedAt: row.lastUsedAt,
    createdAt: row.createdAt,
  );
}

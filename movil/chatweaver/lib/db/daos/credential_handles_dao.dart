import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/credential_handles_table.dart';

part 'credential_handles_dao.g.dart';

@DriftAccessor(tables: [CredentialHandles])
class CredentialHandlesDao extends DatabaseAccessor<AppDatabase>
    with _$CredentialHandlesDaoMixin {
  CredentialHandlesDao(super.db);

  Future<List<CredentialHandleRow>> list() => select(credentialHandles).get();

  Future<CredentialHandleRow?> getById(String id) => (select(
    credentialHandles,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<CredentialHandleRow?> firstForProvider(String providerId) =>
      (select(credentialHandles)
            ..where((t) => t.providerId.equals(providerId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.lastUsedAt,
                mode: OrderingMode.desc,
                nulls: NullsOrder.last,
              ),
              (t) => OrderingTerm(expression: t.createdAt),
            ]))
          .getSingleOrNull();

  Future<void> insertRow(CredentialHandlesCompanion row) =>
      into(credentialHandles).insert(row);

  Future<void> deleteById(String id) =>
      (delete(credentialHandles)..where((t) => t.id.equals(id))).go();

  Future<void> touch(String id, DateTime when) =>
      (update(credentialHandles)..where((t) => t.id.equals(id))).write(
        CredentialHandlesCompanion(lastUsedAt: Value(when)),
      );
}

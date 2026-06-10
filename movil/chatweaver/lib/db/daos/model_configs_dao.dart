import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/model_configs_table.dart';

part 'model_configs_dao.g.dart';

@DriftAccessor(tables: [ModelConfigs])
class ModelConfigsDao extends DatabaseAccessor<AppDatabase>
    with _$ModelConfigsDaoMixin {
  ModelConfigsDao(super.db);

  Future<List<ModelConfigRow>> getAll() => select(modelConfigs).get();

  Stream<List<ModelConfigRow>> watchAll() => select(modelConfigs).watch();

  Future<ModelConfigRow?> getById(String id) =>
      (select(modelConfigs)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<ModelConfigRow>> watchEnabled() =>
      (select(modelConfigs)..where((t) => t.enabled.equals(true))).watch();

  Future<void> upsert(ModelConfigsCompanion row) =>
      into(modelConfigs).insertOnConflictUpdate(row);

  Future<void> setEnabled(String id, bool enabled) =>
      (update(modelConfigs)..where((t) => t.id.equals(id))).write(
        ModelConfigsCompanion(enabled: Value(enabled)),
      );
}

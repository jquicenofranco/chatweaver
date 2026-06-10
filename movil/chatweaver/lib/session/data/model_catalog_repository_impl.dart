import 'package:chatweaver/db/app_database.dart';
import 'package:chatweaver/db/mappers/model_config_mapper.dart';
import 'package:chatweaver/session/domain/entities/model_definition.dart';
import 'package:chatweaver/session/domain/repositories/model_catalog_repository.dart';

class ModelCatalogRepositoryImpl implements ModelCatalogRepository {
  ModelCatalogRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<ModelDefinition>> listAll() async {
    final rows = await _db.modelConfigsDao.getAll();
    return rows.map((r) => r.toDomain()).toList(growable: false);
  }

  @override
  Future<List<ModelDefinition>> listEnabled() async {
    final all = await listAll();
    return all.where((m) => m.enabled).toList(growable: false);
  }

  @override
  Future<List<ModelDefinition>> listByProvider(String providerId) async {
    final all = await listAll();
    return all.where((m) => m.providerId == providerId).toList(growable: false);
  }

  @override
  Future<List<ModelDefinition>> listEnabledByProvider(String providerId) async {
    final byProvider = await listByProvider(providerId);
    return byProvider.where((m) => m.enabled).toList(growable: false);
  }

  @override
  Future<ModelDefinition?> getById(String id) async {
    final row = await _db.modelConfigsDao.getById(id);
    return row?.toDomain();
  }

  @override
  Future<void> setEnabled(String id, bool enabled) =>
      _db.modelConfigsDao.setEnabled(id, enabled);
}

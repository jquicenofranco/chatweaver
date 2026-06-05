import 'package:chatweaver/session/domain/entities/model_definition.dart';

abstract class ModelCatalogRepository {
  Future<List<ModelDefinition>> listAll();

  Future<List<ModelDefinition>> listEnabled();

  Future<ModelDefinition?> getById(String id);

  Future<void> setEnabled(String id, bool enabled);
}

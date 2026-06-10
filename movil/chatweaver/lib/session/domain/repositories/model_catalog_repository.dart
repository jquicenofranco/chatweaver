import 'package:chatweaver/session/domain/entities/model_definition.dart';

abstract class ModelCatalogRepository {
  Future<List<ModelDefinition>> listAll();

  Future<List<ModelDefinition>> listEnabled();

  /// Lista los modelos de un provider concreto. Usado por
  /// `ModelSelectorScreen` cuando se navega con `?providerId=...`
  /// (spec 04 v2.0.0).
  Future<List<ModelDefinition>> listByProvider(String providerId);

  /// Variante filtrada por provider + enabled. Usado por la
  /// pantalla de modelos despues de pasar por ProviderSelector:
  /// muestra solo los modelos que el usuario puede elegir
  /// efectivamente.
  Future<List<ModelDefinition>> listEnabledByProvider(String providerId);

  Future<ModelDefinition?> getById(String id);

  Future<void> setEnabled(String id, bool enabled);
}

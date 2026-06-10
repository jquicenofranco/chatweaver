import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatweaver/di/global_providers.dart';

/// Controller de test de conexion con el API key.
///
/// **Spec 04 v2.0.0**: el test se hace por provider, no por
/// modelo. Se resuelve el primer modelo habilitado del catalogo
/// del provider y se usa para un ping barato. La credencial
/// resultante se guarda asociada al `providerId`.
class ConnectionTestController extends StateNotifier<AsyncValue<void>> {
  ConnectionTestController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<String?> test({
    required String apiKey,
    required String providerId,
  }) async {
    state = const AsyncLoading();
    try {
      // 1. Resolver el primer modelo habilitado del provider.
      //    El test de conexion es barato: solo verifica que la
      //    key es valida, no que el modelo completo funcione.
      final models = await _ref
          .read(modelCatalogRepositoryProvider)
          .listEnabledByProvider(providerId);
      final firstModel = models.firstOrNull;
      if (firstModel == null) {
        // No hay modelos habilitados para este provider: no se
        // puede hacer ping. Mensaje legible para el usuario.
        const err = 'No hay modelos disponibles para este proveedor';
        state = AsyncError(err, StackTrace.current);
        return err;
      }

      // 2. Construir el provider con la definicion real.
      final provider = _ref
          .read(llmProviderFactoryProvider)
          .build(
            providerId: providerId,
            modelId: firstModel.id,
            apiKey: apiKey,
            contextWindow: firstModel.contextWindow,
            dio: _ref.read(dioProvider),
          );

      // 3. Probar conexion.
      final err = await provider.testConnection(apiKey: apiKey);
      if (err != null) {
        state = AsyncError(err, StackTrace.current);
        return err;
      }
      state = const AsyncData(null);
      return null;
    } catch (e, st) {
      state = AsyncError(e, st);
      return e.toString();
    }
  }
}

final connectionTestProvider =
    StateNotifierProvider.autoDispose<
      ConnectionTestController,
      AsyncValue<void>
    >((ref) => ConnectionTestController(ref));

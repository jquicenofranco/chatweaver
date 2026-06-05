import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatweaver/di/global_providers.dart';

/// Controller de test de conexion con el API key.
///
/// Sigue el patron StateNotifier (no Notifier) para conservar
/// la firma exacta de spec 04 §4.2.
class ConnectionTestController extends StateNotifier<AsyncValue<void>> {
  ConnectionTestController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<String?> test({
    required String apiKey,
    required String modelId,
  }) async {
    state = const AsyncLoading();
    try {
      final def = await _ref
          .read(modelCatalogRepositoryProvider)
          .getById(modelId);
      if (def == null) {
        const err = 'Modelo no encontrado en el catalogo';
        state = AsyncError(err, StackTrace.current);
        return err;
      }

      final provider = _ref.read(llmProviderFactoryProvider).build(
            providerId: def.providerId,
            modelId: def.id,
            apiKey: apiKey,
            contextWindow: def.contextWindow,
            dio: _ref.read(dioProvider),
          );

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

final connectionTestProvider = StateNotifierProvider.autoDispose<
    ConnectionTestController, AsyncValue<void>>(
  (ref) => ConnectionTestController(ref),
);

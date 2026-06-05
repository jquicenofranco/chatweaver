import 'package:dio/dio.dart';

import 'illm_provider.dart';

/// Builder que produce un [ILLMProvider] ya configurado.
typedef LlmProviderBuilder = ILLMProvider Function({
  required String apiKey,
  required String modelId,
  required int contextWindow,
  required Dio dio,
});

class UnsupportedProviderException implements Exception {
  const UnsupportedProviderException(this.providerId);

  final String providerId;

  @override
  String toString() => 'UnsupportedProviderException($providerId)';
}

/// Factory + registry para [ILLMProvider].
///
/// Cada provider se registra explicitamente desde
/// `lib/di/global_providers.dart`. NO se usa auto-registro por
/// side-effect de import (seria fragil: Dart no garantiza orden
/// de imports).
class LLMFactory {
  final Map<String, LlmProviderBuilder> _registry = {};

  void register(String providerId, LlmProviderBuilder builder) {
    _registry[providerId] = builder;
  }

  ILLMProvider build({
    required String providerId,
    required String modelId,
    required String apiKey,
    required int contextWindow,
    required Dio dio,
  }) {
    final builder = _registry[providerId];
    if (builder == null) {
      throw UnsupportedProviderException(providerId);
    }
    return builder(
      apiKey: apiKey,
      modelId: modelId,
      contextWindow: contextWindow,
      dio: dio,
    );
  }

  bool supports(String providerId) => _registry.containsKey(providerId);

  List<String> get supportedProviders => _registry.keys.toList();
}

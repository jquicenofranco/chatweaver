import 'dart:async';

import 'package:dio/dio.dart';

import 'generate_request.dart';
import 'generate_response.dart';
import 'llm_exception.dart';

/// Costo por 1k tokens (input, output). Record nativo de Dart 3.
typedef LlmCost = ({double inputPer1k, double outputPer1k});

/// Interfaz Strategy para proveedores de LLM.
///
/// Todo provider concreto (MiniMax, OpenAI, Ollama, etc.) implementa
/// esta interfaz. El caso de uso SendMessage solo conoce esta
/// abstraccion.
abstract class ILLMProvider {
  String get providerId;
  String get modelId;
  int get contextWindow;
  LlmCost get costPer1kTokens;

  /// Valida que [apiKey] es funcional. Devuelve `null` si OK,
  /// o un mensaje legible si falla.
  Future<String?> testConnection({required String apiKey});

  /// Stream principal de generacion de texto.
  Stream<GenerateResponseChunk> generateStream({
    required GenerateRequest request,
    String? apiKey,
    CancelToken? cancelToken,
  });

  /// Parsea una excepcion cruda (DioException, SocketException, etc.)
  /// a [LlmException]. Cada provider implementa el suyo.
  LlmException parseNetworkError(Object error, {StackTrace? stackTrace});

  /// Calcula tokens para [text] segun la tokenizacion del modelo.
  int calculateTokens(String text);
}

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:chatweaver/llm/generate_request.dart';
import 'package:chatweaver/llm/generate_response.dart';
import 'package:chatweaver/llm/illm_provider.dart';
import 'package:chatweaver/llm/llm_exception.dart';
import 'package:chatweaver/llm/llm_factory.dart';

import 'dto/minimax_request_dto.dart';
import 'minimax_adapter.dart';
import 'minimax_api_client.dart';

/// Implementacion de [ILLMProvider] para MiniMax.
///
/// El API key vive en memoria solo; nunca se loggea ni se persiste
/// fuera de [SecureCredentialStore].
class MiniMaxProvider implements ILLMProvider {
  MiniMaxProvider({
    required String apiKey,
    required this.modelId,
    required this.contextWindow,
    required Dio dio,
    String baseUrl = 'https://api.minimax.chat/v1',
    this.costPer1kTokens = (inputPer1k: 0.0, outputPer1k: 0.0),
  })  : _apiKey = apiKey,
        _client = MiniMaxApiClient(dio: dio, baseUrl: baseUrl);

  final String _apiKey;
  final MiniMaxApiClient _client;

  @override
  final String providerId = 'MiniMax';

  @override
  final String modelId;

  @override
  final int contextWindow;

  @override
  final LlmCost costPer1kTokens;

  @override
  Future<String?> testConnection({required String apiKey}) async {
    try {
      final dto = MiniMaxRequestDTO(
        model: modelId,
        messages: const [MiniMaxMessageDTO(role: 'user', content: 'ping')],
        maxTokens: 1,
        stream: false,
      );
      await _client.sendMessage(request: dto, apiKey: apiKey);
      return null;
    } on DioException catch (e) {
      return parseNetworkError(e).userMessage;
    } on SocketException catch (e) {
      return parseNetworkError(e).userMessage;
    } on MiniMaxApiException catch (e) {
      return parseNetworkError(e).userMessage;
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  @override
  Stream<GenerateResponseChunk> generateStream({
    required GenerateRequest request,
    String? apiKey,
    CancelToken? cancelToken,
  }) async* {
    final key = apiKey ?? _apiKey;
    final dto = _toDto(request).copyWith(stream: true);

    try {
      await for (final chunkDto in _client.streamMessage(
        request: dto,
        apiKey: key,
        cancelToken: cancelToken,
      )) {
        final chunk = MiniMaxAdapter.toChunk(chunkDto);
        if (chunk.textDelta != null ||
            chunk.usage != null ||
            chunk.finishReason != null) {
          yield chunk;
        }
      }
    } on MiniMaxApiException catch (e) {
      yield GenerateResponseChunk(errorMessage: parseNetworkError(e).userMessage);
    } on DioException catch (e) {
      yield GenerateResponseChunk(errorMessage: parseNetworkError(e).userMessage);
    } on SocketException catch (e) {
      yield GenerateResponseChunk(errorMessage: parseNetworkError(e).userMessage);
    } catch (e) {
      yield GenerateResponseChunk(errorMessage: 'Error inesperado: $e');
    }
  }

  @override
  int calculateTokens(String text) {
    // Aproximacion: 1 token ~ 4 chars para modelos GPT-compatible.
    return (text.length / 4).ceil();
  }

  @override
  LlmException parseNetworkError(Object error, {StackTrace? stackTrace}) {
    if (error is DioException) {
      return _parseDioError(error);
    }
    if (error is SocketException) {
      return const NetworkException(
        'No se pudo conectar con el servidor. Revisa tu conexion.',
      );
    }
    if (error is TimeoutException) {
      return const TimeoutException(
        'Tiempo de espera agotado. Revisa tu conexion.',
      );
    }
    if (error is MiniMaxApiException) {
      return ProviderException(error.message);
    }
    return ProviderException('Error inesperado: $error');
  }

  LlmException _parseDioError(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return const AuthException('Token invalido o expirado');
      case 403:
        return const AuthException('Sin permisos para este modelo');
      case 404:
        return const ProviderException('Modelo no encontrado');
      case 429:
        return const RateLimitException(
          'Demasiadas solicitudes. Intenta en unos segundos',
        );
      default:
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            return const TimeoutException(
              'Tiempo de espera agotado. Revisa tu conexion.',
            );
          case DioExceptionType.connectionError:
            return const NetworkException(
              'No se pudo conectar con el servidor',
            );
          default:
            return NetworkException(
              'Error de red: ${e.message ?? 'desconocido'}',
            );
        }
    }
  }

  MiniMaxRequestDTO _toDto(GenerateRequest request) {
    return MiniMaxRequestDTO(
      model: modelId,
      messages: request.messages.map(MiniMaxAdapter.toDto).toList(growable: false),
      stream: false,
      temperature: request.temperature,
      maxTokens: request.maxOutputTokens,
    );
  }

  /// Registro explicito en [LLMFactory]. Llamado una sola vez desde
  /// `lib/di/global_providers.dart`.
  static void registerSelf(LLMFactory factory) {
    factory.register(
      'MiniMax',
      ({
        required String apiKey,
        required String modelId,
        required int contextWindow,
        required Dio dio,
      }) =>
          MiniMaxProvider(
        apiKey: apiKey,
        modelId: modelId,
        contextWindow: contextWindow,
        dio: dio,
      ),
    );
  }
}

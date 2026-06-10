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
import 'thinking_stream_parser.dart';

/// Implementacion de [ILLMProvider] para MiniMax.
///
/// El API key vive en memoria solo; nunca se loggea ni se persiste
/// fuera de [SecureCredentialStore].
///
/// **Spec 05 (OQ-01 resuelto empiricamente)**: MiniMax **no**
/// expone un campo `reasoning_content` separado en el delta (aun
/// con `reasoning_split: true` en el request). El modelo M3
/// emite el reasoning **inline en `content`**, delimitado por
/// tags `<think>...</think>`. La separacion se hace en el
/// cliente via [ThinkingStreamParser].
///
/// El provider envia `reasoning_split: true` y
/// `thinking: {type: adaptive}` en el request (porque la doc
/// de MiniMax sugiere que influye en el formato de salida), y
/// adicionalmente parsea el stream entrante con el parser para
/// extraer el reasoning de forma defensiva. Asi, si MiniMax
/// cambia el formato en el futuro, el parser sigue siendo el
/// mecanismo correcto (los tags son OpenAI-compatible y
/// semanticos).
class MiniMaxProvider implements ILLMProvider {
  MiniMaxProvider({
    required String apiKey,
    required this.modelId,
    required this.contextWindow,
    required Dio dio,
    String baseUrl = 'https://api.minimax.io/v1',
    this.costPer1kTokens = (inputPer1k: 0.0, outputPer1k: 0.0),
  }) : _apiKey = apiKey,
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

  /// Modelos MiniMax con reasoning nativo. Mantenido como set
  /// para extender facilmente en el futuro.
  static const _reasoningCapable = <String>{'MiniMax-M3'};

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
    // **Bulletproof**: la flag `reasoningSplit` se envia para
    // hint al API (la doc sugiere que puede ayudar), pero
    // **NO** gateamos el parser en el cliente. El parser corre
    // SIEMPRE sobre el `content` recibido. Si no hay tags, es
    // no-op (pasa todo como text). Esto es defensivo contra:
    //   - Modelo nuevo que emite reasoning pero no esta en
    //     `_reasoningCapable`.
    //   - DB con `supportsReasoning` desincronizado.
    //   - API que ignora `reasoning_split` y siempre emite tags.
    final enableReasoningFlag =
        request.enableReasoning && _reasoningCapable.contains(modelId);
    final dto = _toDto(
      request,
      enableReasoning: enableReasoningFlag,
    ).copyWith(stream: true);

    // **Spec 05 (OQ-01 resuelto)**: MiniMax devuelve el reasoning
    // inline en `content` con tags `<think>...</think>`, no en un
    // campo separado. Usamos un parser con state para separar
    // ambos flujos a partir del mismo `content` del delta. El
    // parser se inicializa POR stream para que un cancel/retry
    // empiece limpio.
    final parser = ThinkingStreamParser();

    try {
      await for (final chunkDto in _client.streamMessage(
        request: dto,
        apiKey: key,
        cancelToken: cancelToken,
      )) {
        final base = MiniMaxAdapter.toChunk(chunkDto);

        // **BULLETPROOF**: procesar el `content` del delta a
        // traves del parser SIEMPRE (no solo si enableReasoning).
        // Si no hay tags `<think>`/`</think>`, el parser pasa
        // todo como text (no-op). Si los hay, separa reasoning
        // del answer. Esto garantiza que NUNCA vemos los tags en
        // el bubble del assistant, sin importar la config.
        String? textDelta = base.textDelta;
        String? reasoningDelta;
        if (base.textDelta != null && base.textDelta!.isNotEmpty) {
          final parsed = parser.process(base.textDelta!);
          textDelta = parsed.textDelta.isEmpty ? null : parsed.textDelta;
          reasoningDelta = parsed.reasoningDelta.isEmpty
              ? null
              : parsed.reasoningDelta;
        }

        // Construir el chunk final: el adapter ya mapeo el usage
        // (con thinkingTokens si la API lo expone). El parser
        // separo text/reasoning.
        final chunk = GenerateResponseChunk(
          textDelta: textDelta,
          reasoningDelta: reasoningDelta,
          usage: base.usage,
          finishReason: base.finishReason,
        );

        if (chunk.textDelta != null ||
            chunk.reasoningDelta != null ||
            chunk.usage != null ||
            chunk.finishReason != null) {
          yield chunk;
        }
      }
      // Flush al cierre normal del stream: emite cualquier residuo
      // del carry que el parser retenia (ej. tag partido justo en
      // el ultimo chunk, o stream truncado).
      final flushed = parser.flush();
      if (flushed.textDelta.isNotEmpty || flushed.reasoningDelta.isNotEmpty) {
        yield GenerateResponseChunk(
          textDelta: flushed.textDelta.isEmpty ? null : flushed.textDelta,
          reasoningDelta: flushed.reasoningDelta.isEmpty
              ? null
              : flushed.reasoningDelta,
        );
      }
    } on MiniMaxApiException catch (e) {
      yield GenerateResponseChunk(
        errorMessage: parseNetworkError(e).userMessage,
      );
    } on DioException catch (e) {
      yield GenerateResponseChunk(
        errorMessage: parseNetworkError(e).userMessage,
      );
    } on SocketException catch (e) {
      yield GenerateResponseChunk(
        errorMessage: parseNetworkError(e).userMessage,
      );
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

  /// Construye el DTO de request. Si [enableReasoning] es true,
  /// setea `reasoning_split: true` y `thinking: {type: adaptive}`.
  /// Esto se hace a nivel provider porque solo MiniMax (con M3
  /// actualmente) entiende estos flags; el caso de uso solo decide
  /// el "si", el provider decide el "como".
  MiniMaxRequestDTO _toDto(
    GenerateRequest request, {
    required bool enableReasoning,
  }) {
    return MiniMaxRequestDTO(
      model: modelId,
      messages: request.messages
          .map(MiniMaxAdapter.toDto)
          .toList(growable: false),
      stream: false,
      temperature: request.temperature,
      maxTokens: request.maxOutputTokens,
      reasoningSplit: enableReasoning,
      // json_serializable ignora `thinking` cuando es null
      // (includeIfNull: false en el DTO).
      thinking: enableReasoning ? const {'type': 'adaptive'} : null,
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
      }) => MiniMaxProvider(
        apiKey: apiKey,
        modelId: modelId,
        contextWindow: contextWindow,
        dio: dio,
      ),
    );
  }
}

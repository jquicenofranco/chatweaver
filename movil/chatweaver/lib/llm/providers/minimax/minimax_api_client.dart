import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'dto/minimax_request_dto.dart';
import 'dto/minimax_response_dto.dart';

/// Cliente HTTP especifico para la API de MiniMax.
///
/// Encapsula el parsing de SSE y el manejo de errores HTTP.
/// Usado internamente por [MiniMaxProvider]; el resto de la app
/// nunca ve tipos de [Dio].
class MiniMaxApiClient {
  MiniMaxApiClient({
    required Dio dio,
    String baseUrl = 'https://api.minimax.chat/v1',
  })  : _dio = dio,
        _baseUrl = baseUrl;

  final Dio _dio;
  final String _baseUrl;

  /// Envio streaming: emite un [MiniMaxResponseDTO] por chunk SSE.
  Stream<MiniMaxResponseDTO> streamMessage({
    required MiniMaxRequestDTO request,
    required String apiKey,
    CancelToken? cancelToken,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      '$_baseUrl/chat/completions',
      data: request.toJson(),
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'text/event-stream',
        },
        responseType: ResponseType.stream,
      ),
      cancelToken: cancelToken,
    );

    final byteStream = response.data?.stream;
    if (byteStream == null) {
      throw const MiniMaxApiException('Empty response stream');
    }

    await for (final line in _lineStream(byteStream)) {
      if (cancelToken?.isCancelled ?? false) break;
      final chunk = _parseSseLine(line);
      if (chunk != null) yield chunk;
    }
  }

  /// Envio no-streaming: una sola peticion, una sola respuesta.
  /// Usado por [MiniMaxProvider.testConnection] (validacion barata).
  Future<MiniMaxResponseDTO> sendMessage({
    required MiniMaxRequestDTO request,
    required String apiKey,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/chat/completions',
      data: request.toJson(),
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      cancelToken: cancelToken,
    );

    if (response.statusCode != 200) {
      throw MiniMaxApiException(
        'Respuesta inesperada: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    final data = response.data;
    if (data == null) {
      throw const MiniMaxApiException('Empty response body');
    }
    return MiniMaxResponseDTO.fromJson(data);
  }

  Stream<String> _lineStream(Stream<Uint8List> byteStream) async* {
    final lines = byteStream
        .cast<List<int>>()
        .transform<String>(const Utf8Decoder())
        .transform(const LineSplitter());
    await for (final line in lines) {
      if (line.startsWith('data:')) {
        final data = line.substring(5).trim();
        if (data == '[DONE]') break;
        yield data;
      }
    }
  }

  MiniMaxResponseDTO? _parseSseLine(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        return MiniMaxResponseDTO.fromJson(decoded);
      }
    } catch (_) {
      // descartar lineas mal formadas
    }
    return null;
  }
}

class MiniMaxApiException implements Exception {
  const MiniMaxApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'MiniMaxApiException: $message';
}

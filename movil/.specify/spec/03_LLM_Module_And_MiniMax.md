# 03 — Modulo LLM y MiniMax

> Especifica el codigo completo de `ILLMProvider`, `LLMFactory`, `MiniMaxProvider`, `MiniMaxApiClient`, `MiniMaxAdapter`, DTOs, `LlmException`, `parseNetworkError`. Adapter Pattern universal: mapper DTO -> ChatMessage.

---

## 1. Vision general

El modulo `llm/` concentra todo el codigo relacionado con la comunicacion con proveedores LLM externos. Es el unico modulo que conoce la libreria HTTP (Dio) y los DTOs especificos de cada API. Los demas modulos (`session/`, `message/`, `ui/`) hablan exclusivamente con la interfaz `ILLMProvider`.

```
llm/                                    # Modulo autocontenido
├── illm_provider.dart                  # Interfaz principal (Strategy)
├── llm_factory.dart                   # Factory con registro dinamico
├── llm_exception.dart                 # Jerarquia de excepciones + parseNetworkError
├── chat_message.dart                  # Entidad de dominio ChatMessage + ChatRole
├── generate_request.dart             # GenerateRequest
├── generate_response.dart            # GenerateResponseChunk
└── providers/
    └── minimax/
        ├── minimax_provider.dart
        ├── minimax_api_client.dart
        ├── minimax_adapter.dart
        └── dto/
            ├── minimax_request_dto.dart
            └── minimax_response_dto.dart
```

---

## 2. Entidades de dominio estandar (`llm/`)

### 2.1 ChatRole y ChatMessage

```dart
// lib/llm/chat_message.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '../../spec/chat_message.freezed.dart';

enum ChatRole { system, user, assistant }

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,           // Para tracking local; provider-generated opcional
    required ChatRole role,
    required String content,
    int? inputTokens,
    int? outputTokens,
    String? finishReason,
    String? errorMessage,         // Si este chunk es un error
    DateTime? timestamp,
  }) = _ChatMessage;
}
```

### 2.2 GenerateRequest

```dart
// lib/llm/generate_request.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '../../spec/generate_request.freezed.dart';

@freezed
class GenerateRequest with _$GenerateRequest {
  const factory GenerateRequest({
    required List<ChatMessage> messages,
    String? systemPrompt,
    @Default(0.7) double temperature,
    @Default(1024) int maxOutputTokens,
  }) = _GenerateRequest;
}
```

### 2.3 GenerateResponseChunk

```dart
// lib/llm/generate_response.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../spec/chat_message.dart';

part '../../spec/generate_response.freezed.dart';

@freezed
class GenerateResponseChunk with _$GenerateResponseChunk {
  const factory GenerateResponseChunk({
    /// Texto incremental. Usado para streaming en tiempo real.
    /// Es el unico campo que el caso de uso SendMessage necesita para
    /// ir acumulando la respuesta en la DB.
    String? textDelta,

    /// Usage stats presentes solo en el ultimo chunk.
    LlmUsage? usage,

    /// Razon de finalizacion: 'stop', 'length', 'content_filter', etc.
    String? finishReason,

    /// Mensaje de error. Cuando no es null, este chunk representa
    /// un error y no debe mostrarse como respuesta.
    String? errorMessage,
  }) = _GenerateResponseChunk;
}

@freezed
class LlmUsage with _$LlmUsage {
  const factory LlmUsage({
    required int inputTokens,
    required int outputTokens,
  }) = _LlmUsage;

  const LlmUsage._();

  int get total => inputTokens + outputTokens;
}
```

---

## 3. Interfaz `ILLMProvider`

```dart
// lib/llm/illm_provider.dart
import 'dart:async';

import 'package:dio/dio.dart';

import '../../spec/generate_request.dart';
import '../../spec/generate_response.dart';
import '../../spec/chat_message.dart';

/// Interfaz Strategy para proveedores de LLM.
///
/// Todo provider concreto (MiniMax, OpenAI, Ollama, etc.) implementa
/// esta interfaz. El caso de uso [SendMessage] solo conoce esta abstraccion.
///
/// Metodos:
/// - [testConnection] — validacion de credencial
/// - [generateStream] — version streaming (unica interfaz para SendMessage)
/// - [calculateTokens] — conteo de tokens especifico del modelo
/// - [parseNetworkError] — traduccion de excepciones de red a LlmException
abstract class ILLMProvider {
  /// Identificador del proveedor (ej. 'MiniMax', 'openai', 'ollama').
  String get providerId;

  /// Identificador del modelo concreto (ej. 'MiniMax-M', 'gpt-4o-mini').
  String get modelId;

  /// Tamanio maximo de la ventana de contexto en tokens.
  int get contextWindow;

  /// Tasa de coste de tokens por cada 1k tokens (input, output) —
  /// para estimacion de coste. Todo provider concreto declara coste
  /// (incluso 0.0 para proveedores gratuitos o desconocidos).
  ({double inputPer1k, double outputPer1k}) get costPer1kTokens;

  /// Valida que [apiKey] es funcional realizando una llamada minima.
  ///
  /// Devuelve `null` si la conexion es exitosa.
  /// Devuelve un mensaje de error legible para el usuario si falla.
  Future<String?> testConnection({required String apiKey});

  /// Stream principal de generacion de texto.
  ///
  /// El llamador puede abortar con [cancelToken].
  /// Esta es la interfaz primaria para el caso de uso [SendMessage].
  Stream<GenerateResponseChunk> generateStream({
    required GenerateRequest request,
    String? apiKey,
    CancelToken? cancelToken,
  });

  /// Parsea una excepcion de red cruda (DioException, http.ClientException,
  /// SocketException, etc.) y la traduce a [LlmException] con un
  /// [userMessage] legible. Esto permite que el codigo de UI no vea
  /// nunca detalles de la libreria HTTP.
  ///
  /// Cada provider implementa su propio parser porque la libreria HTTP
  /// y los codigos de error de cada API son distintos.
  LlmException parseNetworkError(Object error, {StackTrace? stackTrace});

  /// Calcula el numero de tokens necesarios para [text] segun
  /// el esquema de tokenizacion de este modelo.
  ///
  /// Cada provider usa su propio metodo de conteo (no hay un contador
  /// global aproximado). El caso de uso delega en el provider activo.
  int calculateTokens(String text);
}
```

---

## 4. `LLMFactory`

```dart
// lib/llm/llm_factory.dart
import 'package:dio/dio.dart';

import '../../spec/illm_provider.dart';

typedef LlmProviderBuilder = ILLMProvider Function({
  required String apiKey,
  required String modelId,
  required int contextWindow,
  required Dio dio,
});

class UnsupportedProviderException implements Exception {
  final String providerId;
  const UnsupportedProviderException(this.providerId);
  @override
  String toString() => 'UnsupportedProviderException($providerId)';
}

/// Factory para crear instancias de [ILLMProvider] segun el providerId.
///
/// Utiliza el patron Factory con registro dinamico via mapa.
/// Cada provider concreto se registra explicitamente desde
/// [lib/di/global_providers.dart] llamando a `MiniMaxProvider.registerSelf(factory)`.
/// NO se usa auto-registro por side-effect de import (seria fragil:
/// Dart no garantiza el orden de imports y el registro se perderia
/// en tests aislados).
class LLMFactory {
  final Map<String, LlmProviderBuilder> _registry = {};

  /// Registra un builder para un [providerId].
  /// Debe llamarse una unica vez por provider (normalmente al final
  /// del archivo que define la implementacion, o explicitamente
  /// desde global_providers.dart).
  void register(String providerId, LlmProviderBuilder builder) {
    _registry[providerId] = builder;
  }

  /// Construye la instancia del provider para [providerId].
  ///
  /// Lanza [UnsupportedProviderException] si no hay builder registrado.
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
```

---

## 5. Excepciones y parseo de errores de red

```dart
// lib/llm/llm_exception.dart
/// Jerarquia de excepciones del modulo LLM.
///
/// [userMessage] es el mensaje legible para el usuario (ya traducido,
/// localizeable si es necesario). [LlmException] nunca expone
/// detalles de la libreria HTTP ni codigos de red internos.
sealed class LlmException implements Exception {
  final String userMessage;
  const LlmException(this.userMessage);
  @override
  String toString() => '$runtimeType: $userMessage';
}

class NetworkException extends LlmException {
  const NetworkException(super.userMessage);
}

class AuthException extends LlmException {
  const AuthException(super.userMessage);
}

class ContextWindowExceededException extends LlmException {
  const ContextWindowExceededException(super.userMessage);
}

class RateLimitException extends LlmException {
  const RateLimitException(super.userMessage);
}

class ProviderException extends LlmException {
  const ProviderException(super.userMessage);
}

class TimeoutException extends LlmException {
  const TimeoutException(super.userMessage);
}
```

**El metodo `parseNetworkError`** es responsabilidad de cada provider concreto porque:
1. La libreria HTTP puede variar (Dio, http.Client, etc.).
2. Los codigos de error de cada API son distintos.
3. Los mensajes de error del provider son especificos de su implementacion.

Ejemplo en `MiniMaxProvider`:

```dart
// Dentro de lib/llm/providers/minimax/minimax_provider.dart

@override
LlmException parseNetworkError(Object error, {StackTrace? stackTrace}) {
  if (error is DioException) {
    return _parseDioError(error, stackTrace);
  }
  if (error is SocketException) {
    return const NetworkException('No se pudo conectar con el servidor. Revisa tu conexion.');
  }
  if (error is TimeoutException) {
    return const TimeoutException('Tiempo de espera agotado. Revisa tu conexion.');
  }
  return ProviderException('Error inesperado: ${error.toString()}');
}

LlmException _parseDioError(DioException e, StackTrace? st) {
  switch (e.response?.statusCode) {
    case 401:
      return const AuthException('Token invalido o expirado');
    case 403:
      return const AuthException('Sin permisos para este modelo');
    case 404:
      return const ProviderException('Modelo no encontrado');
    case 429:
      return const RateLimitException('Demasiadas solicitudes. Intenta en unos segundos');
    default:
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
          return const TimeoutException('Tiempo de espera agotado. Revisa tu conexion.');
        case DioExceptionType.connectionError:
          return const NetworkException('No se pudo conectar con el servidor');
        default:
          return NetworkException('Error de red: ${e.message ?? 'desconocido'}');
      }
  }
}
```

---

## 6. DTOs de MiniMax

```dart
// lib/llm/providers/minimax/dto/minimax_request_dto.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '../../spec/minimax_request_dto.freezed.dart';
part '../../spec/minimax_request_dto.g.dart';

@freezed
class MiniMaxRequestDTO with _$MiniMaxRequestDTO {
  const factory MiniMaxRequestDTO({
    required String model,
    required List<MiniMaxMessageDTO> messages,
    @Default(true) bool stream,
    @Default(0.7) double temperature,
    @Default(1024) int max_tokens,
  }) = _MiniMaxRequestDTO;
}

@freezed
class MiniMaxMessageDTO with _$MiniMaxMessageDTO {
  const factory MiniMaxMessageDTO({
    required String role,
    required String content,
  }) = _MiniMaxMessageDTO;
}
```

```dart
// lib/llm/providers/minimax/dto/minimax_response_dto.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '../../spec/minimax_response_dto.freezed.dart';
part '../../spec/minimax_response_dto.g.dart';

@freezed
class MiniMaxResponseDTO with _$MiniMaxResponseDTO {
  const factory MiniMaxResponseDTO({
    required String id,
    String? object,
    int? created,
    String? model,
    List<MiniMaxChoiceDTO>? choices,
    MiniMaxUsageDTO? usage,
    String? finishReason,
  }) = _MiniMaxResponseDTO;
}

@freezed
class MiniMaxChoiceDTO with _$MiniMaxChoiceDTO {
  const factory MiniMaxChoiceDTO({
    MiniMaxDeltaDTO? delta,
    @JsonKey('finish_reason') String? finishReason,
    int? index,
  }) = _MiniMaxChoiceDTO;
}

@freezed
class MiniMaxDeltaDTO with _$MiniMaxDeltaDTO {
  const factory MiniMaxDeltaDTO({
    String? content,
    String? role,
  }) = _MiniMaxDeltaDTO;
}

@freezed
class MiniMaxUsageDTO with _$MiniMaxUsageDTO {
  const factory MiniMaxUsageDTO({
    @JsonKey('prompt_tokens') int? promptTokens,
    @JsonKey('completion_tokens') int? completionTokens,
    @JsonKey('total_tokens') int? totalTokens,
  }) = _MiniMaxUsageDTO;
}
```

---

## 7. MiniMaxApiClient

```dart
// lib/llm/providers/minimax/minimax_api_client.dart
import 'dart:async';      // LineSplitter
import 'dart:convert';    // Utf8Decoder
import 'dart:typed_data'; // Uint8List

import 'package:dio/dio.dart';

import '../../dto/minimax_request_dto.dart';
import '../../dto/minimax_response_dto.dart';

/// Cliente HTTP especifico para la API de MiniMax.
///
/// Encapsula la logica de parsing SSE y el manejo de errores HTTP.
/// Es usado internamente por [MiniMaxProvider].
class MiniMaxApiClient {
  final Dio _dio;
  final String _baseUrl;

  MiniMaxApiClient({
    required Dio dio,
    String baseUrl = 'https://api.minimax.io/v1',
  })  : _dio = dio,
        _baseUrl = baseUrl;

  /// Envio streaming: devuelve un stream de lineas SSE parseadas.
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

    final byteStream = response.data;
    if (byteStream == null) {
      throw MiniMaxApiException('Empty response stream');
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

    return MiniMaxResponseDTO.fromJson(response.data!);
  }

  Stream<String> _lineStream(Stream<Uint8List> byteStream) async* {
    final lines = byteStream
        .transform(const Utf8Decoder())
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
      return MiniMaxResponseDTO.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    } catch (_) {
      return null; // descartar lineas mal formadas
    }
  }
}

class MiniMaxApiException implements Exception {
  final String message;
  final int? statusCode;
  const MiniMaxApiException(this.message, {this.statusCode});
  @override
  String toString() => 'MiniMaxApiException: $message';
}
```

---

## 8. MiniMaxAdapter (Adapter Pattern)

```dart
// lib/llm/providers/minimax/minimax_adapter.dart
import '../../../../generate_response.dart';
import '../../../../chat_message.dart';
import '../../dto/minimax_response_dto.dart';

/// Adapter que traduce DTOs nativos de MiniMax a entidades de dominio.
///
/// Transforma:
/// - MiniMaxResponseDTO → GenerateResponseChunk (streaming)
/// - MiniMaxChoiceDTO.delta.content → textDelta
/// - MiniMaxUsageDTO → LlmUsage
///
/// El caso de uso [SendMessage] solo conoce [GenerateResponseChunk] y [LlmUsage];
/// nunca ve [MiniMaxResponseDTO] ni [MiniMaxChoiceDTO].
class MiniMaxAdapter {
  /// Convierte un chunk SSE de MiniMax a [GenerateResponseChunk].
  ///
  /// Solo se mapea lo que el caso de uso consume (textDelta, usage, finishReason).
  /// El `id` del mensaje y el `timestamp` son responsabilidad del caso de uso
  /// (los genera al persistir en DB).
  static GenerateResponseChunk toChunk(MiniMaxResponseDTO dto) {
    final choice = dto.choices?.firstOrNull;
    return GenerateResponseChunk(
      textDelta: choice?.delta?.content,
      usage: dto.usage != null
          ? LlmUsage(
              inputTokens: dto.usage!.promptTokens ?? 0,
              outputTokens: dto.usage!.completionTokens ?? 0,
            )
          : null,
      finishReason: choice?.finishReason ?? dto.finishReason,
    );
  }

  /// Traduce un mensaje de dominio [ChatMessage] a [MiniMaxMessageDTO]
  /// para enviar en el request.
  static MiniMaxMessageDTO toDto(ChatMessage message) {
    return MiniMaxMessageDTO(
      role: _toApiRole(message.role),
      content: message.content,
    );
  }

  static String _toApiRole(ChatRole role) {
    return switch (role) {
      ChatRole.system => 'system',
      ChatRole.user => 'user',
      ChatRole.assistant => 'assistant',
    };
  }
}
```

---

## 9. MiniMaxProvider (implementacion completa)

```dart
// lib/llm/providers/minimax/minimax_provider.dart
import 'dart:async';
import 'dart:io'; // SocketException

import 'package:dio/dio.dart';

import '../../../../illm_provider.dart';
import '../../../../generate_request.dart';
import '../../../../generate_response.dart';
import '../../../../llm_exception.dart';
import '../../../../chat_message.dart';
import '../../spec/minimax_api_client.dart';
import '../../spec/minimax_adapter.dart';
import '../../spec/dto/minimax_request_dto.dart';

/// Implementacion de [ILLMProvider] para MiniMax.
///
/// Auto-registra sus builders en [LLMFactory] al importarse.
/// Cada instancia es stateless; el API key se pasa en cada llamada.
class MiniMaxProvider implements ILLMProvider {
  final String _apiKey;
  final MiniMaxApiClient _client;
  final String _baseUrl;

  @override
  final String providerId = 'MiniMax';
  @override
  final String modelId;
  @override
  final int contextWindow;
  @override
  final ({double inputPer1k, double outputPer1k}) costPer1kTokens;

  MiniMaxProvider({
    required String apiKey,
    required String modelId,
    required int contextWindow,
    required Dio dio,
    String baseUrl = 'https://api.minimax.io/v1',
    this.costPer1kTokens = (inputPer1k: 0.0, outputPer1k: 0.0),
  })  : _apiKey = apiKey,
        _client = MiniMaxApiClient(dio: dio, baseUrl: baseUrl),
        _baseUrl = baseUrl,
        modelId = modelId,
        contextWindow = contextWindow;

  // ─── ILLMProvider ───────────────────────────────────────────────

  @override
  Future<String?> testConnection({required String apiKey}) async {
    try {
      final dto = MiniMaxRequestDTO(
        model: modelId,
        messages: [
          const MiniMaxMessageDTO(role: 'user', content: 'ping'),
        ],
        max_tokens: 1,
        stream: false,
      );

      // Peticion no-streaming barata. Si no lanza excepcion, el token es valido.
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
        if (chunk.textDelta != null || chunk.usage != null || chunk.finishReason != null) {
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
    // MiniMax usa tokenizacion similar a Tiktoken para modelos GPT-compatible.
    // Aproximacion: 1 token ≈ 4 caracteres para texto en Ingles.
    // Para texto mixto se usa la misma aproximacion con margen.
    return (text.length / 4).ceil();
  }

  @override
  LlmException parseNetworkError(Object error, {StackTrace? stackTrace}) {
    if (error is DioException) {
      return _parseDioError(error, stackTrace);
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
    return ProviderException('Error inesperado: ${error.toString()}');
  }

  LlmException _parseDioError(DioException e, StackTrace? st) {
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

  // ─── Privado ───────────────────────────────────────────────────

  MiniMaxRequestDTO _toDto(GenerateRequest request) {
    final messages = request.messages.map((m) {
      return MiniMaxAdapter.toDto(m);
    }).toList();

    return MiniMaxRequestDTO(
      model: modelId,
      messages: messages,
      stream: false,
      temperature: request.temperature,
      max_tokens: request.maxOutputTokens,
    );
  }

  // ─── Auto-registro en Factory ──────────────────────────────────

  /// Registro explicito en [LLMFactory].
  /// Llamado una sola vez desde [lib/di/global_providers.dart].
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
```

---

## 10. Timeouts (configuracion de Dio)

- `connectTimeout`: 10 s.
- `sendTimeout`: 30 s.
- `receiveTimeout`: deshabilitado para streams (ilimitado).
- **Reintentos automaticos:** NO en MVP. El ultimo mensaje fallido se guarda con `status = failed` y `errorMessage`.

---

## 11. Detalles del provider real (MiniMax)

> Esta seccion documenta los IDs de modelo y endpoints **reales** verificados contra
> `https://platform.minimax.io/docs`. Cualquier contribuidor que anada otro modelo
> DEBE confirmar primero que existe en esa documentacion — no inferir nombres.

### 11.1 Endpoint

- **Base URL (OpenAI-compatible)**: `https://api.minimax.io/v1`
- **Path**: `POST /v1/chat/completions`
- **Auth header**: `Authorization: Bearer <MINIMAX_API_KEY>`
- **Plataforma / gestion de keys**: `https://platform.minimax.io/user-center/basic-information/interface-key`
- **Docs**: `https://platform.minimax.io/docs` (seccion *API Reference → Text → OpenAI API Compatible*)

> Tambien existe una superficie **Anthropic-compatible** en
> `https://api.minimax.io/anthropic` con auth por `x-api-key` y
> `anthropic-version: 2023-06-01`. El MVP usa solo la OpenAI-compatible
> para mantener una unica libreria HTTP y un solo set de DTOs. Si se
> necesita la API Anthropic-compatible, va como un nuevo provider
> registrado en `LLMFactory` — **no** se modifica `MiniMaxProvider`.

### 11.2 Modelos sembrados en `model_configs`

| `id` (DB) | `displayName` | `contextWindow` | Notas |
|---|---|---|---|
| `MiniMax-M3` | MiniMax M3 | 1,000,000 | Flagship multimodal. Soporta `thinking` adaptativo. |
| `MiniMax-M2.7` | MiniMax M2.7 | 204,800 | Default. Buen balance calidad/costo. |
| `MiniMax-M2.7-highspeed` | MiniMax M2.7 Highspeed | 204,800 | Variante mas rapida del M2.7. |

> El seed historico uso los IDs `MiniMax-M` y `MiniMax-XL`, que **no
> existen en la API real**. La migracion de DB `v1 -> v2`
> (`app_database.dart::_replaceSeedModelConfigs`) los borra y los
> reemplaza por los IDs de arriba, re-apuntando sesiones huerfanas
> a `MiniMax-M3`.

### 11.3 Parametros del request

| Parametro | Tipo | Default MiniMax | Notas |
|---|---|---|---|
| `model` | string | (segun `model_configs.id`) | Debe matchear un ID valido de la API. |
| `messages` | array | — | Formato OpenAI: `[{role, content}]`. |
| `max_tokens` o `max_completion_tokens` | int | 1024 | Ambos aceptados. |
| `temperature` | float | 1.0 | Rango [0, 2]. |
| `top_p` | float | 0.95 (M3) / 0.9 (M2.x) | Rango [0, 1]. |
| `stream` | bool | false | `true` para SSE. |
| `thinking` | object | — | `{"type":"adaptive"}` para M3. |
| `reasoning_split` | bool | false | Separa `reasoning_content`/`content`. |

> El provider del MVP **no** envia `thinking`, `reasoning_split` ni
> `stream_options` — son aditivos y no rompen nada si se omiten. Si
> en el futuro se quiere mostrar el "razonamiento" del modelo, se
> extiende el DTO de respuesta y `MiniMaxAdapter`, sin tocar la UI.

### 11.4 Formato de respuesta (no-streaming)

```json
{
  "id": "0677...",
  "model": "MiniMax-M3",
  "choices": [
    {
      "index": 0,
      "message": {"role": "assistant", "content": "..."},
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 12,
    "completion_tokens": 84,
    "total_tokens": 96
  }
}
```

El DTO `MiniMaxResponseDTO` y `MiniMaxAdapter.toChunk` ya cubren este
formato. `finish_reason` puede ser `stop`, `length`, `tool_calls` o
`content_filter` — todos mapean a `GenerateResponseChunk.finishReason`.

### 11.5 Errores especificos que valen la pena conocer

| HTTP | Cuerpo tipico | Mapping en `parseNetworkError` |
|---|---|---|
| 401 | `{"type":"error","error":{"type":"authorized_error", ...}}` | `AuthException` — "Token invalido o expirado" |
| 403 | forbidden | `AuthException` — "Sin permisos para este modelo" |
| 404 | model_not_found | `ProviderException` — "Modelo no encontrado" |
| 429 | rate_limit_exceeded | `RateLimitException` |
| 5xx | internal_error | `ProviderException` con mensaje del server |

> **Si un 401 viene con cuerpo vacio**, es senial de que el request
> no llego a `api.minimax.io` (DNS equivocado, proxy, etc.). El bug
> historico `api.minimax.chat` (dominio que no hospeda MiniMax)
> producia exactamente este sintoma. Verificar siempre con
> `curl -i https://api.minimax.io/v1/chat/completions` antes de
> tocar codigo de la app.

---

## 12. Resumen de invariantes

1. `ILLMProvider` es la unica interfaz publica del modulo `llm/`.
2. Los DTOs nativos **nunca** cruzan la capa del provider hacia `domain` o `presentation`.
3. El mapper (`MiniMaxAdapter`) traduce DTO → entidad de dominio; es la unica traduccion valida.
4. `parseNetworkError` es implementacion de cada provider; la UI nunca ve `DioException`.
5. El factory es el unico punto de registro; `session/` y `ui/` solo conocen `ILLMProvider`.
6. La UI usa siempre `generateStream`; no existe `sendMessage` (no-streaming) en la interfaz.
7. **Los IDs de modelo y la base URL vienen de la documentacion oficial** — no se infieren.
   Cualquier anadido requiere confirmar primero contra
   `https://platform.minimax.io/docs`.

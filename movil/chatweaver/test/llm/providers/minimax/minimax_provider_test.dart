import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:chatweaver/llm/chat_message.dart';
import 'package:chatweaver/llm/generate_request.dart';
import 'package:chatweaver/llm/providers/minimax/minimax_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests del provider MiniMax con un Dio fake que captura el body
/// del request y devuelve un stream SSE controlado.
///
/// **OQ-01 resuelto**: el provider usa [ThinkingStreamParser] para
/// separar el razonamiento de la respuesta cuando el modelo
/// emite tags `<think>...</think>` inline en `content`. Estos
/// tests verifican ambos casos: con tags y sin tags.
class _FakeDioAdapter implements HttpClientAdapter {
  _FakeDioAdapter(this._sseBody);

  final String _sseBody;
  Map<String, dynamic>? lastRequestBody;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    if (requestStream != null) {
      // `requestStream` es `Stream<Uint8List>?`. Lo consumimos a
      // una lista plana de bytes. NO existe `Stream.toBytes()` en
      // Dart core.
      final chunks = await requestStream.toList();
      final bytes = chunks.expand((c) => c).toList();
      if (bytes.isNotEmpty) {
        lastRequestBody =
            json.decode(utf8.decode(bytes)) as Map<String, dynamic>;
      }
    }
    final stream = Stream<Uint8List>.fromIterable([utf8.encode(_sseBody)]);
    return ResponseBody(
      stream,
      200,
      headers: {
        'content-type': ['text/event-stream'],
      },
    );
  }
}

String _sseChunk(Map<String, dynamic> json) {
  return 'data: ${jsonEncode(json)}\n\n';
}

/// Helper: arma un `ChatMessage` valido (con id y timestamp
/// requeridos por el freezed factory).
ChatMessage _msg(String content) => ChatMessage(
  id: 'msg-${content.hashCode}',
  role: ChatRole.user,
  content: content,
  timestamp: DateTime(2026),
);

void main() {
  group('MiniMaxProvider (tag-based reasoning parsing)', () {
    test('enableReasoning=true + M3 → parsea tags <think></think>', () async {
      // El API NO devuelve reasoning_content; el reasoning viene
      // inline en content. El provider debe detectarlo y emitir
      // el trace por separado.
      final sse = [
        _sseChunk({
          'id': 'r1',
          'choices': [
            {
              'delta': {'content': '<think>pensemos...'},
            },
          ],
        }),
        _sseChunk({
          'id': 'r1',
          'choices': [
            {
              'delta': {'content': ' 17*24=408</think>La respuesta es 408.'},
            },
          ],
          'finish_reason': 'stop',
        }),
      ].join();

      final adapter = _FakeDioAdapter(sse);
      final dio = Dio()..httpClientAdapter = adapter;
      final provider = MiniMaxProvider(
        apiKey: 'sk-fake',
        modelId: 'MiniMax-M3',
        contextWindow: 1000000,
        dio: dio,
      );

      final chunks = await provider
          .generateStream(
            request: GenerateRequest(
              messages: [_msg('ping')],
              enableReasoning: true,
            ),
          )
          .toList();

      // 1) Request body correcto.
      expect(adapter.lastRequestBody, isNotNull);
      expect(adapter.lastRequestBody!['reasoning_split'], true);
      expect(adapter.lastRequestBody!['thinking'], {'type': 'adaptive'});

      // 2) El provider emite chunks con reasoning y text separados.
      final reasoningChunks = chunks
          .where(
            (c) => c.reasoningDelta != null && c.reasoningDelta!.isNotEmpty,
          )
          .toList();
      final textChunks = chunks
          .where((c) => c.textDelta != null && c.textDelta!.isNotEmpty)
          .toList();
      expect(
        reasoningChunks,
        isNotEmpty,
        reason: 'el parser debio extraer el reasoning',
      );
      expect(
        textChunks,
        isNotEmpty,
        reason: 'el parser debio extraer el answer',
      );

      // 3) Concatenando TODOS los reasoningDeltas obtenemos el
      //    trace completo (sin los tags, sin el answer).
      final fullReasoning = reasoningChunks
          .map((c) => c.reasoningDelta!)
          .join();
      expect(fullReasoning, contains('pensemos...'));
      expect(fullReasoning, contains('17*24=408'));
      expect(fullReasoning, isNot(contains('La respuesta es')));

      // 4) Concatenando TODOS los textDeltas obtenemos el answer
      //    puro (sin tags, sin reasoning).
      final fullText = textChunks.map((c) => c.textDelta!).join();
      expect(fullText, contains('La respuesta es 408'));
      expect(fullText, isNot(contains('pensemos')));
      expect(fullText, isNot(contains('<think>')));
      expect(fullText, isNot(contains('</think>')));
    });

    test('tags partidos entre chunks se manejan correctamente', () async {
      // Caso adversarial: el tag `</think>` se parte justo al
      // final del chunk 1. El carryover del parser debe
      // concatenarlo con el chunk 2 y detectarlo.
      final sse = [
        _sseChunk({
          'id': 'r1',
          'choices': [
            {
              'delta': {'content': '<think>pensando</thin'},
            },
          ],
        }),
        _sseChunk({
          'id': 'r1',
          'choices': [
            {
              'delta': {'content': 'k>respuesta'},
            },
          ],
          'finish_reason': 'stop',
        }),
      ].join();

      final adapter = _FakeDioAdapter(sse);
      final dio = Dio()..httpClientAdapter = adapter;
      final provider = MiniMaxProvider(
        apiKey: 'sk-fake',
        modelId: 'MiniMax-M3',
        contextWindow: 1000000,
        dio: dio,
      );

      final chunks = await provider
          .generateStream(
            request: GenerateRequest(
              messages: [_msg('ping')],
              enableReasoning: true,
            ),
          )
          .toList();

      final fullReasoning = chunks
          .where((c) => c.reasoningDelta != null)
          .map((c) => c.reasoningDelta!)
          .join();
      final fullText = chunks
          .where((c) => c.textDelta != null)
          .map((c) => c.textDelta!)
          .join();
      expect(fullReasoning, 'pensando');
      expect(fullText, 'respuesta');
    });

    test(
      'enableReasoning=false → parser SIGUE corriendo (bulletproof)',
      () async {
        // **Bulletproof**: el parser SIEMPRE corre sobre el
        // `content`, sin importar `enableReasoning`. Esto
        // garantiza que NUNCA vemos tags en el bubble del
        // assistant, sin importar la config del modelo. Si
        // enableReasoning=false, el request NO envia los flags
        // (`reasoning_split`, `thinking`), pero el cliente
        // sigue parseando lo que llegue.
        final sse = _sseChunk({
          'id': 'r1',
          'choices': [
            {
              'delta': {'content': '<think>esto es texto plano</think>hola'},
            },
          ],
          'finish_reason': 'stop',
        });

        final adapter = _FakeDioAdapter(sse);
        final dio = Dio()..httpClientAdapter = adapter;
        final provider = MiniMaxProvider(
          apiKey: 'sk-fake',
          modelId: 'MiniMax-M3',
          contextWindow: 1000000,
          dio: dio,
        );

        final chunks = await provider
            .generateStream(
              request: GenerateRequest(
                messages: [_msg('ping')],
                enableReasoning: false,
              ),
            )
            .toList();

        // El parser SEPARO los tags aunque enableReasoning=false.
        final fullText = chunks
            .where((c) => c.textDelta != null)
            .map((c) => c.textDelta!)
            .join();
        final fullReasoning = chunks
            .where((c) => c.reasoningDelta != null)
            .map((c) => c.reasoningDelta!)
            .join();
        // El answer NO contiene los tags.
        expect(fullText, isNot(contains('<think>')));
        expect(fullText, isNot(contains('</think>')));
        expect(fullText, 'hola');
        // El reasoning tiene el trace.
        expect(fullReasoning, 'esto es texto plano');
      },
    );

    test('modelo M2.7 (no-thinking) → no envia flags ni parsea tags', () async {
      final sse = _sseChunk({
        'id': 'r1',
        'choices': [
          {
            'delta': {'content': 'hola'},
          },
        ],
        'finish_reason': 'stop',
      });

      final adapter = _FakeDioAdapter(sse);
      final dio = Dio()..httpClientAdapter = adapter;
      final provider = MiniMaxProvider(
        apiKey: 'sk-fake',
        modelId: 'MiniMax-M2.7',
        contextWindow: 204800,
        dio: dio,
      );

      await provider
          .generateStream(
            request: GenerateRequest(
              messages: [_msg('ping')],
              enableReasoning: true, // pero el modelo no es M3
            ),
          )
          .toList();

      expect(adapter.lastRequestBody, isNotNull);
      expect(adapter.lastRequestBody!['reasoning_split'], false);
      expect(adapter.lastRequestBody!.containsKey('thinking'), isFalse);
    });
  });
}

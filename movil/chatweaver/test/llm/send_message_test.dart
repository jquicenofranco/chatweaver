import 'dart:async';

import 'package:chatweaver/context/context_window_manager.dart';
import 'package:chatweaver/llm/illm_provider.dart';
import 'package:chatweaver/llm/generate_request.dart';
import 'package:chatweaver/llm/generate_response.dart';
import 'package:chatweaver/session/domain/entities/chat_session.dart';
import 'package:chatweaver/session/domain/entities/model_definition.dart';
import 'package:chatweaver/session/domain/repositories/model_catalog_repository.dart';
import 'package:chatweaver/session/domain/repositories/sessions_repository.dart';
import 'package:chatweaver/session/domain/usecases/send_message.dart';
import 'package:chatweaver/message/domain/entities/message.dart' as m;
import 'package:chatweaver/message/domain/repositories/messages_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _MockProvider extends Mock implements ILLMProvider {}

class _MockSessions extends Mock implements SessionsRepository {}

class _MockMessages extends Mock implements MessagesRepository {}

class _MockModels extends Mock implements ModelCatalogRepository {}

class _FakeCancelToken extends Fake implements CancelToken {}

class _FakeMessage extends Fake implements m.Message {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeCancelToken());
    registerFallbackValue(GenerateRequest(messages: const []));
    registerFallbackValue(_FakeMessage());
  });

  group('SendMessage', () {
    late _MockProvider provider;
    late _MockSessions sessions;
    late _MockMessages messages;
    late _MockModels models;
    late SendMessage useCase;

    final session = ChatSession(
      id: 's1',
      title: 'Test',
      modelId: 'MiniMax-M3',
      providerId: 'MiniMax',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    // Default: M3 con supportsReasoning. Tests individuales pueden
    // sobreescribirlo.
    final m3Thinking = const ModelDefinition(
      id: 'MiniMax-M3',
      providerId: 'MiniMax',
      displayName: 'MiniMax M3',
      contextWindow: 1000000,
      supportsStreaming: true,
      supportsReasoning: true,
    );
    final m27NoThinking = const ModelDefinition(
      id: 'MiniMax-M2.7',
      providerId: 'MiniMax',
      displayName: 'MiniMax M2.7',
      contextWindow: 204800,
      supportsStreaming: true,
      supportsReasoning: false,
    );

    SendMessage buildUseCase() => SendMessage(
      provider: provider,
      sessions: sessions,
      messages: messages,
      models: models,
      context: ContextWindowManager(provider: provider, contextWindow: 200000),
      uuid: const Uuid(),
    );

    setUp(() {
      provider = _MockProvider();
      sessions = _MockSessions();
      messages = _MockMessages();
      models = _MockModels();
      useCase = buildUseCase();

      when(() => provider.calculateTokens(any())).thenReturn(1);
      when(() => sessions.getById('s1')).thenAnswer((_) async => session);
      when(
        () => models.getById('MiniMax-M3'),
      ).thenAnswer((_) async => m3Thinking);
      when(
        () => models.getById('MiniMax-M2.7'),
      ).thenAnswer((_) async => m27NoThinking);
      when(() => messages.listBySession('s1')).thenAnswer((_) async => []);
      when(() => messages.append(any())).thenAnswer((_) async {});
      when(() => messages.updateContent(any(), any())).thenAnswer((_) async {});
      when(
        () => messages.updateReasoning(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => messages.updateTokenUsage(
          any(),
          inputTokens: any(named: 'inputTokens'),
          outputTokens: any(named: 'outputTokens'),
          thinkingTokens: any(named: 'thinkingTokens'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => messages.updateStatus(
          any(),
          m.MessageStatus.streaming,
          error: any(named: 'error'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => messages.updateStatus(
          any(),
          m.MessageStatus.complete,
          error: any(named: 'error'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => messages.updateStatus(
          any(),
          m.MessageStatus.failed,
          error: any(named: 'error'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => messages.patch(any(), completedAt: any(named: 'completedAt')),
      ).thenAnswer((_) async {});
      when(() => sessions.touch(any(), any())).thenAnswer((_) async {});
      when(
        () => sessions.accumulateTokens(
          any(),
          input: any(named: 'input'),
          output: any(named: 'output'),
        ),
      ).thenAnswer((_) async {});
    });

    test('lanza SessionNotFoundException si la sesion no existe', () async {
      when(() => sessions.getById('missing')).thenAnswer((_) async => null);

      expect(
        () => useCase(sessionId: 'missing', userText: 'hola'),
        throwsA(isA<Exception>()),
      );
    });

    test('stream de texto actualiza el contenido y acumula tokens', () async {
      when(
        () => provider.generateStream(
          request: any(named: 'request'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) => Stream<GenerateResponseChunk>.fromIterable([
          const GenerateResponseChunk(textDelta: 'Hola '),
          const GenerateResponseChunk(textDelta: 'mundo'),
          const GenerateResponseChunk(
            usage: LlmUsage(inputTokens: 5, outputTokens: 2),
            finishReason: 'stop',
          ),
        ]),
      );

      await useCase(sessionId: 's1', userText: 'hola');

      verify(() => messages.append(any())).called(2);
      verify(() => messages.updateContent(any(), any())).called(2);
      verify(
        () => messages.updateTokenUsage(
          any(),
          inputTokens: 5,
          outputTokens: 2,
          // thinkingTokens: 0 porque el modelo no devolvio
          // reasoning_content en este test.
          thinkingTokens: 0,
        ),
      ).called(1);
      verify(
        () => sessions.accumulateTokens('s1', input: 5, output: 2),
      ).called(1);
    });

    test('mensaje fallido queda con status=failed y error', () async {
      when(
        () => provider.generateStream(
          request: any(named: 'request'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) => Stream<GenerateResponseChunk>.fromIterable([
          const GenerateResponseChunk(
            errorMessage: 'Token invalido o expirado',
          ),
        ]),
      );

      await expectLater(
        useCase(sessionId: 's1', userText: 'hola'),
        throwsA(isA<Exception>()),
      );

      verify(
        () => messages.updateStatus(
          any(),
          m.MessageStatus.failed,
          error: 'Token invalido o expirado',
        ),
      ).called(1);
    });

    test('stream con reasoning: persiste reasoning aparte del content '
        'y envia enableReasoning al provider', () async {
      // Capturamos el request para verificar que lleva
      // enableReasoning=true.
      GenerateRequest? captured;
      when(
        () => provider.generateStream(
          request: any(named: 'request'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((invocation) {
        captured = invocation.namedArguments[#request] as GenerateRequest;
        return Stream<GenerateResponseChunk>.fromIterable([
          const GenerateResponseChunk(reasoningDelta: 'Pensemos... '),
          const GenerateResponseChunk(reasoningDelta: '17 * 24 = 408.'),
          const GenerateResponseChunk(textDelta: 'La respuesta es '),
          const GenerateResponseChunk(textDelta: '408.'),
          const GenerateResponseChunk(
            usage: LlmUsage(
              inputTokens: 10,
              outputTokens: 5,
              thinkingTokens: 0, // provider no lo reporta
            ),
            finishReason: 'stop',
          ),
        ]);
      });

      await useCase(sessionId: 's1', userText: 'cuanto es 17*24?');

      // 1) El request llevaba enableReasoning=true (M3 lo soporta).
      expect(captured, isNotNull);
      expect(captured!.enableReasoning, isTrue);

      // 2) updateReasoning se llamo 2 veces con el buffer acumulado
      //    (los dos reasoningDeltas concatenados). Importante: el
      //    contenido del reasoning NO se mezcla con el content
      //    (C-BIZ-01).
      verify(
        () => messages.updateReasoning(any(), 'Pensemos... 17 * 24 = 408.'),
      ).called(1);

      // 3) updateContent se llamo 2 veces con el buffer de texto
      //    (los dos textDeltas concatenados).
      verify(
        () => messages.updateContent(any(), 'La respuesta es 408.'),
      ).called(1);

      // 4) updateTokenUsage recibe thinkingTokens estimado por
      //    length/4 (fallback OQ-02). 'Pensemos... 17 * 24 = 408.'
      //    tiene 28 chars, 28/4 = 7.
      verify(
        () => messages.updateTokenUsage(
          any(),
          inputTokens: 10,
          outputTokens: 5,
          thinkingTokens: 7,
        ),
      ).called(1);
    });

    test('modelo sin supportsReasoning envia enableReasoning=false', () async {
      // Override: la sesion apunta a M2.7 (no-thinking).
      final noThinkingSession = ChatSession(
        id: 's2',
        title: 'Test',
        modelId: 'MiniMax-M2.7',
        providerId: 'MiniMax',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      when(
        () => sessions.getById('s2'),
      ).thenAnswer((_) async => noThinkingSession);
      // Importante: la sesion es 's2', asi que listBySession
      // necesita estar mockeada para 's2' tambien.
      when(() => messages.listBySession('s2')).thenAnswer((_) async => []);

      GenerateRequest? captured;
      when(
        () => provider.generateStream(
          request: any(named: 'request'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((invocation) {
        captured = invocation.namedArguments[#request] as GenerateRequest;
        return Stream<GenerateResponseChunk>.fromIterable([
          const GenerateResponseChunk(textDelta: 'ok'),
          const GenerateResponseChunk(
            usage: LlmUsage(inputTokens: 1, outputTokens: 1),
            finishReason: 'stop',
          ),
        ]);
      });

      await useCase(sessionId: 's2', userText: 'hola');

      expect(captured, isNotNull);
      expect(captured!.enableReasoning, isFalse);
    });

    test('cancel del usuario: stream se cierra, status=complete y reasoning '
        'parcial persiste', () async {
      // El test simula el escenario de "abort mid-stream":
      // 1. El provider emite un chunk con reasoning.
      // 2. El stream se cierra (sin finishReason, sin error).
      // 3. El usuario aborto (cancelToken fue activado).
      //
      // En el codigo real, el cancelToken hace que la API HTTP
      // aborte, lo que causa que el stream se cierre. El use
      // case detecta esto y persiste el reasoning parcial.
      when(
        () => provider.generateStream(
          request: any(named: 'request'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((invocation) {
        // Stream que emite un chunk y luego se cierra (sin
        // error, sin finishReason) -- esto es lo que pasa cuando
        // el cancelToken aborta la request HTTP mid-stream.
        final controller = StreamController<GenerateResponseChunk>();
        controller.add(const GenerateResponseChunk(reasoningDelta: 'pensando'));
        Future.microtask(controller.close);
        return controller.stream;
      });

      // No esperamos que lance CancelToken (eso solo pasa si
      // usamos un HTTP real). Solo verificamos que el stream
      // se procesa y el estado queda consistente.
      await useCase(sessionId: 's1', userText: 'hola');

      // El reasoning parcial quedo persistido.
      verify(() => messages.updateReasoning(any(), 'pensando')).called(1);
      // El status quedo en complete (no failed) porque el
      // stream cerro normalmente (sin errorMessage en el chunk).
      verify(
        () => messages.updateStatus(
          any(),
          m.MessageStatus.complete,
          error: any(named: 'error'),
        ),
      ).called(greaterThanOrEqualTo(1));
    });
  });
}

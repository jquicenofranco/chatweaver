import 'package:chatweaver/context/context_window_manager.dart';
import 'package:chatweaver/llm/illm_provider.dart';
import 'package:chatweaver/llm/generate_request.dart';
import 'package:chatweaver/llm/generate_response.dart';
import 'package:chatweaver/session/domain/entities/chat_session.dart';
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
    late SendMessage useCase;

    final session = ChatSession(
      id: 's1',
      title: 'Test',
      modelId: 'MiniMax-M',
      providerId: 'MiniMax',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    setUp(() {
      provider = _MockProvider();
      sessions = _MockSessions();
      messages = _MockMessages();
      useCase = SendMessage(
        provider: provider,
        sessions: sessions,
        messages: messages,
        context: ContextWindowManager(
          provider: provider,
          contextWindow: 200000,
        ),
        uuid: const Uuid(),
      );

      when(() => provider.calculateTokens(any())).thenReturn(1);
      when(() => sessions.getById('s1')).thenAnswer((_) async => session);
      when(() => messages.listBySession('s1')).thenAnswer((_) async => []);
      when(() => messages.append(any())).thenAnswer((_) async {});
      when(() => messages.updateContent(any(), any()))
          .thenAnswer((_) async {});
      when(() => messages.updateTokenUsage(
            any(),
            inputTokens: any(named: 'inputTokens'),
            outputTokens: any(named: 'outputTokens'),
          )).thenAnswer((_) async {});
      when(() => messages.updateStatus(
            any(),
            m.MessageStatus.streaming,
            error: any(named: 'error'),
          )).thenAnswer((_) async {});
      when(() => messages.updateStatus(
            any(),
            m.MessageStatus.complete,
            error: any(named: 'error'),
          )).thenAnswer((_) async {});
      when(() => messages.updateStatus(
            any(),
            m.MessageStatus.failed,
            error: any(named: 'error'),
          )).thenAnswer((_) async {});
      when(() => messages.patch(any(), completedAt: any(named: 'completedAt')))
          .thenAnswer((_) async {});
      when(() => sessions.touch(any(), any())).thenAnswer((_) async {});
      when(() => sessions.accumulateTokens(
            any(),
            input: any(named: 'input'),
            output: any(named: 'output'),
          )).thenAnswer((_) async {});
    });

    test('lanza SessionNotFoundException si la sesion no existe', () async {
      when(() => sessions.getById('missing')).thenAnswer((_) async => null);

      expect(
        () => useCase(sessionId: 'missing', userText: 'hola'),
        throwsA(isA<Exception>()),
      );
    });

    test('stream de texto actualiza el contenido y acumula tokens', () async {
      when(() => provider.generateStream(
            request: any(named: 'request'),
            cancelToken: any(named: 'cancelToken'),
          )).thenAnswer(
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
      verify(() => messages.updateTokenUsage(
            any(),
            inputTokens: 5,
            outputTokens: 2,
          )).called(1);
      verify(() => sessions.accumulateTokens(
            's1',
            input: 5,
            output: 2,
          )).called(1);
    });

    test('mensaje fallido queda con status=failed y error', () async {
      when(() => provider.generateStream(
            request: any(named: 'request'),
            cancelToken: any(named: 'cancelToken'),
          )).thenAnswer(
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

      verify(() => messages.updateStatus(
            any(),
            m.MessageStatus.failed,
            error: 'Token invalido o expirado',
          )).called(1);
    });
  });
}

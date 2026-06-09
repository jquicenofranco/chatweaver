import 'package:chatweaver/db/credential_handle.dart';
import 'package:chatweaver/di/global_providers.dart';
import 'package:chatweaver/llm/illm_provider.dart';
import 'package:chatweaver/llm/llm_factory.dart';
import 'package:chatweaver/ui/chat/chat_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLlmProvider extends Mock implements ILLMProvider {}

/// Regresion del bug que reporto el usuario:
///
/// `"Bad state: No se pudo resolver el provider LLM para <sessionId>"`
///
/// El `ChatController` se construia sincrónicamente leyendo
/// `sendMessageProvider(sessionId)`, que a su vez leia
/// `activeLlmProviderProvider(sessionId).valueOrNull`. Para un
/// `sessionId` nuevo ese FutureProvider estaba en loading, asi que
/// `valueOrNull` era `null` y se lanzaba `StateError` reventando la UI.
///
/// El fix mueve la resolucion de `SendMessage` adentro de `send()`
/// (lazy), propagando errores a `ChatState.error` en vez de throwear.
void main() {
  late _MockLlmProvider llmProvider;
  late CredentialHandle credential;

  setUp(() {
    llmProvider = _MockLlmProvider();
    credential = CredentialHandle(
      id: 'cred-1',
      providerId: 'MiniMax',
      label: 'Default',
      secureKey: 'chatweaver_cred-1',
      createdAt: DateTime(2026),
    );
    when(() => llmProvider.contextWindow).thenReturn(1000000);
  });

  ProviderContainer makeContainer({
    Duration activeProviderDelay = Duration.zero,
    ActiveCredential? credentialToReturn,
  }) {
    return ProviderContainer(
      overrides: [
        // Resolucion del provider LLM con un delay configurable para
        // simular el estado "loading" que tenia el bug.
        activeLlmProviderProvider.overrideWith((ref, sessionId) async {
          if (activeProviderDelay > Duration.zero) {
            await Future<void>.delayed(activeProviderDelay);
          }
          return llmProvider;
        }),
        activeCredentialForProviderProvider.overrideWith(
          (ref, providerId) async => credentialToReturn,
        ),
        // Repos no-op: el controller no llega a usarlos en estos tests.
        sessionsRepositoryProvider.overrideWith((ref) {
          throw UnimplementedError('not used in this test');
        }),
        messagesRepositoryProvider.overrideWith((ref) {
          throw UnimplementedError('not used in this test');
        }),
        modelCatalogRepositoryProvider.overrideWith((ref) {
          throw UnimplementedError('not used in this test');
        }),
        llmProviderFactoryProvider.overrideWith((ref) {
          return _ThrowingFactory();
        }),
      ],
    );
  }

  test(
      'ChatController se construye sin throw aunque activeLlmProviderProvider '
      'este en loading (regresion del "Bad state")',
      () async {
    final container = makeContainer(
      activeProviderDelay: const Duration(milliseconds: 50),
      credentialToReturn: ActiveCredential(
        handle: credential,
        apiKey: 'sk-test',
      ),
    );
    addTearDown(container.dispose);

    // Antes del fix esta linea lanzaba
    // `StateError: No se pudo resolver el provider LLM para s1`.
    final controller = container.read(chatControllerProvider('s1').notifier);

    expect(controller, isNotNull);
    expect(controller.state.isStreaming, isFalse);
    expect(controller.state.error, isNull);
  });

  test(
      'ChatController.send() propaga a state.error si la resolucion falla '
      '(en vez de throwear)',
      () async {
    final container = makeContainer(
      credentialToReturn: null, // sin credencial -> falla la resolucion
    );
    addTearDown(container.dispose);

    final controller = container.read(chatControllerProvider('s1').notifier);

    // No debe throwear. Antes, si la resolucion fallaba (o el
    // provider estaba loading), el controller reventaba la UI.
    await controller.send('hola');

    expect(controller.state.isStreaming, isFalse);
    expect(controller.state.error, isNotNull,
        reason: 'El error debe quedar en state.error, no en un throw.');
  });
}

/// Factory de ILLMProvider que nunca se invoca en estos tests
/// (sobreescribimos `activeLlmProviderProvider` directo). Lanzar
/// aqui es una salvaguarda para detectar regresiones.
class _ThrowingFactory extends LLMFactory {
  @override
  ILLMProvider build({
    required String providerId,
    required String modelId,
    required String apiKey,
    required int contextWindow,
    required Dio dio,
  }) {
    throw UnimplementedError(
      'Estos tests no deben pasar por LLMFactory.build — '
      'se sobreescribe activeLlmProviderProvider directamente.',
    );
  }
}

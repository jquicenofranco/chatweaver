import 'package:chatweaver/db/app_database.dart';
import 'package:chatweaver/db/credential_handle.dart';
import 'package:chatweaver/db/credential_repository.dart';
import 'package:chatweaver/di/global_providers.dart';
import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/llm/illm_provider.dart';
import 'package:chatweaver/llm/llm_factory.dart';
import 'package:chatweaver/session/domain/entities/model_definition.dart';
import 'package:chatweaver/session/domain/repositories/model_catalog_repository.dart';
import 'package:chatweaver/ui/home/token_input_screen.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockModelCatalogRepository extends Mock
    implements ModelCatalogRepository {}

class _MockCredentialRepository extends Mock implements CredentialRepository {}

class _MockLlmProvider extends Mock implements ILLMProvider {}

class _StubLlmFactory extends LLMFactory {
  _StubLlmFactory(ILLMProvider provider) : _provider = provider;

  final ILLMProvider _provider;

  @override
  ILLMProvider build({
    required String providerId,
    required String modelId,
    required String apiKey,
    required int contextWindow,
    required Dio dio,
  }) {
    return _provider;
  }
}

/// Tests de TokenInputScreen (spec 04 v2.0.0).
///
/// Cobertura:
/// - Recibe `providerId` por constructor y lo muestra en el header.
/// - Tap "back" navega a /providers.
/// - Submit con API key valido navega a /models?providerId=... y
///   guarda la credencial asociada al providerId.
void main() {
  late _MockModelCatalogRepository modelRepo;
  late _MockCredentialRepository credentialRepo;
  late _MockLlmProvider llmProvider;
  late GoRouter router;
  late AppDatabase testDb;

  setUpAll(() {
    registerFallbackValue(
      CredentialHandle(
        id: 'fallback',
        providerId: 'MiniMax',
        label: 'fallback',
        secureKey: 'k',
        createdAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    testDb = AppDatabase.forTesting(NativeDatabase.memory());
    modelRepo = _MockModelCatalogRepository();
    credentialRepo = _MockCredentialRepository();
    llmProvider = _MockLlmProvider();
    when(() => modelRepo.listEnabledByProvider('MiniMax')).thenAnswer(
      (_) async => const [
        ModelDefinition(
          id: 'MiniMax-M3',
          providerId: 'MiniMax',
          displayName: 'M3',
          contextWindow: 200000,
        ),
      ],
    );
    when(
      () => llmProvider.testConnection(apiKey: any(named: 'apiKey')),
    ).thenAnswer((_) async => null);
    when(() => credentialRepo.save(any(), any())).thenAnswer((_) async {});
    when(() => credentialRepo.setActive(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await testDb.close();
  });

  Widget pumpScreen({String providerId = 'MiniMax'}) {
    router = GoRouter(
      initialLocation: '/token?providerId=$providerId',
      routes: [
        GoRoute(
          path: '/token',
          builder: (_, state) => TokenInputScreen(
            providerId: state.uri.queryParameters['providerId'] ?? '',
          ),
        ),
        GoRoute(
          path: '/providers',
          builder: (_, state) => const Scaffold(body: Text('PROVIDERS')),
        ),
        GoRoute(
          path: '/models',
          builder: (_, state) => Scaffold(
            body: Text('MODELS:${state.uri.queryParameters['providerId']}'),
          ),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWith((ref) {
          ref.onDispose(testDb.close);
          return testDb;
        }),
        modelCatalogRepositoryProvider.overrideWith((ref) => modelRepo),
        credentialRepositoryProvider.overrideWith((ref) => credentialRepo),
        llmProviderFactoryProvider.overrideWith(
          (ref) => _StubLlmFactory(llmProvider),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        // Forzamos locale `en` para que los strings visibles
        // ("Test and continue", "Back") coincidan con las
        // aserciones en este test.
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  testWidgets('muestra el providerId recibido en el header', (tester) async {
    await tester.pumpWidget(pumpScreen(providerId: 'MiniMax'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // El header incluye el providerId ("Provider: MiniMax" en en).
    expect(find.textContaining('MiniMax'), findsWidgets);
  });

  testWidgets('tap en el back button navega a /providers', (tester) async {
    await tester.pumpWidget(pumpScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // El back button tiene tooltip "Back" (en).
    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('PROVIDERS'), findsOneWidget);
  });

  testWidgets(
    'submit con key valida navega a /models?providerId=... (no /token)',
    (tester) async {
      await tester.pumpWidget(pumpScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Pegar key en el TextField.
      await tester.enterText(find.byType(TextField), 'sk-test-valid');
      await tester.pump();
      // Tap en el boton "Test and continue" (en).
      await tester.tap(find.text('Test and continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('MODELS:MiniMax'), findsOneWidget);
      verify(
        () => llmProvider.testConnection(apiKey: 'sk-test-valid'),
      ).called(1);
    },
  );
}

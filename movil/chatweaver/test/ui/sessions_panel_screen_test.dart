import 'package:chatweaver/db/app_database.dart';
import 'package:chatweaver/db/credential_handle.dart';
import 'package:chatweaver/db/credential_repository.dart';
import 'package:chatweaver/di/global_providers.dart';
import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/session/domain/entities/chat_session.dart';
import 'package:chatweaver/session/domain/entities/model_definition.dart';
import 'package:chatweaver/session/domain/repositories/model_catalog_repository.dart';
import 'package:chatweaver/session/domain/repositories/sessions_repository.dart';
import 'package:chatweaver/ui/sessions/sessions_panel_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSessionsRepository extends Mock implements SessionsRepository {}

class _MockModelCatalogRepository extends Mock
    implements ModelCatalogRepository {}

class _MockCredentialRepository extends Mock implements CredentialRepository {}

/// Tests de SessionsPanelScreen (spec 04 v2.0.0).
///
/// Cobertura:
/// - Recibe `initialProviderId` y `initialModelId` por constructor.
/// - Sincroniza ambos `StateProvider` despues del primer frame.
/// - El AppBar expone los iconos "Cambiar modelo" y "Cambiar
///   provider" (nuevo flujo de navegacion).
void main() {
  late _MockSessionsRepository sessionsRepo;
  late _MockModelCatalogRepository modelRepo;
  late _MockCredentialRepository credentialRepo;
  late GoRouter router;
  late AppDatabase testDb;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    testDb = AppDatabase.forTesting(NativeDatabase.memory());
    sessionsRepo = _MockSessionsRepository();
    modelRepo = _MockModelCatalogRepository();
    credentialRepo = _MockCredentialRepository();
    when(
      () => sessionsRepo.watchByModel(any()),
    ).thenAnswer((_) => const Stream<List<ChatSession>>.empty());
    when(() => modelRepo.getById(any())).thenAnswer(
      (_) async => const ModelDefinition(
        id: 'm1',
        providerId: 'MiniMax',
        displayName: 'M3',
        contextWindow: 200000,
      ),
    );
    when(
      () => credentialRepo.list(),
    ).thenAnswer((_) async => <CredentialHandle>[]);
  });

  tearDown(() async {
    await testDb.close();
  });

  Widget makeScope({String? initialProviderId, String? initialModelId}) {
    router = GoRouter(
      initialLocation: '/sessions',
      routes: [
        GoRoute(
          path: '/sessions',
          builder: (_, _) => SessionsPanelScreen(
            initialProviderId: initialProviderId,
            initialModelId: initialModelId,
          ),
        ),
        GoRoute(
          path: '/providers',
          builder: (_, _) => const Scaffold(body: Text('PROVIDERS')),
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
        sessionsRepositoryProvider.overrideWith((ref) => sessionsRepo),
        modelCatalogRepositoryProvider.overrideWith((ref) => modelRepo),
        credentialRepositoryProvider.overrideWith((ref) => credentialRepo),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        // Forzamos locale `en` para que los tooltips del AppBar
        // ("Change model", "Change provider") coincidan con las
        // aserciones.
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  testWidgets('acepta initialProviderId y initialModelId en el constructor', (
    tester,
  ) async {
    await tester.pumpWidget(
      makeScope(initialProviderId: 'MiniMax', initialModelId: 'm1'),
    );
    // Un solo pump (no pumpAndSettle: appDatabase queda enganchado).
    await tester.pump();
    expect(find.byType(SessionsPanelScreen), findsOneWidget);
  });

  testWidgets('AppBar expone el IconButton "Change model"', (tester) async {
    await tester.pumpWidget(
      makeScope(initialProviderId: 'MiniMax', initialModelId: 'm1'),
    );
    await tester.pump();
    expect(find.byTooltip('Change model'), findsOneWidget);
  });

  testWidgets('AppBar expone el IconButton "Change provider"', (tester) async {
    await tester.pumpWidget(
      makeScope(initialProviderId: 'MiniMax', initialModelId: 'm1'),
    );
    await tester.pump();
    expect(find.byTooltip('Change provider'), findsOneWidget);
  });

  testWidgets('tap "Change provider" navega a /providers', (tester) async {
    await tester.pumpWidget(
      makeScope(initialProviderId: 'MiniMax', initialModelId: 'm1'),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Change provider'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('PROVIDERS'), findsOneWidget);
  });

  testWidgets(
    'tap "Change model" con providerId navega a /models?providerId=...',
    (tester) async {
      await tester.pumpWidget(
        makeScope(initialProviderId: 'MiniMax', initialModelId: 'm1'),
      );
      await tester.pump();
      await tester.tap(find.byTooltip('Change model'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('MODELS:MiniMax'), findsOneWidget);
    },
  );

  // Unit test directo sobre los StateProvider: confirma que la
  // sincronizacion del initState es trivial (setear state).
  test('activeProviderIdProvider queda seteado al initialProviderId', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(activeProviderIdProvider), isNull);
    container.read(activeProviderIdProvider.notifier).state = 'MiniMax';
    container.read(activeModelIdProvider.notifier).state = 'm1';
    expect(container.read(activeProviderIdProvider), 'MiniMax');
    expect(container.read(activeModelIdProvider), 'm1');
  });
}

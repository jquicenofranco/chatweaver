import 'package:chatweaver/di/global_providers.dart';
import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/session/domain/entities/model_definition.dart';
import 'package:chatweaver/session/domain/repositories/model_catalog_repository.dart';
import 'package:chatweaver/ui/home/model_selector_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockModelCatalogRepository extends Mock
    implements ModelCatalogRepository {}

/// Tests de ModelSelectorScreen (spec 04 v2.0.0).
///
/// Cobertura:
/// - Si NO llega `providerId`, lista TODOS los modelos
///   habilitados (`listEnabled`).
/// - Si llega `providerId`, filtra por provider
///   (`listEnabledByProvider`).
/// - Tap en modelo navega a `/sessions?providerId=...&modelId=...`.
void main() {
  late _MockModelCatalogRepository modelRepo;
  late GoRouter router;

  setUp(() {
    modelRepo = _MockModelCatalogRepository();
  });

  Widget pumpScreen({String? providerId}) {
    final initialLoc = providerId == null
        ? '/models'
        : '/models?providerId=$providerId';
    router = GoRouter(
      initialLocation: initialLoc,
      routes: [
        GoRoute(
          path: '/models',
          builder: (_, state) => ModelSelectorScreen(
            initialProviderId: state.uri.queryParameters['providerId'],
          ),
        ),
        GoRoute(
          path: '/sessions',
          builder: (_, state) => Scaffold(
            body: Text(
              'SESSIONS:provider=${state.uri.queryParameters['providerId']}'
              '&model=${state.uri.queryParameters['modelId']}',
            ),
          ),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        modelCatalogRepositoryProvider.overrideWith((ref) => modelRepo),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  testWidgets(
    'SIN providerId usa listEnabled() (fallback / deep link directo)',
    (tester) async {
      when(() => modelRepo.listEnabled()).thenAnswer(
        (_) async => const [
          ModelDefinition(
            id: 'm1',
            providerId: 'MiniMax',
            displayName: 'M3',
            contextWindow: 200000,
          ),
        ],
      );
      await tester.pumpWidget(pumpScreen());
      await tester.pumpAndSettle();

      expect(find.text('M3'), findsOneWidget);
      verify(() => modelRepo.listEnabled()).called(1);
      verifyNever(() => modelRepo.listEnabledByProvider(any()));
    },
  );

  testWidgets('CON providerId filtra con listEnabledByProvider(providerId)', (
    tester,
  ) async {
    when(() => modelRepo.listEnabledByProvider('MiniMax')).thenAnswer(
      (_) async => const [
        ModelDefinition(
          id: 'm1',
          providerId: 'MiniMax',
          displayName: 'M3',
          contextWindow: 200000,
        ),
        ModelDefinition(
          id: 'm2',
          providerId: 'MiniMax',
          displayName: 'M2.7',
          contextWindow: 128000,
        ),
      ],
    );
    await tester.pumpWidget(pumpScreen(providerId: 'MiniMax'));
    await tester.pumpAndSettle();

    expect(find.text('M3'), findsOneWidget);
    expect(find.text('M2.7'), findsOneWidget);
    verify(() => modelRepo.listEnabledByProvider('MiniMax')).called(1);
    verifyNever(() => modelRepo.listEnabled());
  });

  testWidgets(
    'tap en un modelo navega a /sessions?providerId=...&modelId=...',
    (tester) async {
      when(() => modelRepo.listEnabledByProvider('MiniMax')).thenAnswer(
        (_) async => const [
          ModelDefinition(
            id: 'm1',
            providerId: 'MiniMax',
            displayName: 'M3',
            contextWindow: 200000,
          ),
        ],
      );
      await tester.pumpWidget(pumpScreen(providerId: 'MiniMax'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('M3'));
      await tester.pumpAndSettle();

      expect(
        find.text('SESSIONS:provider=MiniMax&model=m1'),
        findsOneWidget,
        reason: 'spec 04 v2.0.0: deep link propaga providerId + modelId',
      );
    },
  );
}

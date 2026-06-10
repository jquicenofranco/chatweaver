import 'package:chatweaver/db/credential_handle.dart';
import 'package:chatweaver/db/credential_repository.dart';
import 'package:chatweaver/di/global_providers.dart';
import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/llm/llm_factory.dart';
import 'package:chatweaver/ui/home/provider_selector_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockCredentialRepository extends Mock implements CredentialRepository {}

class _StubLlmFactory extends LLMFactory {
  _StubLlmFactory(this._ids);
  final List<String> _ids;

  @override
  List<String> get supportedProviders => _ids;
}

/// Tests de ProviderSelectorScreen (spec 04 v2.0.0).
///
/// Cobertura:
/// - Lista los providers del factory.
/// - Muestra badge "Conectado" si hay credencial para el provider.
/// - Tap en provider SIN credencial navega a `/token?providerId=...`.
/// - Tap en provider CON credencial navega a `/models?providerId=...`.
void main() {
  late _MockCredentialRepository credentialRepo;
  late GoRouter router;

  setUp(() {
    credentialRepo = _MockCredentialRepository();
    // Stub de `read` para `list()`. Por default: sin credenciales.
    when(
      () => credentialRepo.list(),
    ).thenAnswer((_) async => <CredentialHandle>[]);
  });

  Widget pumpScreen(List<String> providerIds) {
    router = GoRouter(
      initialLocation: '/providers',
      routes: [
        GoRoute(
          path: '/providers',
          builder: (_, _) => const ProviderSelectorScreen(),
        ),
        GoRoute(
          path: '/models',
          builder: (_, state) => Scaffold(
            body: Text('models:${state.uri.queryParameters['providerId']}'),
          ),
        ),
        GoRoute(
          path: '/token',
          builder: (_, state) => Scaffold(
            body: Text('token:${state.uri.queryParameters['providerId']}'),
          ),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        llmProviderFactoryProvider.overrideWith(
          (ref) => _StubLlmFactory(providerIds),
        ),
        credentialRepositoryProvider.overrideWith((ref) => credentialRepo),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  testWidgets('lista el provider del catalogo del factory', (tester) async {
    await tester.pumpWidget(pumpScreen(const ['MiniMax']));
    await tester.pumpAndSettle();

    expect(find.text('MiniMax'), findsOneWidget);
  });

  testWidgets('muestra badge "Not configured" cuando no hay credencial', (
    tester,
  ) async {
    await tester.pumpWidget(pumpScreen(const ['MiniMax']));
    await tester.pumpAndSettle();

    // El test corre con `Locale.en_US` por defecto, por lo que
    // `AppLocalizations.of(context)` resuelve al paquete en.
    expect(find.text('Not configured'), findsOneWidget);
    expect(find.text('Connected'), findsNothing);
  });

  testWidgets(
    'muestra badge "Connected" cuando hay credencial para el provider',
    (tester) async {
      when(() => credentialRepo.list()).thenAnswer(
        (_) async => [
          CredentialHandle(
            id: 'MiniMax-default',
            providerId: 'MiniMax',
            label: 'Default',
            secureKey: 'k',
            createdAt: DateTime(2026),
          ),
        ],
      );
      await tester.pumpWidget(pumpScreen(const ['MiniMax']));
      await tester.pumpAndSettle();

      expect(find.text('Connected'), findsOneWidget);
    },
  );

  testWidgets('tap en provider sin credencial navega a /token?providerId=...', (
    tester,
  ) async {
    await tester.pumpWidget(pumpScreen(const ['MiniMax']));
    await tester.pumpAndSettle();

    await tester.tap(find.text('MiniMax'));
    await tester.pumpAndSettle();

    expect(find.text('token:MiniMax'), findsOneWidget);
  });

  testWidgets(
    'tap en provider con credencial navega a /models?providerId=...',
    (tester) async {
      when(() => credentialRepo.list()).thenAnswer(
        (_) async => [
          CredentialHandle(
            id: 'MiniMax-default',
            providerId: 'MiniMax',
            label: 'Default',
            secureKey: 'k',
            createdAt: DateTime(2026),
          ),
        ],
      );
      await tester.pumpWidget(pumpScreen(const ['MiniMax']));
      await tester.pumpAndSettle();

      await tester.tap(find.text('MiniMax'));
      await tester.pumpAndSettle();

      expect(find.text('models:MiniMax'), findsOneWidget);
    },
  );
}

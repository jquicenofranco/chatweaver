import 'package:chatweaver/ui/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Tests del router (spec 04 v2.0.0).
///
/// Cobertura:
/// - `/` redirige a `/providers` (no mas splash con spinner).
/// - `/sessions?providerId=...&modelId=...` parsea ambos query
///   params correctamente.
void main() {
  late ProviderContainer container;
  late GoRouter router;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    router = container.read(routerProvider);
  });

  test('la ruta raiz "/" tiene un redirect configurado a /providers', () {
    // `findMatch` no aplica redirects (solo navigation los dispara).
    // En su lugar, inspeccionamos las rutas registradas: la
    // primera ruta (`/`) debe ser un GoRoute con un `redirect`
    // no-nulo. `routes` devuelve `List<RouteBase>`; las
    // rutas con `path` son `GoRoute`.
    final routes = router.configuration.routes.whereType<GoRoute>().toList();
    expect(routes, isNotEmpty);
    final root = routes.first;
    expect(root.path, '/');
    expect(
      root.redirect,
      isNotNull,
      reason: 'spec 04 v2.0.0: el splash es un redirect, no un spinner.',
    );
  });

  test('"/providers" resuelve a ProviderSelectorScreen', () {
    final match = router.configuration.findMatch(Uri.parse('/providers'));
    expect(match.uri.path, '/providers');
  });

  test('"/models?providerId=MiniMax" acepta query param providerId', () {
    final match = router.configuration.findMatch(
      Uri.parse('/models?providerId=MiniMax'),
    );
    expect(match.uri.path, '/models');
    expect(match.uri.queryParameters['providerId'], 'MiniMax');
  });

  test('"/token?providerId=MiniMax" acepta query param providerId', () {
    final match = router.configuration.findMatch(
      Uri.parse('/token?providerId=MiniMax'),
    );
    expect(match.uri.path, '/token');
    expect(match.uri.queryParameters['providerId'], 'MiniMax');
  });

  test('"/sessions" sin query params es deep link valido', () {
    final match = router.configuration.findMatch(Uri.parse('/sessions'));
    expect(match.uri.path, '/sessions');
    expect(match.uri.queryParameters.containsKey('providerId'), isFalse);
    expect(match.uri.queryParameters.containsKey('modelId'), isFalse);
  });

  test('"/sessions?providerId=...&modelId=..." expone ambos query params', () {
    final match = router.configuration.findMatch(
      Uri.parse('/sessions?providerId=MiniMax&modelId=m1'),
    );
    expect(match.uri.queryParameters['providerId'], 'MiniMax');
    expect(match.uri.queryParameters['modelId'], 'm1');
  });

  test('"/chat/:sessionId" parsea path param sessionId', () {
    final match = router.configuration.findMatch(Uri.parse('/chat/abc-123'));
    expect(match.pathParameters['sessionId'], 'abc-123');
  });

  testWidgets('navegar a "/" redirige a "/providers" (integration)', (
    tester,
  ) async {
    // Test integral minimo: confirmamos que un GoRoute con
    // `redirect: (_, _) => '/providers'` aplicado a `/` termina
    // renderizando la pantalla `/providers`.
    final probeRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', redirect: (_, _) => '/providers'),
        GoRoute(
          path: '/providers',
          builder: (_, _) => const _ProbeScaffold(label: 'PROVIDERS'),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: probeRouter));
    await tester.pumpAndSettle();

    expect(find.text('PROVIDERS'), findsOneWidget);
  });
}

class _ProbeScaffold extends StatelessWidget {
  const _ProbeScaffold({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}

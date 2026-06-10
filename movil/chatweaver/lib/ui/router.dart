import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:chatweaver/ui/chat/chat_screen.dart';
import 'package:chatweaver/ui/home/model_selector_screen.dart';
import 'package:chatweaver/ui/home/provider_selector_screen.dart';
import 'package:chatweaver/ui/home/token_input_screen.dart';
import 'package:chatweaver/ui/sessions/sessions_panel_screen.dart';
import 'package:chatweaver/ui/settings/settings_screen.dart';

/// Router de la app. SplashRoute siempre redirige a `/providers`
/// (spec 04 v2.0.0): el usuario pasa por la seleccion de
/// provider para poder cambiarlo con un solo tap, incluso si ya
/// tiene credenciales guardadas.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const _SplashRoute()),
      GoRoute(
        path: '/providers',
        builder: (context, state) => const ProviderSelectorScreen(),
      ),
      GoRoute(
        path: '/models',
        builder: (context, state) {
          final providerId = state.uri.queryParameters['providerId'];
          return ModelSelectorScreen(initialProviderId: providerId);
        },
      ),
      GoRoute(
        path: '/token',
        builder: (context, state) {
          // spec 04 v2.0.0: TokenInputScreen recibe providerId
          // (no modelId). El test de conexion usa el primer
          // modelo del catalogo del provider.
          final providerId = state.uri.queryParameters['providerId'] ?? '';
          return TokenInputScreen(providerId: providerId);
        },
      ),
      GoRoute(
        path: '/sessions',
        builder: (context, state) {
          final modelId = state.uri.queryParameters['modelId'];
          return SessionsPanelScreen(initialModelId: modelId);
        },
      ),
      GoRoute(
        path: '/chat/:sessionId',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId'] ?? '';
          return ChatScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class _SplashRoute extends ConsumerWidget {
  const _SplashRoute();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // spec 04 v2.0.0 §3.2: el redirect del splash va a
    // `/providers` siempre. La seleccion del provider es el
    // primer paso del onboarding, antes de validar si hay
    // credenciales. Asi el usuario puede cambiar de provider
    // con un solo tap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.go('/providers');
    });
    return const _SplashView();
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF6750A4),
      child: Center(child: CircularProgressIndicator(color: Color(0xFFFFFFFF))),
    );
  }
}

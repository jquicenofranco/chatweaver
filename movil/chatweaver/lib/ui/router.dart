import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:chatweaver/di/global_providers.dart';
import 'package:chatweaver/ui/chat/chat_screen.dart';
import 'package:chatweaver/ui/home/model_selector_screen.dart';
import 'package:chatweaver/ui/home/token_input_screen.dart';
import 'package:chatweaver/ui/sessions/sessions_panel_screen.dart';
import 'package:chatweaver/ui/settings/settings_screen.dart';

/// Router de la app. SplashRoute decide entre `/models` y
/// `/sessions` segun si hay credenciales.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const _SplashRoute(),
      ),
      GoRoute(
        path: '/models',
        builder: (context, state) => const ModelSelectorScreen(),
      ),
      GoRoute(
        path: '/token',
        builder: (context, state) {
          final modelId = state.uri.queryParameters['modelId'] ?? '';
          return TokenInputScreen(modelId: modelId);
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
    final hasAny = ref.watch(hasAnyCredentialProvider);
    return hasAny.when(
      data: (has) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          context.go(has ? '/sessions' : '/models');
        });
        return const _SplashView();
      },
      loading: () => const _SplashView(),
      error: (_, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          context.go('/models');
        });
        return const _SplashView();
      },
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF6750A4),
      child: Center(
        child: CircularProgressIndicator(color: Color(0xFFFFFFFF)),
      ),
    );
  }
}

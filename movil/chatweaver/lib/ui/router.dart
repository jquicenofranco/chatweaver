import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:chatweaver/ui/chat/chat_screen.dart';
import 'package:chatweaver/ui/home/model_selector_screen.dart';
import 'package:chatweaver/ui/home/provider_selector_screen.dart';
import 'package:chatweaver/ui/home/token_input_screen.dart';
import 'package:chatweaver/ui/sessions/sessions_panel_screen.dart';
import 'package:chatweaver/ui/settings/settings_screen.dart';

/// Router de la app. La ruta `/` redirige a `/providers` siempre
/// (spec 04 v2.0.0): el usuario pasa por la seleccion de
/// provider para poder cambiarlo con un solo tap, incluso si ya
/// tiene credenciales guardadas.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // spec 04 v2.0.0 §3.2: la seleccion del provider es el primer
      // paso del onboarding, antes de validar si hay credenciales.
      // Asi el usuario puede cambiar de provider con un solo tap.
      GoRoute(path: '/', redirect: (_, _) => '/providers'),
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
          // spec 04 v2.0.0: /sessions recibe providerId + modelId.
          // Ambos son opcionales (modo deep link / fallback).
          final providerId = state.uri.queryParameters['providerId'];
          final modelId = state.uri.queryParameters['modelId'];
          return SessionsPanelScreen(
            initialProviderId: providerId,
            initialModelId: modelId,
          );
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

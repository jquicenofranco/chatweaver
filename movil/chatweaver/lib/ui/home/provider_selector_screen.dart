import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:chatweaver/di/global_providers.dart';
import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/llm/provider_definition.dart';
import 'package:chatweaver/ui/shared/empty_state_view.dart';
import 'package:chatweaver/ui/shared/error_view.dart';

/// Pantalla de seleccion de proveedor (spec 04 v2.0.0 §4.1).
///
/// Es el nuevo punto de entrada del flujo de onboarding:
/// splash redirige a `/providers` siempre (incluso si ya hay
/// credenciales), para que el usuario pueda cambiar de provider
/// con un solo tap.
class ProviderSelectorScreen extends ConsumerWidget {
  const ProviderSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final providers = ref.watch(availableProvidersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.providerSelectorTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: providers.isEmpty
          ? EmptyStateView(
              icon: Icons.cloud_off_outlined,
              message: l10n.modelSelectorEmpty,
              actionLabel: l10n.modelSelectorGoToSettings,
              onAction: () => context.push('/settings'),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: providers.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) =>
                  _ProviderCard(provider: providers[i]),
            ),
    );
  }
}

class _ProviderCard extends ConsumerWidget {
  const _ProviderCard({required this.provider});

  final ProviderDefinition provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // Badge "Conectado / Sin configurar". `family(providerId)` se
    // invalida automaticamente al cambiar el provider (Riverpod
    // detecta el cambio de parametro y re-emite).
    final hasCredAsync = ref.watch(
      hasAnyCredentialForProviderProvider(provider.id),
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(Icons.cloud_outlined, color: theme.colorScheme.primary),
      ),
      title: Text(provider.name, style: theme.textTheme.titleMedium),
      subtitle: provider.description == null
          ? null
          : Text(provider.description!),
      trailing: hasCredAsync.when(
        data: (has) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: (has ? Colors.green : theme.colorScheme.outline).withValues(
              alpha: 0.15,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            has
                ? l10n.providerSelectorHasCredential
                : l10n.providerSelectorNoCredential,
            style: TextStyle(
              color: has ? Colors.green : theme.colorScheme.outline,
              fontSize: 12,
            ),
          ),
        ),
        loading: () => const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (e, _) => ErrorView(message: e.toString()),
      ),
      onTap: () async {
        // Decidir siguiente ruta segun si ya hay credencial
        // (spec 04 §4.1): "tap en ProviderCard → consulta
        // hasAnyCredentialForProviderProvider(providerId):
        //   - Si tiene credencial → /models?providerId=...
        //   - Si no → /token?providerId=..."
        final has = await ref.read(
          hasAnyCredentialForProviderProvider(provider.id).future,
        );
        if (!context.mounted) return;
        if (has) {
          context.go('/models?providerId=${provider.id}');
        } else {
          context.go('/token?providerId=${provider.id}');
        }
      },
    );
  }
}

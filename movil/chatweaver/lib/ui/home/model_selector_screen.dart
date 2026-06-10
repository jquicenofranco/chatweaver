import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:chatweaver/di/global_providers.dart';
import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/session/domain/entities/model_definition.dart';
import 'package:chatweaver/ui/shared/empty_state_view.dart';
import 'package:chatweaver/ui/shared/error_view.dart';

/// Pantalla de seleccion de modelo.
///
/// **Spec 04 v2.0.0**: se llega desde ProviderSelector (no es
/// el entry point del flujo). Filtra por `providerId` cuando
/// viene como query param; si no viene, muestra todos los
/// modelos habilitados (modo legacy / fallback).
class ModelSelectorScreen extends ConsumerWidget {
  const ModelSelectorScreen({super.key, this.initialProviderId});

  final String? initialProviderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final modelsAsync = ref.watch(_modelsProvider(initialProviderId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.modelSelectorTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.commonBack,
          onPressed: () => context.go('/providers'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: modelsAsync.when(
        data: (models) {
          if (models.isEmpty) {
            return EmptyStateView(
              icon: Icons.psychology_outlined,
              message: l10n.modelSelectorEmpty,
              actionLabel: l10n.modelSelectorGoToSettings,
              onAction: () => context.push('/settings'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: models.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) => _ModelCard(model: models[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(_modelsProvider(initialProviderId)),
        ),
      ),
    );
  }
}

/// Provider local: filtra por providerId si viene, sino lista
/// todos los habilitados (modo fallback / deep link directo).
final _modelsProvider = FutureProvider.family<List<ModelDefinition>, String?>((
  ref,
  providerId,
) {
  final repo = ref.read(modelCatalogRepositoryProvider);
  if (providerId == null || providerId.isEmpty) {
    return repo.listEnabled();
  }
  return repo.listEnabledByProvider(providerId);
});

class _ModelCard extends ConsumerWidget {
  const _ModelCard({required this.model});

  final ModelDefinition model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.psychology_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        model.displayName,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        l10n.modelSelectorSubtitle(
          _formatTokens(model.contextWindow),
          l10n.modelSelectorStreaming,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          l10n.modelSelectorBadgeFree,
          style: const TextStyle(color: Colors.green, fontSize: 12),
        ),
      ),
      onTap: () => context.push(
        // spec 04 v2.0.0: /sessions recibe providerId + modelId.
        // providerId es la clave para que el panel sepa a que
        // provider pertenece y arme el deep link de "Cambiar
        // modelo" correctamente.
        '/sessions?providerId=${model.providerId}&modelId=${model.id}',
      ),
      onLongPress: () async {
        await ref
            .read(modelCatalogRepositoryProvider)
            .setEnabled(model.id, !model.enabled);
        ref.invalidate(_modelsProvider(model.providerId));
      },
    );
  }

  String _formatTokens(int tokens) {
    final k = tokens ~/ 1000;
    return '${k}k';
  }
}

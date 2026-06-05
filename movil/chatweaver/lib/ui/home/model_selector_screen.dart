import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:chatweaver/di/global_providers.dart';
import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/session/domain/entities/model_definition.dart';
import 'package:chatweaver/ui/shared/empty_state_view.dart';
import 'package:chatweaver/ui/shared/error_view.dart';

class ModelSelectorScreen extends ConsumerWidget {
  const ModelSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final modelsAsync = ref.watch(availableModelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.modelSelectorTitle),
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
          onRetry: () => ref.invalidate(availableModelsProvider),
        ),
      ),
    );
  }
}

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
      onTap: () => context.push('/token?modelId=${model.id}'),
      onLongPress: () async {
        await ref
            .read(modelCatalogRepositoryProvider)
            .setEnabled(model.id, !model.enabled);
        ref.invalidate(availableModelsProvider);
      },
    );
  }

  String _formatTokens(int tokens) {
    final k = tokens ~/ 1000;
    return '${k}k';
  }
}

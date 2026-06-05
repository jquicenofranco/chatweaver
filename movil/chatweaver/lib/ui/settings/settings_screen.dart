import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatweaver/db/credential_handle.dart';
import 'package:chatweaver/di/global_providers.dart';
import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/ui/shared/confirm_dialog.dart';
import 'package:chatweaver/ui/shared/empty_state_view.dart';
import 'package:chatweaver/ui/shared/error_view.dart';

final credentialsListProvider = FutureProvider<List<CredentialHandle>>((ref) {
  return ref.read(credentialRepositoryProvider).list();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.key),
            title: Text(l10n.settingsCredentials),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const _CredentialsScreen(),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.psychology_outlined),
            title: Text(l10n.settingsModels),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const _ModelsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CredentialsScreen extends ConsumerWidget {
  const _CredentialsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final credsAsync = ref.watch(credentialsListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsCredentials)),
      body: credsAsync.when(
        data: (creds) {
          if (creds.isEmpty) {
            return EmptyStateView(
              icon: Icons.key_off,
              message: l10n.settingsNoCredentials,
              actionLabel: l10n.settingsAddCredential,
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const _AddCredentialScreen(),
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: creds.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final c = creds[i];
              return ListTile(
                leading: const Icon(Icons.key),
                title: Text(c.label),
                subtitle: Text(c.providerId),
                onLongPress: () async {
                  final ok = await ConfirmDialog.show(
                    context,
                    title: l10n.settingsDeleteCredential,
                    body: '${c.label} (${c.providerId})',
                  );
                  if (ok) {
                    await ref.read(credentialRepositoryProvider).delete(c.id);
                    ref.invalidate(credentialsListProvider);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(message: e.toString()),
      ),
    );
  }
}

class _AddCredentialScreen extends ConsumerStatefulWidget {
  const _AddCredentialScreen();

  @override
  ConsumerState<_AddCredentialScreen> createState() =>
      _AddCredentialScreenState();
}

class _AddCredentialScreenState
    extends ConsumerState<_AddCredentialScreen> {
  final _labelController = TextEditingController();
  final _tokenController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAddCredential)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(labelText: 'Label'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tokenController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.tokenInputLabel),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                await ref.read(credentialRepositoryProvider).save(
                      CredentialHandle(
                        id: id,
                        providerId: 'MiniMax',
                        label: _labelController.text.isEmpty
                            ? 'Default'
                            : _labelController.text,
                        secureKey: 'chatweaver_$id',
                        createdAt: DateTime.now(),
                      ),
                      _tokenController.text,
                    );
                ref.invalidate(credentialsListProvider);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelsScreen extends ConsumerWidget {
  const _ModelsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelsAsync = ref.watch(availableModelsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsModels)),
      body: modelsAsync.when(
        data: (models) => ListView.separated(
          itemCount: models.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final m = models[i];
            return SwitchListTile(
              title: Text(m.displayName),
              subtitle: Text(m.providerId),
              value: m.enabled,
              onChanged: (v) async {
                await ref
                    .read(modelCatalogRepositoryProvider)
                    .setEnabled(m.id, v);
                ref.invalidate(availableModelsProvider);
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(message: e.toString()),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'package:chatweaver/db/credential_handle.dart';
import 'package:chatweaver/di/global_providers.dart';
import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/ui/home/connection_test_controller.dart';
import 'package:chatweaver/ui/shared/primary_button.dart';

class TokenInputScreen extends ConsumerStatefulWidget {
  const TokenInputScreen({super.key, required this.modelId});

  final String modelId;

  @override
  ConsumerState<TokenInputScreen> createState() => _TokenInputScreenState();
}

class _TokenInputScreenState extends ConsumerState<TokenInputScreen> {
  final _tokenController = TextEditingController();
  bool _remember = true;
  bool _obscure = true;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(connectionTestProvider);
    final model = ref.watch(
      _modelDefinitionProvider(widget.modelId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tokenInputTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              model.when(
                data: (def) => def == null
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.tokenInputProvider(def.providerId),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            l10n.tokenInputModel(def.displayName),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(e.toString()),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _tokenController,
                obscureText: _obscure,
                autocorrect: false,
                enableSuggestions: false,
                maxLines: 3,
                minLines: 1,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: InputDecoration(
                  labelText: l10n.tokenInputLabel,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _remember,
                onChanged: (v) => setState(() => _remember = v),
                title: Text(l10n.tokenInputRemember),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: l10n.tokenInputSubmit,
                loading: state.isLoading,
                onPressed: () => _onSubmit(context),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _openDocs(context),
                child: Text(l10n.tokenInputHelp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final apiKey = _tokenController.text.trim();
    if (apiKey.isEmpty) return;
    final err = await ref.read(connectionTestProvider.notifier).test(
          apiKey: apiKey,
          modelId: widget.modelId,
        );
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    if (_remember) {
      final def = await ref
          .read(modelCatalogRepositoryProvider)
          .getById(widget.modelId);
      if (def != null) {
        const uuid = Uuid();
        final id = '${def.providerId}-${uuid.v4().substring(0, 8)}';
        await ref.read(credentialRepositoryProvider).save(
              CredentialHandle(
                id: id,
                providerId: def.providerId,
                label: 'Default',
                secureKey: 'chatweaver_$id',
                createdAt: DateTime.now(),
              ),
              apiKey,
            );
        await ref.read(credentialRepositoryProvider).setActive(id);
      }
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.tokenInputConnected)),
    );
    context.pushReplacement('/sessions?modelId=${widget.modelId}');
  }

  Future<void> _openDocs(BuildContext context) async {
    final uri = Uri.parse('https://docs.minimax.chat');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

final _modelDefinitionProvider = FutureProvider.family((ref, String id) async {
  return ref.read(modelCatalogRepositoryProvider).getById(id);
});

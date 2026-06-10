import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:chatweaver/db/credential_handle.dart';
import 'package:chatweaver/di/global_providers.dart';
import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/session/domain/entities/model_definition.dart';
import 'package:chatweaver/ui/home/connection_test_controller.dart';
import 'package:chatweaver/ui/shared/primary_button.dart';

/// Pantalla de captura y validacion del API key (spec 04 v2.0.0).
///
/// **Cambio v2.0.0**: recibe `providerId` (no `modelId`). El
/// catalogo de modelos se filtra por provider para resolver el
/// primer modelo habilitado, que se usa para el ping barato de
/// `testConnection`. La credencial se guarda a nivel de provider.
class TokenInputScreen extends ConsumerStatefulWidget {
  const TokenInputScreen({super.key, required this.providerId});

  final String providerId;

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
    // Header: nombre del provider + lista de modelos disponibles.
    final modelsAsync = ref.watch(
      _modelsForProviderProvider(widget.providerId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tokenInputTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.commonBack,
          onPressed: () => context.go('/providers'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              modelsAsync.when(
                data: (models) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tokenInputProvider(widget.providerId),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (models.isNotEmpty)
                      Text(
                        l10n.tokenInputModel(
                          models.map((m) => m.displayName).join(', '),
                        ),
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
                // Cuando se oculta, el campo es password (1 línea).
                // Cuando se muestra, permite pegar keys multilínea (3 líneas).
                maxLines: _obscure ? 1 : 3,
                minLines: 1,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: InputDecoration(
                  labelText: l10n.tokenInputLabel,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
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
    final err = await ref
        .read(connectionTestProvider.notifier)
        .test(apiKey: apiKey, providerId: widget.providerId);
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    if (_remember) {
      // spec 04 v2.0.0: la credencial es por provider. La `id`
      // de la credencial usa el providerId para que sea estable
      // (si el usuario re-entra, sobreescribimos en vez de
      // duplicar).
      final id = '${widget.providerId}-default';
      await ref
          .read(credentialRepositoryProvider)
          .save(
            CredentialHandle(
              id: id,
              providerId: widget.providerId,
              label: l10n.commonDefault,
              secureKey: 'chatweaver_$id',
              createdAt: DateTime.now(),
            ),
            apiKey,
          );
      await ref.read(credentialRepositoryProvider).setActive(id);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.tokenInputConnected)));
    // Despues de validar, ir al selector de modelos del provider
    // (spec 04 v2.0.0). El usuario elige cual modelo usar.
    context.go('/models?providerId=${widget.providerId}');
  }

  Future<void> _openDocs(BuildContext context) async {
    final uri = Uri.parse('https://platform.minimax.io/docs');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

/// Provider local: modelos habilitados del provider (usado para
/// mostrar el header "Modelo: M3, M2.7, ..." en TokenInput).
final _modelsForProviderProvider =
    FutureProvider.family<List<ModelDefinition>, String>((ref, providerId) {
      return ref
          .read(modelCatalogRepositoryProvider)
          .listEnabledByProvider(providerId);
    });

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:chatweaver/di/global_providers.dart';
import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/session/domain/entities/chat_session.dart';
import 'package:chatweaver/session/domain/entities/model_definition.dart';
import 'package:chatweaver/ui/shared/confirm_dialog.dart';
import 'package:chatweaver/ui/shared/empty_state_view.dart';
import 'package:chatweaver/ui/shared/error_view.dart';

/// Provider activo (modelo + provider) seleccionado en este panel.
/// spec 04 v2.0.0: el panel puede recibir `providerId` y `modelId`
/// como query params; ambos son opcionales.
final activeProviderIdProvider = StateProvider<String?>((ref) => null);

/// Modelo activo seleccionado en este panel (param de query o null).
final activeModelIdProvider = StateProvider<String?>((ref) => null);

final sessionsStreamProvider = StreamProvider<List<ChatSession>>((ref) {
  final modelId = ref.watch(activeModelIdProvider);
  if (modelId == null) return const Stream.empty();
  return ref.read(sessionsRepositoryProvider).watchByModel(modelId);
});

final activeModelProvider = FutureProvider<ModelDefinition?>((ref) async {
  final modelId = ref.watch(activeModelIdProvider);
  if (modelId == null) return null;
  return ref.read(modelCatalogRepositoryProvider).getById(modelId);
});

class SessionsPanelScreen extends ConsumerStatefulWidget {
  const SessionsPanelScreen({
    super.key,
    this.initialProviderId,
    this.initialModelId,
  });

  /// spec 04 v2.0.0: query param `providerId` (opcional).
  final String? initialProviderId;

  /// spec 04 v2.0.0: query param `modelId` (opcional).
  final String? initialModelId;

  @override
  ConsumerState<SessionsPanelScreen> createState() =>
      _SessionsPanelScreenState();
}

class _SessionsPanelScreenState extends ConsumerState<SessionsPanelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // spec 04 v2.0.0: providerId puede llegar como null/empty en
      // deep links legacy; solo actualizamos si viene valor util.
      if (widget.initialProviderId != null &&
          widget.initialProviderId!.isNotEmpty) {
        ref.read(activeProviderIdProvider.notifier).state =
            widget.initialProviderId;
      }
      if (widget.initialModelId != null) {
        ref.read(activeModelIdProvider.notifier).state = widget.initialModelId;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final model = ref.watch(activeModelProvider);
    final sessionsAsync = ref.watch(sessionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: model.when(
          data: (m) => Text(m?.displayName ?? l10n.sessionsTitle),
          loading: () => Text(l10n.sessionsTitle),
          error: (_, _) => Text(l10n.sessionsTitle),
        ),
        actions: [
          // spec 04 v2.0.0: deep link explicito con `providerId` para
          // que el selector de modelos filtre por provider y no liste
          // modelos de otros providers.
          IconButton(
            icon: const Icon(Icons.psychology_outlined),
            tooltip: l10n.commonChangeModel,
            onPressed: () {
              final providerId = ref.read(activeProviderIdProvider);
              if (providerId == null || providerId.isEmpty) {
                // Fallback: si no tenemos providerId (deep link
                // directo), vamos al selector de modelos global.
                context.push('/models');
              } else {
                context.push('/models?providerId=$providerId');
              }
            },
          ),
          // spec 04 v2.0.0: volver al selector de proveedor permite
          // cambiar de provider con un solo tap.
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: l10n.commonChangeProvider,
            onPressed: () => context.go('/providers'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return EmptyStateView(
              icon: Icons.chat_bubble_outline,
              message: l10n.sessionsEmpty,
              actionLabel: l10n.sessionsNewSession,
              onAction: _createSession,
            );
          }
          return ListView.separated(
            itemCount: sessions.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) => _SessionTile(session: sessions[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(sessionsStreamProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createSession,
        icon: const Icon(Icons.add),
        label: Text(l10n.sessionsNewSession),
      ),
    );
  }

  Future<void> _createSession() async {
    final modelId = ref.read(activeModelIdProvider);
    if (modelId == null) return;
    final model = await ref
        .read(modelCatalogRepositoryProvider)
        .getById(modelId);
    if (model == null || !mounted) return;
    // spec 04 v2.0.0: el `providerId` del use case sale del modelo
    // resuelto (catalogo es la fuente de verdad). El
    // `activeProviderIdProvider` del panel se usa solo para deep
    // links de UI (botones "Cambiar modelo/provider"), no para
    // resolver la sesion.
    final id = await ref
        .read(createSessionProvider)
        .call(modelId: model.id, providerId: model.providerId);
    if (!mounted) return;
    unawaited(context.push('/chat/$id'));
  }
}

class _SessionTile extends ConsumerWidget {
  const _SessionTile({required this.session});

  final ChatSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lastAgo = _formatLastMessage(session.lastMessageAt);
    final totalTokens = session.totalInputTokens + session.totalOutputTokens;

    return ListTile(
      title: Text(session.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '$lastAgo • ${l10n.sessionsTokens(totalTokens)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (v) => _onMenu(context, ref, v),
        itemBuilder: (_) => [
          PopupMenuItem(value: 'rename', child: Text(l10n.sessionsRename)),
          PopupMenuItem(value: 'delete', child: Text(l10n.sessionsDelete)),
        ],
      ),
      onTap: () => context.push('/chat/${session.id}'),
    );
  }

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final l10n = AppLocalizations.of(context);
    switch (action) {
      case 'rename':
        final controller = TextEditingController(text: session.title);
        final newTitle = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.sessionsRename),
            content: TextField(controller: controller, autofocus: true),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop(controller.text.trim()),
                child: Text(l10n.commonSave),
              ),
            ],
          ),
        );
        if (newTitle != null && newTitle.isNotEmpty) {
          await ref
              .read(sessionsRepositoryProvider)
              .rename(session.id, newTitle);
        }
        break;
      case 'delete':
        final ok = await ConfirmDialog.show(
          context,
          title: l10n.sessionsDeleteConfirmTitle,
          body: l10n.sessionsDeleteConfirmBody,
          confirmLabel: l10n.sessionsConfirm,
        );
        if (ok) {
          await ref.read(deleteSessionProvider).call(session.id);
        }
        break;
    }
  }

  String _formatLastMessage(DateTime? when) {
    if (when == null) return '—';
    final formatter = DateFormat('d MMM HH:mm', 'es');
    return formatter.format(when);
  }
}

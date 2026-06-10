import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatweaver/di/global_providers.dart';
import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/message/domain/entities/message.dart';
import 'package:chatweaver/message/domain/entities/token_usage.dart';
import 'package:chatweaver/message/presentation/widgets/message_bubble.dart';
import 'package:chatweaver/message/presentation/widgets/token_meter.dart';
import 'package:chatweaver/ui/chat/chat_controller.dart';
import 'package:chatweaver/ui/chat/prompt_input.dart';
import 'package:chatweaver/ui/shared/confirm_dialog.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sessionAsync = ref.watch(sessionProvider(widget.sessionId));
    final messagesAsync = ref.watch(messagesStreamProvider(widget.sessionId));
    final chatState = ref.watch(chatControllerProvider(widget.sessionId));

    // Escuchar cambios en mensajes y hacer scroll al fondo.
    ref.listen(messagesStreamProvider(widget.sessionId), (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    });

    // **Spec 05 (T-22)**: sincronizar el map de reasoning
    // incremental del controller. Solo si la lista esta disponible
    // (no en loading). El controller hace el diff con
    // `mapEquals` y evita rebuilds innecesarios.
    messagesAsync.whenData((msgs) {
      ref
          .read(chatControllerProvider(widget.sessionId).notifier)
          .syncFromMessages(msgs);
    });

    return sessionAsync.when(
      data: (session) {
        if (session == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.sessionsDelete)),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(session.title),
            actions: [
              if (chatState.isStreaming)
                IconButton(
                  icon: const Icon(Icons.stop),
                  tooltip: l10n.chatStop,
                  onPressed: () => ref
                      .read(chatControllerProvider(widget.sessionId).notifier)
                      .abort(),
                ),
              PopupMenuButton<String>(
                onSelected: (v) => _onMenu(context, v, session.title),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'rename', child: Text(l10n.chatRename)),
                  PopupMenuItem(
                    value: 'system',
                    child: Text(l10n.chatSetSystemPrompt),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.chatDeleteSession),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              _TokenMeterHeader(
                sessionId: widget.sessionId,
                messages: chatState.messages,
                draft: chatState.draft,
                contextWindowModelId: session.modelId,
              ),
              Expanded(
                child: messagesAsync.when(
                  data: (messages) {
                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.sessionsEmpty,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: messages.length,
                      itemBuilder: (context, i) {
                        return MessageBubble(
                          message: messages[i],
                          onRetry: messages[i].status == MessageStatus.failed
                              ? () => ref
                                    .read(
                                      chatControllerProvider(
                                        widget.sessionId,
                                      ).notifier,
                                    )
                                    .send(messages[i].content)
                              : null,
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(e.toString())),
                ),
              ),
              if (chatState.error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Text(
                    chatState.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              PromptInput(sessionId: widget.sessionId),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
    );
  }

  void _scrollToEnd() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Future<void> _onMenu(BuildContext context, String action, String _) async {
    final l10n = AppLocalizations.of(context);
    switch (action) {
      case 'delete':
        final ok = await ConfirmDialog.show(
          context,
          title: l10n.sessionsDeleteConfirmTitle,
          body: l10n.sessionsDeleteConfirmBody,
        );
        if (ok) {
          await ref.read(deleteSessionProvider).call(widget.sessionId);
          if (context.mounted) Navigator.of(context).pop();
        }
        break;
    }
  }
}

class _TokenMeterHeader extends ConsumerWidget {
  const _TokenMeterHeader({
    required this.sessionId,
    required this.messages,
    required this.draft,
    required this.contextWindowModelId,
  });

  final String sessionId;
  final List<Message> messages;
  final String draft;
  final String contextWindowModelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider(sessionId));
    final session = sessionAsync.valueOrNull;
    final modelAsync = ref.watch(_modelByIdProvider(contextWindowModelId));
    final contextWindow = modelAsync.valueOrNull?.contextWindow ?? 0;

    // **Spec 05 (decision MVP)**: thinking tokens NO se acumulan
    // a nivel `Session` (no tocamos el schema de sessions). El
    // `TokenMeter` los consume desde la lista de mensajes, sumando
    // `thinkingTokens` de los assistant messages. Para listas
    // pequeñas (<1000) el fold es O(n) y barato; si crece, pasar
    // a query agregada en el DAO.
    final thinkingTokens = messages.fold<int>(
      0,
      (sum, m) => sum + (m.thinkingTokens ?? 0),
    );

    final usage = TokenUsage(
      inputTokens: session?.totalInputTokens ?? 0,
      outputTokens: session?.totalOutputTokens ?? 0,
      thinkingTokens: thinkingTokens,
    );
    final projected = _projectedRatio(contextWindow);

    return TokenMeter(
      usage: usage,
      contextBudget: contextWindow,
      projectedRatio: projected,
    );
  }

  double _projectedRatio(int contextWindow) {
    if (contextWindow == 0) return 0;
    const overhead = 4;
    var total = draft.length + overhead + 1024;
    for (final m in messages) {
      total += m.content.length + overhead;
    }
    return total / contextWindow;
  }
}

final _modelByIdProvider = FutureProvider.family((ref, String id) async {
  return ref.read(modelCatalogRepositoryProvider).getById(id);
});

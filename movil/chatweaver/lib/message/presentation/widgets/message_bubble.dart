import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatweaver/di/global_providers.dart';
import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/message/domain/entities/message.dart';
import 'package:chatweaver/message/presentation/widgets/reasoning_panel.dart';

/// Bubble de un mensaje en la conversacion.
///
/// **Spec 05**:
/// - Refactorizado a `ConsumerWidget` para leer
///   `showReasoningProvider` (T-29) sin acoplar al padre.
/// - Si el mensaje es del assistant Y tiene reasoning Y el toggle
///   del usuario esta ON, renderiza un [ReasoningPanel] **encima**
///   del bubble de la respuesta (C-BIZ-01: nunca intercalado).
/// - El `MarkdownBody` SOLO se usa para `content` (answer). El
///   reasoning se renderiza como `SelectableText` plano en el
///   panel (C-SEC-01: anti-inyeccion).
class MessageBubble extends ConsumerWidget {
  const MessageBubble({super.key, required this.message, this.onRetry});

  final Message message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isUser = message.role == MessageRole.user;
    final isFailed = message.status == MessageStatus.failed;

    // **Spec 05 (T-29)**: leer el toggle de Settings. Si esta OFF,
    // nunca se renderiza el panel aunque el modelo lo soporte
    // (la data sigue persistida, asi que toggle ON la muestra de
    // nuevo sin re-streamear).
    final showReasoning = ref.watch(showReasoningProvider);

    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isUser
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isUser
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **Spec 05 (T-23)**: ReasoningPanel ANTES del bubble
            // del assistant. Solo se muestra si: (a) el mensaje es
            // del assistant, (b) el toggle esta ON, (c) hay
            // reasoning. La data viaja en `message.reasoning`
            // persistido por `SendMessage` durante el streaming.
            if (!isUser &&
                showReasoning &&
                (message.reasoning?.isNotEmpty ?? false))
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4, right: 8),
                child: ReasoningPanel(
                  reasoning: message.reasoning!,
                  thinkingTokens: message.thinkingTokens,
                  isStreaming: message.status == MessageStatus.streaming,
                ),
              ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(16),
                border: isFailed
                    ? Border.all(color: theme.colorScheme.error)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isUser)
                    Text(message.content, style: TextStyle(color: textColor))
                  else
                    MarkdownBody(
                      data: message.content,
                      styleSheet: MarkdownStyleSheet.fromTheme(
                        theme,
                      ).copyWith(p: TextStyle(color: textColor)),
                    ),
                  if (isFailed) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.chatMessageFailed,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                        if (onRetry != null) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: onRetry,
                            child: Text(l10n.chatRetry),
                          ),
                        ],
                      ],
                    ),
                  ],
                  if (message.status == MessageStatus.streaming)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/ui/chat/chat_controller.dart';

class PromptInput extends ConsumerStatefulWidget {
  const PromptInput({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<PromptInput> createState() => _PromptInputState();
}

class _PromptInputState extends ConsumerState<PromptInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isStreaming = ref.watch(
      chatControllerProvider(widget.sessionId).select((s) => s.isStreaming),
    );
    final controller = ref.read(chatControllerProvider(widget.sessionId).notifier);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                // Sin maxLength: requisito explicito de la spec.
                minLines: 1,
                maxLines: 8,
                onChanged: controller.updateDraft,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: l10n.chatPlaceholder,
                  filled: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: Icon(
                isStreaming ? Icons.stop : Icons.send,
              ),
              tooltip: isStreaming ? l10n.chatStop : l10n.chatSend,
              onPressed: () {
                if (isStreaming) {
                  controller.abort();
                } else {
                  final text = _controller.text;
                  _controller.clear();
                  controller.updateDraft('');
                  controller.send(text);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatweaver/l10n/generated/app_localizations.dart';

/// Panel colapsable que muestra el trace de razonamiento de un
/// modelo pensante (chain-of-thought), **separado** del bubble
/// de la respuesta final (C-BIZ-01).
///
/// **Spec 05 (T-19, T-20, T-21, C-PERF-01)**:
/// - `ConsumerStatefulWidget` con estado interno de expansion
///   (no persistido entre sesiones, spec 05 §3.2 OUT).
/// - `Semantics` para accesibilidad.
/// - `RepaintBoundary` + `ConstrainedBox(maxHeight: 400)` +
///   `SingleChildScrollView` para que traces largos (>10k chars)
///   no causen jank.
/// - `SelectableText` monoespaciado (12px) para diferenciar
///   visualmente del answer (que usa `MarkdownBody` proporcional).
/// - `SelectableText` plano, NO `MarkdownBody`, para evitar
///   superficie de inyeccion (C-SEC-01).
/// - Empty state: el widget NUNCA se invoca con texto vacio (el
///   guard esta en [MessageBubble]).
class ReasoningPanel extends ConsumerStatefulWidget {
  const ReasoningPanel({
    super.key,
    required this.reasoning,
    required this.thinkingTokens,
    required this.isStreaming,
  });

  final String reasoning;
  final int? thinkingTokens;
  final bool isStreaming;

  @override
  ConsumerState<ReasoningPanel> createState() => _ReasoningPanelState();
}

class _ReasoningPanelState extends ConsumerState<ReasoningPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isStreaming = widget.isStreaming;
    // Usamos `tertiary` (no `primary`) para que el panel se distinga
    // visualmente del bubble del assistant (`surfaceContainerHighest`)
    // y del bubble del user (`primary`). Asi no se confunde con la
    // respuesta final.
    final color = theme.colorScheme.tertiary;

    return Semantics(
      container: true,
      label: l10n.reasoningPanelSemantic(widget.reasoning.length),
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        child: Theme(
          // Elimina el divisor default del ExpansionTile para que
          // no haya una linea horizontal extra entre el header y
          // el contenido.
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: _expanded,
            onExpansionChanged: (v) => setState(() => _expanded = v),
            leading: Icon(
              Icons.psychology_outlined,
              color: color,
              size: 20,
              semanticLabel: l10n.reasoningTitle,
            ),
            title: Text(
              isStreaming ? l10n.reasoningThinking : l10n.reasoningTitle,
              style: theme.textTheme.labelMedium?.copyWith(color: color),
            ),
            subtitle:
                widget.thinkingTokens != null && widget.thinkingTokens! > 0
                ? Text(
                    l10n.reasoningTokensHint(widget.thinkingTokens!),
                    style: theme.textTheme.bodySmall,
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Boton de copiar: solo visible cuando el panel
                // esta expandido (evita copia accidental del
                // header contraido).
                Semantics(
                  button: true,
                  label: l10n.reasoningCopySemantic,
                  child: IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: _expanded ? _copy : null,
                    tooltip: l10n.reasoningCopyTooltip,
                  ),
                ),
                if (isStreaming)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: [
              // RepaintBoundary: un update del texto no re-pinta
              // el ListView padre (mantiene 60fps con traces largos,
              // C-PERF-01).
              RepaintBoundary(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      widget.reasoning,
                      // Monoespaciado para diferenciar del answer
                      // (que usa MarkdownBody proporcional). Tamano
                      // 12px para que quepan mas chars por linea
                      // sin saturar.
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copy() async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: widget.reasoning));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.reasoningCopied)));
  }
}

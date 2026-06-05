import 'package:flutter/material.dart';

import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/message/domain/entities/token_usage.dart';

/// Widget de medicion de contexto.
///
/// Muestra una barra `usage / contextBudget` con color verde /
/// amarillo / rojo, y un warning si el proximo envio excede 85%.
class TokenMeter extends StatelessWidget {
  const TokenMeter({
    super.key,
    required this.usage,
    required this.contextBudget,
    required this.projectedRatio,
  });

  final TokenUsage usage;
  final int contextBudget;
  final double projectedRatio;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final usedRatio = contextBudget == 0
        ? 0.0
        : (usage.total / contextBudget).clamp(0.0, 1.0);
    final color = _colorFor(usedRatio);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: usedRatio,
                  minHeight: 6,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.15),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.chatTokensUsed(usage.total, contextBudget),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          if (projectedRatio > 0.85)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(
                    l10n.chatProjectedWarning(
                      (projectedRatio * 100).toInt(),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(color: color),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _colorFor(double ratio) {
    if (ratio < 0.60) return Colors.green;
    if (ratio < 0.85) return Colors.amber;
    return Colors.red;
  }
}

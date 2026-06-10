import 'package:flutter/material.dart';

import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/message/domain/entities/token_usage.dart';

/// Widget de medicion de contexto.
///
/// **Spec 05 (T-17)**: muestra 3 segmentos apilados en la misma
/// fila horizontal, en el orden de consumo:
///   - **Azul** (`#1976D2`): input tokens
///   - **Naranja** (`#F57C00`): thinking tokens (3ra categoria)
///   - **Verde** (`#388E3C`): answer tokens (output)
/// Esto preserva la lectura "se va llenando el contexto" sin
/// saturar con un grafico de dona o 3 filas.
///
/// Decision OQ-03 resuelta: **3 segmentos apilados** (vs. 3 filas
/// o grafico de dona). Justificacion: misma altura (6 px) que el
/// widget original → no rompe el layout de la `ChatScreen`; una
/// sola fila → facil escaneo; los 3 colores contrastan con
/// `surface` en dark y light.
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

  // Colores fijos (no del theme) para que dark/light contrasten
  // consistentemente. Verificado: en `surface` (light ~#FAFAFA,
  // dark ~#1C1B1F) los 3 colores tienen contraste suficiente
  // para el LinearProgressIndicator de 6 px.
  static const _inputColor = Color(0xFF1976D2); // blue 700
  static const _thinkingColor = Color(0xFFF57C00); // orange 700
  static const _answerColor = Color(0xFF388E3C); // green 700

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // TokenUsage.total ya incluye los 3 flujos (spec 05: total =
    // input + output + thinking).
    final total = usage.total;
    final usedRatio = contextBudget == 0
        ? 0.0
        : (total / contextBudget).clamp(0.0, 1.0);
    final color = _colorFor(usedRatio);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // **Spec 05 (T-17, VC-05)**: 3 segmentos apilados
              // proporcionales. Si `total == 0`, todo el ancho
              // queda como background (no se ve nada), lo que
              // preserva la lectura del "no usado" sin un fondo
              // gris explicito.
              Expanded(
                child: Tooltip(
                  message: l10n.tokenMeterTooltip(
                    usage.inputTokens,
                    usage.thinkingTokens,
                    usage.outputTokens,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      height: 6,
                      child: Row(
                        children: [
                          if (usage.inputTokens > 0)
                            Expanded(
                              flex: usage.inputTokens,
                              child: Container(color: _inputColor),
                            ),
                          if (usage.thinkingTokens > 0)
                            Expanded(
                              flex: usage.thinkingTokens,
                              child: Container(color: _thinkingColor),
                            ),
                          if (usage.outputTokens > 0)
                            Expanded(
                              flex: usage.outputTokens,
                              child: Container(color: _answerColor),
                            ),
                          // Cuando `total == 0`, no se renderiza
                          // ningun Expanded → el Row queda vacio.
                          // Aceptable: el LinearProgressIndicator
                          // desaparece visualmente, lo que indica
                          // "sin uso".
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.chatTokensUsed(total, contextBudget),
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
                    l10n.chatProjectedWarning((projectedRatio * 100).toInt()),
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

import 'package:chatweaver/context/context_strategy.dart';
import 'package:chatweaver/llm/chat_message.dart';

/// Mantiene los mensajes mas recientes, descartando los mas
/// antiguos hasta que el total quepa en el budget.
///
/// Pseudocodigo (spec 02 §10.2):
/// 1. Reservar margen de seguridad del 10% del budget.
/// 2. Iterar desde el mas reciente hacia el mas antiguo.
/// 3. Si agregar este mensaje excede el budget efectivo, parar.
/// 4. Insertar al inicio de `kept` para mantener orden cronologico.
class SlidingWindowStrategy implements ContextStrategy {
  const SlidingWindowStrategy();

  static const int _perMessageOverhead = 4;
  static const double _safetyMarginRatio = 0.10;

  @override
  List<ChatMessage> apply({
    required List<ChatMessage> messages,
    required int budget,
    required int Function(String text) calculateTokens,
  }) {
    if (budget <= 0 || messages.isEmpty) return const [];

    final safetyMargin = (budget * _safetyMarginRatio).floor();
    final effectiveBudget = budget - safetyMargin;
    if (effectiveBudget <= 0) return const [];

    final kept = <ChatMessage>[];
    var usedTokens = 0;

    for (final message in messages.reversed) {
      final messageTokens =
          calculateTokens(message.content) + _perMessageOverhead;

      if (usedTokens + messageTokens > effectiveBudget) break;

      kept.insert(0, message);
      usedTokens += messageTokens;
    }

    return kept;
  }
}

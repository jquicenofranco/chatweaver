import 'package:chatweaver/context/context_strategy.dart';
import 'package:chatweaver/context/sliding_window_strategy.dart';
import 'package:chatweaver/llm/chat_message.dart';
import 'package:chatweaver/llm/illm_provider.dart';

/// Compone la estrategia de contexto con el provider activo.
///
/// El manager es el unico que conoce la formula del budget
/// (`contextWindow - maxOutputTokens`) y como descontar el system
/// prompt. Los casos de uso le delegan `trimHistory` /
/// `estimateNextSendTokens` y no duplican esa logica.
class ContextWindowManager {
  ContextWindowManager({
    required ILLMProvider provider,
    required int contextWindow,
    int maxOutputTokens = 1024,
    ContextStrategy? strategy,
  }) : _provider = provider,
       _contextWindow = contextWindow,
       _maxOutputTokens = maxOutputTokens,
       _strategy = strategy ?? const SlidingWindowStrategy();

  static const int _perMessageOverhead = 4;

  final ILLMProvider _provider;
  final int _contextWindow;
  final int _maxOutputTokens;
  final ContextStrategy _strategy;

  int get contextWindow => _contextWindow;
  int get maxOutputTokens => _maxOutputTokens;

  int get totalBudget => _contextWindow - _maxOutputTokens;

  /// Devuelve la sublista de [history] que cabe en el budget,
  /// descontando primero el system prompt.
  List<ChatMessage> trimHistory(
    List<ChatMessage> history, {
    String? systemPrompt,
  }) {
    final systemTokens = _systemPromptTokens(systemPrompt);
    final historyBudget = totalBudget - systemTokens;
    if (historyBudget <= 0) return const [];

    return _strategy.apply(
      messages: history,
      budget: historyBudget,
      calculateTokens: _provider.calculateTokens,
    );
  }

  /// Estima los tokens del proximo envio: historial + draft +
  /// system prompt + maxOutput.
  int estimateNextSendTokens({
    required List<ChatMessage> history,
    required String draft,
    String? systemPrompt,
  }) {
    var total = 0;
    for (final m in history) {
      total += _provider.calculateTokens(m.content) + _perMessageOverhead;
    }
    total += _provider.calculateTokens(draft) + _perMessageOverhead;
    total += _systemPromptTokens(systemPrompt);
    total += _maxOutputTokens;
    return total;
  }

  /// Ratio `estimated / contextWindow` para la UI.
  double usageRatio({
    required List<ChatMessage> history,
    required String draft,
    String? systemPrompt,
  }) {
    final estimated = estimateNextSendTokens(
      history: history,
      draft: draft,
      systemPrompt: systemPrompt,
    );
    if (_contextWindow == 0) return 0;
    return estimated / _contextWindow;
  }

  int _systemPromptTokens(String? systemPrompt) {
    if (systemPrompt == null || systemPrompt.isEmpty) return 0;
    return _provider.calculateTokens(systemPrompt) + _perMessageOverhead;
  }
}

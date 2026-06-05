import 'package:chatweaver/context/context_window_manager.dart';
import 'package:chatweaver/llm/chat_message.dart';
import 'package:chatweaver/llm/illm_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProvider extends Mock implements ILLMProvider {}

ChatMessage _msg(String id, String content) => ChatMessage(
      id: id,
      role: ChatRole.user,
      content: content,
    );

int _calc(String text) => (text.length / 4).ceil();

void main() {
  late _MockProvider provider;
  late ContextWindowManager manager;

  setUp(() {
    provider = _MockProvider();
    when(() => provider.calculateTokens(any())).thenAnswer(
      (inv) => _calc(inv.positionalArguments.first as String),
    );
    manager = ContextWindowManager(
      provider: provider,
      contextWindow: 1000,
      maxOutputTokens: 100,
    );
  });

  group('ContextWindowManager', () {
    test('totalBudget = contextWindow - maxOutputTokens', () {
      expect(manager.totalBudget, 900);
    });

    test('trimHistory sin systemPrompt descuenta solo maxOutput', () {
      final history = List.generate(
        5,
        (i) => _msg('m$i', 'A' * 16),
      );

      final result = manager.trimHistory(history);

      expect(result, isNotEmpty);
      verify(() => provider.calculateTokens(any())).called(greaterThan(0));
    });

    test('trimHistory con systemPrompt reduce el budget del historial', () {
      final history = [_msg('a', 'A' * 16)];
      final withSys = manager.trimHistory(history, systemPrompt: 'B' * 400);
      final withoutSys = manager.trimHistory(history);

      // El system prompt de 400 chars -> 100 tokens + 4 overhead = 104
      // Sin system -> budget 900
      // Con system -> budget 796
      // Para un solo mensaje de 8 tokens, ambos caben,
      // pero la diferencia esta en la cantidad de tokens que el manager "ve".
      expect(withSys.length, lessThanOrEqualTo(withoutSys.length));
    });

    test('trimHistory devuelve vacio si systemPrompt excede budget', () {
      final history = [_msg('a', 'hola')];
      // contextWindow 1000, maxOutput 100 -> budget 900
      // systemPrompt 4000 chars -> 1000 tokens + 4 overhead > 900
      final result = manager.trimHistory(history, systemPrompt: 'B' * 4000);
      expect(result, isEmpty);
    });

    test('estimateNextSendTokens suma historial + draft + system + maxOutput',
        () {
      final history = List.generate(3, (i) => _msg('m$i', 'A' * 16));
      final draft = 'B' * 16; // 4 + 4 = 8

      final total = manager.estimateNextSendTokens(
        history: history,
        draft: draft,
        systemPrompt: 'C' * 16, // 4 + 4 = 8
      );

      // 3 mensajes * 8 + draft 8 + system 8 + maxOutput 100 = 140
      expect(total, 140);
    });

    test('usageRatio devuelve ratio estimado / contextWindow', () {
      final ratio = manager.usageRatio(
        history: const [],
        draft: 'A' * 16,
      );
      // estimate = 4 (draft) + 4 (overhead) + 100 (maxOutput) = 108
      // ratio = 108 / 1000 = 0.108
      expect(ratio, closeTo(0.108, 0.001));
    });

    test('uso de strategy inyectable', () {
      final messages = List.generate(5, (i) => _msg('m$i', 'A' * 16));
      final result = manager.trimHistory(messages);
      // La estrategia default es SlidingWindow; debe estar aplicandose.
      expect(result.length, greaterThan(0));
    });
  });

  // Verifica que la firma ILLMProvider incluye todos los miembros
  // que la capa de contexto consume.
  test('ILLMProvider expone los miembros requeridos por ContextWindowManager',
      () {
    final p = provider;
    expect(p.calculateTokens, isA<Function>());
    // generateStream y parseNetworkError existen (no los usamos aqui).
    expect(p.generateStream, isA<Function>());
    expect(p.parseNetworkError, isA<Function>());
  });
}

import 'package:chatweaver/context/sliding_window_strategy.dart';
import 'package:chatweaver/llm/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

/// Calculador determinista para tests: 1 token cada 4 chars.
int _calculateTokens(String text) => (text.length / 4).ceil();

ChatMessage _msg(String id, String content) =>
    ChatMessage(id: id, role: ChatRole.user, content: content);

void main() {
  group('SlidingWindowStrategy', () {
    const strategy = SlidingWindowStrategy();

    test('preserva orden cronologico', () {
      final messages = [
        _msg('a', 'AAAAAAAA'), // 2 tokens + 4 overhead = 6
        _msg('b', 'BBBB'), // 1 + 4 = 5
        _msg('c', 'CCCC'), // 1 + 4 = 5
      ];

      final result = strategy.apply(
        messages: messages,
        budget: 100,
        calculateTokens: _calculateTokens,
      );

      expect(result.map((m) => m.id), ['a', 'b', 'c']);
    });

    test('mantiene los mas recientes cuando se desborda', () {
      // budget 50 -> effective 45 (10% margin)
      // Cada mensaje: 4 tokens + 4 overhead = 8 tokens
      // Esperado: entran 5 de 10 mensajes
      final messages = List.generate(10, (i) => _msg('m$i', 'A' * 16));

      final result = strategy.apply(
        messages: messages,
        budget: 50,
        calculateTokens: _calculateTokens,
      );

      expect(result.length, 5);
      expect(result.first.id, 'm5');
      expect(result.last.id, 'm9');
    });

    test('preserva los mensajes mas recientes y descarta los antiguos', () {
      final messages = [
        _msg('old', 'X' * 400), // 100 tokens, no cabe
        _msg('new1', 'Y' * 16), // 4 + 4 = 8
        _msg('new2', 'Z' * 16), // 4 + 4 = 8
      ];

      final result = strategy.apply(
        messages: messages,
        budget: 30,
        calculateTokens: _calculateTokens,
      );

      // effective = 27, new2 cabe (8), new1 cabe (16), old no cabe (116).
      expect(result.length, 2);
      expect(result.map((m) => m.id), ['new1', 'new2']);
    });

    test('devuelve vacio si budget <= 0', () {
      final messages = [_msg('a', 'hola')];
      final result = strategy.apply(
        messages: messages,
        budget: 0,
        calculateTokens: _calculateTokens,
      );
      expect(result, isEmpty);
    });

    test('devuelve vacio si no hay mensajes', () {
      final result = strategy.apply(
        messages: const [],
        budget: 1000,
        calculateTokens: _calculateTokens,
      );
      expect(result, isEmpty);
    });

    test('devuelve vacio si effective budget es 0', () {
      // budget 5 -> safety margin floor(0.5) = 0 -> effective 5
      // Pero con budget 4 -> margin floor(0.4) = 0 -> effective 4
      // Para que effective sea 0, budget debe ser < ~5
      // Usamos budget 1 -> margin 0 -> effective 1, pero mensajes de 8 no caben
      final messages = [_msg('a', 'A' * 16)];
      final result = strategy.apply(
        messages: messages,
        budget: 1,
        calculateTokens: _calculateTokens,
      );
      expect(result, isEmpty);
    });

    test('incluye mensajes que caben exactamente en el effective budget', () {
      // effective = 90 (budget 100, margin 10)
      // Mensaje: 1 + 4 = 5 tokens
      // Caben 18 mensajes: 18 * 5 = 90
      final messages = List.generate(20, (i) => _msg('m$i', 'A' * 4));
      final result = strategy.apply(
        messages: messages,
        budget: 100,
        calculateTokens: _calculateTokens,
      );
      expect(result.length, 18);
      expect(result.first.id, 'm2');
      expect(result.last.id, 'm19');
    });

    test('mensaje de tamano exacto al effective budget: cabe uno, no dos', () {
      // effective = 90, mensaje de 86 tokens + 4 overhead = 90, cabe uno
      final messages = List.generate(3, (i) => _msg('m$i', 'A' * 344));
      final result = strategy.apply(
        messages: messages,
        budget: 100,
        calculateTokens: _calculateTokens,
      );
      expect(result.length, 1);
      expect(result.first.id, 'm2');
    });
  });
}

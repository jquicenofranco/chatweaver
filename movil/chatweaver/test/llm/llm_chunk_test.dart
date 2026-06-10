import 'package:chatweaver/llm/generate_response.dart';
import 'package:chatweaver/message/domain/entities/token_usage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests unitarios de los DTOs del modulo LLM extendidos por
/// spec 05: `GenerateResponseChunk.reasoningDelta`,
/// `LlmUsage.thinkingTokens`, `TokenUsage.thinkingTokens`.
void main() {
  group('GenerateResponseChunk', () {
    test('campos independientes: textDelta y reasoningDelta no se mezclan', () {
      const a = GenerateResponseChunk(textDelta: 'hola');
      const b = GenerateResponseChunk(reasoningDelta: 'pensando');

      // freezed genera `==` por valor: dos chunks con campos
      // diferentes no son iguales.
      expect(a, isNot(equals(b)));
      expect(a.textDelta, 'hola');
      expect(a.reasoningDelta, isNull);
      expect(b.textDelta, isNull);
      expect(b.reasoningDelta, 'pensando');
    });

    test('chunk con ambos campos es valido', () {
      const c = GenerateResponseChunk(
        textDelta: 'respuesta',
        reasoningDelta: 'razonamiento',
      );
      expect(c.textDelta, 'respuesta');
      expect(c.reasoningDelta, 'razonamiento');
    });
  });

  group('LlmUsage', () {
    test('default thinkingTokens es 0 (backward-compat)', () {
      const u = LlmUsage(inputTokens: 5, outputTokens: 3);
      expect(u.thinkingTokens, 0);
      expect(u.total, 8, reason: '5 + 3 + 0 = 8');
    });

    test('total incluye thinkingTokens', () {
      const u = LlmUsage(inputTokens: 5, outputTokens: 3, thinkingTokens: 7);
      expect(u.total, 15, reason: '5 + 3 + 7 = 15');
    });
  });

  group('TokenUsage (message domain)', () {
    test('default thinkingTokens es 0 (backward-compat)', () {
      const t = TokenUsage();
      expect(t.inputTokens, 0);
      expect(t.outputTokens, 0);
      expect(t.thinkingTokens, 0);
      expect(t.total, 0);
    });

    test('total incluye thinkingTokens', () {
      const t = TokenUsage(
        inputTokens: 10,
        outputTokens: 20,
        thinkingTokens: 30,
      );
      expect(t.total, 60);
    });
  });
}

import 'package:chatweaver/llm/provider_definition.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests unitarios de [ProviderDefinition].
///
/// Es un value object con `==` / `hashCode` por valor para que
/// pueda usarse como clave de `Map` o en sets.
void main() {
  group('ProviderDefinition', () {
    test('const constructor y == por valor', () {
      const a = ProviderDefinition(id: 'MiniMax', name: 'MiniMax');
      const b = ProviderDefinition(id: 'MiniMax', name: 'MiniMax');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('description diferencia instancias con misma id+name', () {
      const a = ProviderDefinition(
        id: 'MiniMax',
        name: 'MiniMax',
        description: 'MiniMax AI',
      );
      const b = ProviderDefinition(id: 'MiniMax', name: 'MiniMax');
      expect(a, isNot(equals(b)));
    });

    test('toString incluye los tres campos', () {
      const a = ProviderDefinition(
        id: 'MiniMax',
        name: 'MiniMax',
        description: 'MiniMax AI',
      );
      final s = a.toString();
      expect(s, contains('MiniMax'));
      expect(s, contains('MiniMax AI'));
    });
  });
}

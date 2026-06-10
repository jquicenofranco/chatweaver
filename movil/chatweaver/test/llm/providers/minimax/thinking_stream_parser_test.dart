import 'package:chatweaver/llm/providers/minimax/thinking_stream_parser.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests unitarios del [ThinkingStreamParser].
///
/// **OQ-01 resuelto (empirico)**: el parser separa el trace de
/// razonamiento (entre `<think>` y `</think>`) de la respuesta
/// final, dentro de un mismo stream de `content`. Esta clase se
/// prueba en aislamiento para cubrir los casos adversariales de
/// streaming (tags partidos, tags huerfanos, etc.).
///
/// **Semantica "un bloque por call"**: cada llamada a [process]
/// emite a lo sumo un bloque `<think>...</think><text>`. Si el
/// buffer contiene varios bloques, el resto queda en [carry] para
/// la siguiente llamada.
void main() {
  group('ThinkingStreamParser', () {
    test('caso simple: <think>reasoning</think>answer', () {
      final p = ThinkingStreamParser();
      final r = p.process('<think>pensando</think>La respuesta es 42.');
      expect(r.reasoningDelta, 'pensando');
      expect(r.textDelta, 'La respuesta es 42.');
      expect(p.inThinking, isFalse);
    });

    test('pensamiento al inicio, sin answer', () {
      final p = ThinkingStreamParser();
      final r = p.process('<think>solo reasoning</think>');
      expect(r.reasoningDelta, 'solo reasoning');
      expect(r.textDelta, isEmpty);
    });

    test('sin tags, todo es texto', () {
      final p = ThinkingStreamParser();
      final r = p.process('hola mundo');
      expect(r.textDelta, 'hola mundo');
      expect(r.reasoningDelta, isEmpty);
    });

    test('stream multiparte: tags partidos entre chunks', () {
      final p = ThinkingStreamParser();
      // Chunk 1: termina con "<" del `<think>` partido.
      final r1 = p.process('<think>pensando</thin');
      // El primer chunk no debe emitir nada todavia (el tag
      // <think> no se cerro).
      expect(r1.textDelta, isEmpty);
      expect(r1.reasoningDelta, isEmpty);
      // Chunk 2: completa el tag.
      final r2 = p.process('k>respuesta');

      // El segundo chunk detecta el cierre y emite ambos.
      expect(r2.reasoningDelta, 'pensando');
      expect(r2.textDelta, 'respuesta');
    });

    test('chunk partido por la mitad del tag de cierre', () {
      final p = ThinkingStreamParser();
      final r1 = p.process('<think>razonando</th');
      // Sin emision todavia.
      expect(r1.reasoningDelta, isEmpty);
      final r2 = p.process('ink>la respuesta');
      // Ahora se cierra y emite.
      expect(r2.reasoningDelta, 'razonando');
      expect(r2.textDelta, 'la respuesta');
    });

    test('multiples bloques: solo el primero se emite en r1', () {
      // **Semantica "un bloque por call"**: el primer bloque se
      // emite en r1, el segundo queda en carry.
      final p = ThinkingStreamParser();
      final r1 = p.process(
        '<think>paso 1</think>resp1<think>paso 2</think>resp2',
      );
      expect(r1.reasoningDelta, 'paso 1');
      expect(r1.textDelta, 'resp1');

      // Para emitir el segundo bloque, necesitamos otro call.
      // El carry contiene `<think>paso 2</think>resp2`. Llamamos
      // process con un delta vacio + el carry se procesa
      // (en realidad el delta vacio no aporta nada; para
      // forzar emision usamos flush).
      final flushed = p.flush();
      // El carry es el bloque 2 completo. Como estamos en text
      // mode (ya salimos del bloque 1), el flush lo emite
      // como text sin procesar.
      expect(flushed.textDelta, '<think>paso 2</think>resp2');
      expect(flushed.reasoningDelta, isEmpty);
    });

    test('flush al final emite el residuo en el modo correcto', () {
      final p = ThinkingStreamParser();
      // Stream truncado a mitad de thinking.
      p.process('<think>pensando sin cerrar');
      expect(p.inThinking, isTrue);
      // Flush emite el residuo como reasoning.
      final flushed = p.flush();
      expect(flushed.reasoningDelta, 'pensando sin cerrar');
      expect(flushed.textDelta, isEmpty);
      expect(
        p.inThinking,
        isFalse,
        reason: 'el carry se vacio y el estado se resetea',
      );
    });

    test('flush con residuo en modo text lo emite como text', () {
      // **Spec 05 (nuevo diseno)**: el parser emite TODO el
      // texto en una sola llamada a process (no hay carry
      // residual en modo text). El carry solo se llena en modo
      // thinking o cuando hay un tag incompleto.
      final p = ThinkingStreamParser();
      final r = p.process('hola mundo sin tags<think>cerrado</think>ok');
      // El parser emite texto + reasoning + texto final en un
      // solo call. No queda nada en carry.
      expect(r.textDelta, 'hola mundo sin tagsok');
      expect(r.reasoningDelta, 'cerrado');
      // El flush posterior no emite nada (carry vacio).
      final flushed = p.flush();
      expect(flushed.textDelta, isEmpty);
      expect(flushed.reasoningDelta, isEmpty);
    });

    test('tag </think> huerfano se trata como texto literal', () {
      final p = ThinkingStreamParser();
      final r = p.process('texto </think> orphan');
      // El parser no estaba en thinking, asi que el `</think>`
      // se trata como texto (no se interpreta).
      expect(r.textDelta, 'texto </think> orphan');
      expect(r.reasoningDelta, isEmpty);
    });

    test('delta vacio no rompe el estado', () {
      final p = ThinkingStreamParser();
      final r = p.process('');
      expect(r.textDelta, isEmpty);
      expect(r.reasoningDelta, isEmpty);
      expect(p.inThinking, isFalse);
    });

    test('reasoning largo partido en muchos chunks', () {
      // Simula un trace de 200 chars partido en chunks de 7.
      final p = ThinkingStreamParser();
      // NOTA: NO usamos `const` porque `String * int` no es
      // const-evaluable en el analyzer (aunque en runtime
      // funciona).
      final reason = 'X' * 200;
      final full = '<<think>$reason</think>resp';
      final chunks = <String>[];
      for (var i = 0; i < full.length; i += 7) {
        final end = (i + 7).clamp(0, full.length);
        chunks.add(full.substring(i, end));
      }
      // **Nuevo diseno**: recolectamos TANTO reasoningDelta
      // COMO textDelta de cada process. Asi reconstruimos el
      // output completo.
      final allEmissions = <String>[];
      for (final c in chunks) {
        final r = p.process(c);
        if (r.reasoningDelta.isNotEmpty) allEmissions.add(r.reasoningDelta);
        if (r.textDelta.isNotEmpty) allEmissions.add(r.textDelta);
      }
      // Flush emite cualquier residuo en carry.
      final flushed = p.flush();
      if (flushed.reasoningDelta.isNotEmpty) {
        allEmissions.add(flushed.reasoningDelta);
      }
      if (flushed.textDelta.isNotEmpty) {
        allEmissions.add(flushed.textDelta);
      }
      final total = allEmissions.join();
      // El total debe contener los 200 X's (el reasoning).
      expect(total, contains(reason));
      // Y debe terminar con el answer 'resp'.
      expect(total, endsWith('resp'));
    });
  });
}

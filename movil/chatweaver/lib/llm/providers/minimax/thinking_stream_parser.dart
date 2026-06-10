/// Parser del stream de MiniMax que separa el razonamiento (envuelto
/// en `<think>...</think>` dentro de `content`) de la respuesta final.
///
/// **Hallazgo empirico** (resuelve OQ-01): MiniMax **no** expone
/// un campo `reasoning_content` separado. En su lugar, el modelo
/// thinking emite el reasoning **inline** dentro de `content`,
/// delimitado por los tags `<think>` y `</think>`. La API es
/// OpenAI-compatible: solo `content` en cada delta.
///
/// Este parser corre en el cliente (provider) y emite dos
/// campos paralelos a partir del mismo stream:
///   - `textDelta`: contenido que va al bubble de la respuesta final.
///   - `reasoningDelta`: contenido que va al [ReasoningPanel].
///
/// ## Estado
///
/// Mantiene state entre llamadas a [process]:
///   - `_inThinking`: estamos dentro de un bloque `<think>`.
///   - `_carry`: tail del chunk anterior que no se proceso aun
///     (puede contener el inicio de un tag partido entre chunks).
///
/// ## Semantica: un bloque por llamada
///
/// Cada llamada a [process] emite **a lo sumo un bloque**:
/// `<think><reasoning></think><text>`. Si el buffer contiene varios
/// bloques, solo se emite el primero y el resto queda en [carry]
/// para la siguiente llamada. Esto permite que la UI reciba
/// updates incrementales (un chunk por bloque) en vez de un solo
/// update gigante.
///
/// ## Robustez ante tags partidos
///
/// `<think>` (7) y `</think>` (8) son los tag lengths. Cuando un
/// tag podria estar partido entre el final de un chunk y el
/// inicio del siguiente:
///
///   chunk N:   "...res</thin"
///   chunk N+1: "k>answer..."
///
/// el parser lo concatena via [_carry] + nuevo delta y detecta el
/// tag completo.
///
/// En **modo text**, el parser tambien aplica una "safe region":
/// si el tag `<think>` no se encuentra, busca el `<` mas a la
/// derecha en los ultimos 8 chars del buffer. Si lo hay, lo
/// mantiene en [carry] (podria ser el inicio de un tag). Si no,
/// emite todo como texto.
class ThinkingStreamParser {
  ThinkingStreamParser();

  static const _openTag = '<think>';
  static const _closeTag = '</think>';
  static const _maxTagLen = 8; // == len('</think>')

  String _carry = '';
  bool _inThinking = false;

  /// True si actualmente estamos dentro de un bloque `<think>`.
  /// Util para tests y para el [flush] final.
  bool get inThinking => _inThinking;

  /// Resultado de procesar un delta. Ambos campos son **no null**
  /// y pueden ser string vacio. El caller (`SendMessage`) los
  /// concatena a sus buffers correspondientes.
  ({String textDelta, String reasoningDelta}) process(String delta) {
    if (delta.isEmpty) {
      return (textDelta: '', reasoningDelta: '');
    }
    final buffer = _carry + delta;
    final outText = StringBuffer();
    final outReasoning = StringBuffer();
    int i = 0;
    bool done = false;

    while (i < buffer.length && !done) {
      if (!_inThinking) {
        // ─── Modo text: buscar `<think>` ───────────────────────
        final idx = buffer.indexOf(_openTag, i);
        if (idx < 0) {
          // No hay `<think>`. Emitir la "safe region" como texto:
          // desde `i` hasta el `<` mas a la derecha de los ultimos
          // 8 chars (o hasta el final si no hay `<`). El resto va
          // a carry.
          final safeEnd = _findRightmostLtEnd(buffer);
          if (safeEnd > i) {
            outText.write(buffer.substring(i, safeEnd));
            i = safeEnd;
          }
          done = true;
        } else if (idx + _openTag.length > buffer.length) {
          // `<think>` empieza pero no entra completo en el buffer
          // (tag partido al final). Hold everything como carry.
          done = true;
        } else {
          // `<think>` completo. Emitir texto previo y switch.
          if (idx > i) {
            outText.write(buffer.substring(i, idx));
          }
          i = idx + _openTag.length;
          _inThinking = true;
          // Continuar a la siguiente iteracion para buscar `</think>`.
        }
      } else {
        // ─── Modo thinking: buscar `</think>` ──────────────────
        final idx = buffer.indexOf(_closeTag, i);
        if (idx < 0) {
          // No hay `</think>`. Hold everything como carry (el
          // trace puede ser muy largo; la siguiente llamada lo
          // completa o el [flush] lo emite como reasoning).
          done = true;
        } else if (idx + _closeTag.length > buffer.length) {
          // `</think>` empieza pero no entra completo. Hold as carry.
          done = true;
        } else {
          // `</think>` completo. Emitir reasoning previo y switch.
          if (idx > i) {
            outReasoning.write(buffer.substring(i, idx));
          }
          i = idx + _closeTag.length;
          _inThinking = false;
          // ─── Un bloque por call: BREAK despues de este bloque.
          // Ahora en modo text. Buscar el siguiente `<think>` o
          // el final del buffer. Si encontramos `<think>`, emitimos
          // el texto hasta el y dejamos el `<think>` en carry.
          // Si no, emitimos el resto (con safe region) y break.
          final nextThink = buffer.indexOf(_openTag, i);
          if (nextThink < 0) {
            final safeEnd = _findRightmostLtEnd(buffer);
            if (safeEnd > i) {
              outText.write(buffer.substring(i, safeEnd));
              i = safeEnd;
            }
          } else {
            if (nextThink > i) {
              outText.write(buffer.substring(i, nextThink));
            }
            i = nextThink; // el `<think>` queda en carry
          }
          done = true;
        }
      }
    }

    _carry = buffer.substring(i);
    return (
      textDelta: outText.toString(),
      reasoningDelta: outReasoning.toString(),
    );
  }

  /// Llamado al final del stream. Emite cualquier residuo en
  /// [carry] segun el modo actual. Resetea [_inThinking] a
  /// `false` siempre (el carry ya se proceso, no hay mas
  /// contexto de "estamos pensando").
  ({String textDelta, String reasoningDelta}) flush() {
    final wasInThinking = _inThinking;
    _inThinking = false;
    if (_carry.isEmpty) {
      return (textDelta: '', reasoningDelta: '');
    }
    final tail = _carry;
    _carry = '';
    if (wasInThinking) {
      return (textDelta: '', reasoningDelta: tail);
    }
    return (textDelta: tail, reasoningDelta: '');
  }

  /// Encuentra el indice seguro hasta donde emitir texto sin
  /// riesgo de partir un tag. Busca el `<` mas a la derecha en
  /// los ultimos [_maxTagLen] chars del buffer. Si lo encuentra,
  /// devuelve su posicion (para emitir hasta ahi y mantener el
  /// resto en carry). Si no, devuelve [buffer]`.length` (emitir
  /// todo).
  int _findRightmostLtEnd(String buffer) {
    int safeEnd = buffer.length;
    final scanStart = (buffer.length - _maxTagLen).clamp(0, buffer.length);
    for (int k = buffer.length - 1; k >= scanStart; k--) {
      if (buffer[k] == '<') {
        safeEnd = k;
        break;
      }
    }
    return safeEnd;
  }
}

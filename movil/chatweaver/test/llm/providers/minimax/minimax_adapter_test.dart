import 'package:chatweaver/llm/providers/minimax/dto/minimax_response_dto.dart';
import 'package:chatweaver/llm/providers/minimax/minimax_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests del mapeo de DTOs MiniMax → chunks de dominio.
///
/// **OQ-01 resuelto (empirico)**: MiniMax NO emite `reasoning_content`
/// como campo separado. El reasoning viene inline en `content`
/// con tags `<think>...</think>`. La separacion se hace en
/// [MiniMaxProvider] con [ThinkingStreamParser], no aca (el
/// adapter es stateless).
///
/// **OQ-02**: `usage.reasoningTokens` puede o no existir; si
/// viene, se mapea a `LlmUsage.thinkingTokens`.
void main() {
  group('MiniMaxAdapter.toChunk', () {
    test(
      'mapea content a textDelta tal cual (parser se aplica en provider)',
      () {
        // OJO: el adapter pasa el content tal cual, INCLUYENDO
        // posibles tags `<think>`. La limpieza la hace el provider.
        final dto = MiniMaxResponseDTO(
          id: 'r1',
          choices: [
            MiniMaxChoiceDTO(
              delta: MiniMaxDeltaDTO(content: '<think>pensemos...</think>42'),
            ),
          ],
          usage: const MiniMaxUsageDTO(
            promptTokens: 5,
            completionTokens: 2,
            reasoningTokens: 4,
          ),
        );

        final chunk = MiniMaxAdapter.toChunk(dto);

        // El adapter pasa el content tal cual (con tags).
        expect(chunk.textDelta, '<think>pensemos...</think>42');
        // El reasoningDelta queda null aca; lo emite el provider
        // despues de pasar el content por el parser.
        expect(chunk.reasoningDelta, isNull);
        // El thinkingTokens del usage SI se mapea aca.
        expect(chunk.usage?.thinkingTokens, 4);
      },
    );

    test('DTO sin content → chunk con textDelta null', () {
      final dto = MiniMaxResponseDTO(id: 'r1');
      final chunk = MiniMaxAdapter.toChunk(dto);
      expect(chunk.textDelta, isNull);
      expect(chunk.reasoningDelta, isNull);
      expect(chunk.usage, isNull);
    });

    test('finishReason se toma del choice o del top-level', () {
      final dto1 = MiniMaxResponseDTO(
        id: 'r1',
        choices: [MiniMaxChoiceDTO(finishReason: 'stop')],
      );
      expect(MiniMaxAdapter.toChunk(dto1).finishReason, 'stop');

      final dto2 = MiniMaxResponseDTO(id: 'r2', finishReason: 'length');
      expect(MiniMaxAdapter.toChunk(dto2).finishReason, 'length');
    });

    test('usage sin reasoningTokens → thinkingTokens 0 (fallback OQ-02)', () {
      final dto = MiniMaxResponseDTO(
        id: 'r1',
        usage: const MiniMaxUsageDTO(promptTokens: 5, completionTokens: 2),
      );
      final chunk = MiniMaxAdapter.toChunk(dto);
      expect(chunk.usage?.thinkingTokens, 0);
    });
  });
}

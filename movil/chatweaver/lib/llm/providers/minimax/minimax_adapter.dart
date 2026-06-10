import 'package:chatweaver/llm/chat_message.dart';
import 'package:chatweaver/llm/generate_response.dart';

import 'dto/minimax_request_dto.dart';
import 'dto/minimax_response_dto.dart';

/// Adapter Pattern: traduce entre DTOs nativos de MiniMax y
/// las entidades de dominio ([ChatMessage], [GenerateResponseChunk]).
///
/// Es la unica frontera valida entre el provider y el caso de uso.
class MiniMaxAdapter {
  const MiniMaxAdapter._();

  /// Mapea una respuesta cruda de MiniMax a un chunk de dominio.
  ///
  /// **OQ-01 resuelto**: el campo `delta.content` puede contener
  /// tags `<think>...</think>` inline para modelos thinking. La
  /// separacion reasoning/answer NO se hace aca (somos stateless);
  /// se hace en [MiniMaxProvider] con [ThinkingStreamParser].
  ///
  /// **OQ-02**: `usage.reasoningTokens` puede o no existir. Si
  /// viene, lo propagamos como `LlmUsage.thinkingTokens`. Si no,
  /// el caso de uso [SendMessage] hace fallback a length/4 del
  /// reasoning buffer.
  static GenerateResponseChunk toChunk(MiniMaxResponseDTO dto) {
    final choice = dto.choices?.isNotEmpty ?? false ? dto.choices!.first : null;
    return GenerateResponseChunk(
      textDelta: choice?.delta?.content,
      usage: dto.usage == null
          ? null
          : LlmUsage(
              inputTokens: dto.usage!.promptTokens ?? 0,
              outputTokens: dto.usage!.completionTokens ?? 0,
              thinkingTokens: dto.usage!.reasoningTokens ?? 0,
            ),
      finishReason: choice?.finishReason ?? dto.finishReason,
    );
  }

  static MiniMaxMessageDTO toDto(ChatMessage message) {
    return MiniMaxMessageDTO(
      role: _toApiRole(message.role),
      content: message.content,
    );
  }

  static String _toApiRole(ChatRole role) => switch (role) {
    ChatRole.system => 'system',
    ChatRole.user => 'user',
    ChatRole.assistant => 'assistant',
  };
}

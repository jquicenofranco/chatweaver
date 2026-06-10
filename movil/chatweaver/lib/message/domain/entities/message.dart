import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';

enum MessageRole { system, user, assistant }

enum MessageStatus { sending, streaming, complete, failed }

/// Mensaje persistido de una sesion.
///
/// **Spec 05 (T-04)**: `reasoning` lleva el trace de razonamiento
/// del modelo cuando este produce chain-of-thought. Es **nullable**
/// porque: (a) mensajes pre-existentes en DB v2 no lo tienen,
/// (b) modelos no-thinking no lo producen,
/// (c) providers que no exponen el campo lo dejan null.
/// NUNCA se mezcla con `content` (C-BIZ-01); la UI lo renderiza
/// en un widget separado ([ReasoningPanel]).
@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String sessionId,
    required MessageRole role,
    required String content,
    String? reasoning,
    int? inputTokens,
    int? outputTokens,

    /// Thinking tokens autoritativos del provider. Distinto de
    /// `outputTokens` (C-TECH-06). Nullable: null para mensajes
    /// sin thinking (modelos no-thinking, providers sin reporte).
    int? thinkingTokens,
    @Default(MessageStatus.complete) MessageStatus status,
    String? errorMessage,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _Message;
}

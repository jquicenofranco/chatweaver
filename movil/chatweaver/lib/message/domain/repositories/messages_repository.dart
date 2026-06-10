import 'package:chatweaver/message/domain/entities/message.dart';

/// Repositorio de mensajes de una sesion.
///
/// **Spec 05 (T-12)**: agregado `updateReasoning` para persistir
/// el reasoning trace incrementalmente durante el streaming
/// (un write por chunk). `updateTokenUsage` extendido con
/// `thinkingTokens` (3ra categoria, C-TECH-06).
abstract class MessagesRepository {
  Stream<List<Message>> watchBySession(String sessionId);

  Future<List<Message>> listBySession(String sessionId);

  Future<void> append(Message message);

  Future<void> updateContent(String id, String content);

  /// **Spec 05**: persistir el reasoning incremental. Se llama
  /// con el buffer acumulado a cada chunk de `reasoningDelta`.
  Future<void> updateReasoning(String id, String reasoning);

  Future<void> updateStatus(String id, MessageStatus status, {String? error});

  /// Actualiza el uso de tokens. Los tres campos son opcionales
  /// nombrados; null significa "no cambiar".
  Future<void> updateTokenUsage(
    String id, {
    int? inputTokens,
    int? outputTokens,
    int? thinkingTokens,
  });

  Future<void> patch(String id, {DateTime? completedAt});

  Future<void> deleteById(String id);
}

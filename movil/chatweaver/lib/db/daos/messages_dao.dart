import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/messages_table.dart';

part 'messages_dao.g.dart';

@DriftAccessor(tables: [Messages])
class MessagesDao extends DatabaseAccessor<AppDatabase>
    with _$MessagesDaoMixin {
  MessagesDao(super.db);

  Stream<List<MessageRow>> watchBySession(String sessionId) =>
      (select(messages)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .watch();

  Future<List<MessageRow>> listBySession(String sessionId) =>
      (select(messages)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .get();

  Future<void> insertRow(MessagesCompanion row) => into(messages).insert(row);

  Future<void> updateContent(String id, String content) =>
      (update(messages)..where((t) => t.id.equals(id))).write(
        MessagesCompanion(content: Value(content)),
      );

  /// **Spec 05 (T-12)**: persistir el reasoning incremental. Se
  /// llama una vez por chunk de `reasoningDelta` durante el
  /// streaming (envuelto en un `StringBuffer` en el caso de uso).
  Future<void> updateReasoning(String id, String reasoning) =>
      (update(messages)..where((t) => t.id.equals(id))).write(
        MessagesCompanion(reasoning: Value(reasoning)),
      );

  Future<void> updateStatus(String id, String status, {String? error}) =>
      (update(messages)..where((t) => t.id.equals(id))).write(
        MessagesCompanion(status: Value(status), errorMessage: Value(error)),
      );

  /// Actualiza el uso de tokens. Los tres campos son **opcionales
  /// nombrados** para que el caller solo mande lo que quiere
  /// cambiar. `thinkingTokens` es la 3ra categoria (spec 05
  /// C-TECH-06), independiente de `outputTokens`.
  Future<void> updateTokenUsage(
    String id, {
    int? inputTokens,
    int? outputTokens,
    int? thinkingTokens,
  }) => (update(messages)..where((t) => t.id.equals(id))).write(
    MessagesCompanion(
      inputTokens: Value(inputTokens),
      outputTokens: Value(outputTokens),
      thinkingTokens: Value(thinkingTokens),
    ),
  );

  Future<void> patch(String id, {DateTime? completedAt}) =>
      (update(messages)..where((t) => t.id.equals(id))).write(
        MessagesCompanion(completedAt: Value(completedAt)),
      );

  Future<void> deleteById(String id) =>
      (delete(messages)..where((t) => t.id.equals(id))).go();
}

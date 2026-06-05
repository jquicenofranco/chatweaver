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
      (update(messages)..where((t) => t.id.equals(id)))
          .write(MessagesCompanion(content: Value(content)));

  Future<void> updateStatus(String id, String status, {String? error}) =>
      (update(messages)..where((t) => t.id.equals(id))).write(
        MessagesCompanion(
          status: Value(status),
          errorMessage: Value(error),
        ),
      );

  Future<void> updateTokenUsage(
    String id, {
    int? inputTokens,
    int? outputTokens,
  }) =>
      (update(messages)..where((t) => t.id.equals(id))).write(
        MessagesCompanion(
          inputTokens: Value(inputTokens),
          outputTokens: Value(outputTokens),
        ),
      );

  Future<void> patch(String id, {DateTime? completedAt}) =>
      (update(messages)..where((t) => t.id.equals(id)))
          .write(MessagesCompanion(completedAt: Value(completedAt)));

  Future<void> deleteById(String id) =>
      (delete(messages)..where((t) => t.id.equals(id))).go();
}

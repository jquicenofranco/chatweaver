import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sessions_table.dart';

part 'sessions_dao.g.dart';

@DriftAccessor(tables: [Sessions])
class SessionsDao extends DatabaseAccessor<AppDatabase>
    with _$SessionsDaoMixin {
  SessionsDao(super.db);

  Stream<List<SessionRow>> watchAll() =>
      (select(sessions)..orderBy([
            (t) => OrderingTerm(
              expression: t.lastMessageAt,
              mode: OrderingMode.desc,
              nulls: NullsOrder.last,
            ),
          ]))
          .watch();

  Stream<List<SessionRow>> watchByModel(String modelId) =>
      (select(sessions)
            ..where((t) => t.modelId.equals(modelId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.lastMessageAt,
                mode: OrderingMode.desc,
                nulls: NullsOrder.last,
              ),
            ]))
          .watch();

  Stream<List<SessionRow>> watchByProvider(String providerId) =>
      (select(sessions)..where((t) => t.providerId.equals(providerId))).watch();

  Future<List<SessionRow>> listAll() => select(sessions).get();

  Future<SessionRow?> getById(String id) =>
      (select(sessions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insertRow(SessionsCompanion row) => into(sessions).insert(row);

  Future<void> updateTitle(String id, String title) =>
      (update(sessions)..where((t) => t.id.equals(id))).write(
        SessionsCompanion(
          title: Value(title),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> updateSystemPrompt(String id, String? systemPrompt) =>
      (update(sessions)..where((t) => t.id.equals(id))).write(
        SessionsCompanion(systemPrompt: Value(systemPrompt)),
      );

  Future<void> deleteById(String id) =>
      (delete(sessions)..where((t) => t.id.equals(id))).go();

  Future<void> touch(String id, DateTime when) =>
      (update(sessions)..where((t) => t.id.equals(id))).write(
        SessionsCompanion(lastMessageAt: Value(when), updatedAt: Value(when)),
      );

  Future<void> accumulateTokens(
    String id, {
    required int input,
    required int output,
  }) async {
    final row = await getById(id);
    if (row == null) return;
    await (update(sessions)..where((t) => t.id.equals(id))).write(
      SessionsCompanion(
        totalInputTokens: Value(row.totalInputTokens + input),
        totalOutputTokens: Value(row.totalOutputTokens + output),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

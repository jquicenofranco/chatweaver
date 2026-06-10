import 'package:drift/drift.dart';

import 'package:chatweaver/db/app_database.dart';
import 'package:chatweaver/db/mappers/session_mapper.dart';
import 'package:chatweaver/session/domain/entities/chat_session.dart';
import 'package:chatweaver/session/domain/repositories/sessions_repository.dart';

class SessionsRepositoryImpl implements SessionsRepository {
  SessionsRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<ChatSession>> watchAll() => _db.sessionsDao.watchAll().map(
    (rows) => rows.map((r) => r.toDomain()).toList(growable: false),
  );

  @override
  Stream<List<ChatSession>> watchByModel(String modelId) => _db.sessionsDao
      .watchByModel(modelId)
      .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));

  @override
  Stream<List<ChatSession>> watchByProvider(String providerId) => _db
      .sessionsDao
      .watchByProvider(providerId)
      .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));

  @override
  Future<List<ChatSession>> listAll() async {
    final rows = await _db.sessionsDao.listAll();
    return rows.map((r) => r.toDomain()).toList(growable: false);
  }

  @override
  Future<ChatSession?> getById(String id) async {
    final row = await _db.sessionsDao.getById(id);
    return row?.toDomain();
  }

  @override
  Future<void> create(ChatSession session) async {
    await _db.sessionsDao.insertRow(
      SessionsCompanion.insert(
        id: session.id,
        title: session.title,
        modelId: session.modelId,
        providerId: session.providerId,
        systemPrompt: Value(session.systemPrompt),
        totalInputTokens: Value(session.totalInputTokens),
        totalOutputTokens: Value(session.totalOutputTokens),
        lastMessageAt: Value(session.lastMessageAt),
        createdAt: session.createdAt,
        updatedAt: session.updatedAt,
      ),
    );
  }

  @override
  Future<void> rename(String id, String newTitle) =>
      _db.sessionsDao.updateTitle(id, newTitle);

  @override
  Future<void> updateSystemPrompt(String id, String? systemPrompt) =>
      _db.sessionsDao.updateSystemPrompt(id, systemPrompt);

  @override
  Future<void> delete(String id) => _db.sessionsDao.deleteById(id);

  @override
  Future<void> touch(String id, DateTime when) =>
      _db.sessionsDao.touch(id, when);

  @override
  Future<void> accumulateTokens(String id, {int input = 0, int output = 0}) =>
      _db.sessionsDao.accumulateTokens(id, input: input, output: output);
}

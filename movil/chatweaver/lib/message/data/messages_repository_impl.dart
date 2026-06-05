import 'package:drift/drift.dart';

import 'package:chatweaver/db/app_database.dart';
import 'package:chatweaver/db/mappers/message_mapper.dart';
import 'package:chatweaver/message/domain/entities/message.dart';
import 'package:chatweaver/message/domain/repositories/messages_repository.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  MessagesRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Message>> watchBySession(String sessionId) => _db.messagesDao
      .watchBySession(sessionId)
      .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));

  @override
  Future<List<Message>> listBySession(String sessionId) async {
    final rows = await _db.messagesDao.listBySession(sessionId);
    return rows.map((r) => r.toDomain()).toList(growable: false);
  }

  @override
  Future<void> append(Message message) async {
    await _db.messagesDao.insertRow(
      MessagesCompanion.insert(
        id: message.id,
        sessionId: message.sessionId,
        role: _roleToString(message.role),
        content: message.content,
        inputTokens: Value(message.inputTokens),
        outputTokens: Value(message.outputTokens),
        status: _statusToString(message.status),
        errorMessage: Value(message.errorMessage),
        createdAt: message.createdAt,
        completedAt: Value(message.completedAt),
      ),
    );
  }

  @override
  Future<void> updateContent(String id, String content) =>
      _db.messagesDao.updateContent(id, content);

  @override
  Future<void> updateStatus(
    String id,
    MessageStatus status, {
    String? error,
  }) =>
      _db.messagesDao.updateStatus(id, _statusToString(status), error: error);

  @override
  Future<void> updateTokenUsage(
    String id, {
    int? inputTokens,
    int? outputTokens,
  }) =>
      _db.messagesDao.updateTokenUsage(
        id,
        inputTokens: inputTokens,
        outputTokens: outputTokens,
      );

  @override
  Future<void> patch(String id, {DateTime? completedAt}) =>
      _db.messagesDao.patch(id, completedAt: completedAt);

  @override
  Future<void> deleteById(String id) => _db.messagesDao.deleteById(id);

  String _roleToString(MessageRole r) => switch (r) {
        MessageRole.system => 'system',
        MessageRole.user => 'user',
        MessageRole.assistant => 'assistant',
      };

  String _statusToString(MessageStatus s) => switch (s) {
        MessageStatus.sending => 'sending',
        MessageStatus.streaming => 'streaming',
        MessageStatus.complete => 'complete',
        MessageStatus.failed => 'failed',
      };
}

import 'package:chatweaver/session/domain/entities/chat_session.dart';

abstract class SessionsRepository {
  Stream<List<ChatSession>> watchAll();

  Stream<List<ChatSession>> watchByModel(String modelId);

  Stream<List<ChatSession>> watchByProvider(String providerId);

  Future<List<ChatSession>> listAll();

  Future<ChatSession?> getById(String id);

  Future<void> create(ChatSession session);

  Future<void> rename(String id, String newTitle);

  Future<void> updateSystemPrompt(String id, String? systemPrompt);

  Future<void> delete(String id);

  Future<void> touch(String id, DateTime when);

  Future<void> accumulateTokens(String id, {int input = 0, int output = 0});
}

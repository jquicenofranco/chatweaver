import 'package:chatweaver/message/domain/entities/message.dart';

abstract class MessagesRepository {
  Stream<List<Message>> watchBySession(String sessionId);

  Future<List<Message>> listBySession(String sessionId);

  Future<void> append(Message message);

  Future<void> updateContent(String id, String content);

  Future<void> updateStatus(
    String id,
    MessageStatus status, {
    String? error,
  });

  Future<void> updateTokenUsage(
    String id, {
    int? inputTokens,
    int? outputTokens,
  });

  Future<void> patch(String id, {DateTime? completedAt});

  Future<void> deleteById(String id);
}

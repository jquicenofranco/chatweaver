import 'package:chatweaver/message/domain/entities/message.dart';
import 'package:chatweaver/message/domain/repositories/messages_repository.dart';

class GetSessionMessages {
  const GetSessionMessages(this._repo);

  final MessagesRepository _repo;

  Stream<List<Message>> watch(String sessionId) =>
      _repo.watchBySession(sessionId);

  Future<List<Message>> list(String sessionId) =>
      _repo.listBySession(sessionId);
}

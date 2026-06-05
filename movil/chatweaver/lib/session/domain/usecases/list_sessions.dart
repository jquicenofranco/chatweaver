import 'package:chatweaver/session/domain/entities/chat_session.dart';
import 'package:chatweaver/session/domain/repositories/sessions_repository.dart';

class ListSessions {
  const ListSessions(this._repo);

  final SessionsRepository _repo;

  Stream<List<ChatSession>> watchByModel(String modelId) =>
      _repo.watchByModel(modelId);

  Stream<List<ChatSession>> watchAll() => _repo.watchAll();
}

import 'package:chatweaver/session/domain/repositories/sessions_repository.dart';

class DeleteSession {
  const DeleteSession(this._repo);

  final SessionsRepository _repo;

  Future<void> call(String id) => _repo.delete(id);
}

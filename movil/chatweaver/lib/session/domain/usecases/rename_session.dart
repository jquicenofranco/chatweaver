import 'package:chatweaver/session/domain/repositories/sessions_repository.dart';

class RenameSession {
  const RenameSession(this._repo);

  final SessionsRepository _repo;

  Future<void> call(String id, String newTitle) => _repo.rename(id, newTitle);
}

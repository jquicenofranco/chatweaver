import 'package:chatweaver/message/domain/entities/message.dart';
import 'package:chatweaver/message/domain/repositories/messages_repository.dart';

class AppendMessage {
  const AppendMessage(this._repo);

  final MessagesRepository _repo;

  Future<void> call(Message message) => _repo.append(message);
}

import 'package:chatweaver/session/domain/entities/chat_session.dart';
import 'package:chatweaver/session/domain/repositories/sessions_repository.dart';
import 'package:uuid/uuid.dart';

class CreateSession {
  const CreateSession({
    required SessionsRepository sessions,
    required Uuid uuid,
  }) : _sessions = sessions,
       _uuid = uuid;

  final SessionsRepository _sessions;
  final Uuid _uuid;

  Future<String> call({
    required String modelId,
    required String providerId,
    String title = 'Nueva sesion',
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _sessions.create(
      ChatSession(
        id: id,
        title: title,
        modelId: modelId,
        providerId: providerId,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }
}

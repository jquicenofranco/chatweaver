import 'package:chatweaver/db/app_database.dart';
import 'package:chatweaver/session/domain/entities/chat_session.dart';

/// Mapper Drift Row -> Dominio.
///
/// Los DTOs de Drift NUNCA cruzan a la capa `domain/` o
/// `presentation/`. Toda conversion pasa por estas extensiones.
extension SessionMapper on SessionRow {
  ChatSession toDomain() => ChatSession(
        id: id,
        title: title,
        modelId: modelId,
        providerId: providerId,
        systemPrompt: systemPrompt,
        totalInputTokens: totalInputTokens,
        totalOutputTokens: totalOutputTokens,
        lastMessageAt: lastMessageAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

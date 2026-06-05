import 'package:chatweaver/db/app_database.dart';
import 'package:chatweaver/session/domain/entities/model_definition.dart';

extension ModelConfigMapper on ModelConfigRow {
  ModelDefinition toDomain() => ModelDefinition(
        id: id,
        providerId: providerId,
        displayName: displayName,
        contextWindow: contextWindow,
        supportsStreaming: supportsStreaming,
        apiBaseUrl: apiBaseUrl,
        enabled: enabled,
      );
}

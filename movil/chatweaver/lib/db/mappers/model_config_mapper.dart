import 'package:chatweaver/db/app_database.dart';
import 'package:chatweaver/session/domain/entities/model_definition.dart';

/// Mapea `ModelConfigRow` (Drift) → `ModelDefinition` (dominio).
///
/// **Spec 05 (T-11 equivalente para model_configs)**: incluye
/// `supportsReasoning`. El caso de uso `SendMessage` lo consulta
/// para decidir si enviar `reasoning_split: true` en el request.
extension ModelConfigMapper on ModelConfigRow {
  ModelDefinition toDomain() => ModelDefinition(
    id: id,
    providerId: providerId,
    displayName: displayName,
    contextWindow: contextWindow,
    supportsStreaming: supportsStreaming,
    supportsReasoning: supportsReasoning,
    apiBaseUrl: apiBaseUrl,
    enabled: enabled,
  );
}

import 'package:drift/drift.dart';

/// Tabla `model_configs` (catalogo sembrado + modelos del usuario).
///
/// **Spec 05 (T-26)**: `supportsReasoning` indica si el modelo
/// produce reasoning trace separado del answer. Default `false`
/// para backward-compat con DBs pre-existentes. Se backfilea a
/// `true` para MiniMax-M3 durante la migración v2 → v3.
@DataClassName('ModelConfigRow')
class ModelConfigs extends Table {
  TextColumn get id => text()();
  TextColumn get providerId => text()();
  TextColumn get displayName => text()();
  IntColumn get contextWindow => integer()();
  BoolColumn get supportsStreaming =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get supportsReasoning =>
      boolean().withDefault(const Constant(false))();
  TextColumn get apiBaseUrl => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

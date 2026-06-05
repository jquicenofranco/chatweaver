import 'package:drift/drift.dart';

@DataClassName('ModelConfigRow')
class ModelConfigs extends Table {
  TextColumn get id => text()();
  TextColumn get providerId => text()();
  TextColumn get displayName => text()();
  IntColumn get contextWindow => integer()();
  BoolColumn get supportsStreaming =>
      boolean().withDefault(const Constant(true))();
  TextColumn get apiBaseUrl => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

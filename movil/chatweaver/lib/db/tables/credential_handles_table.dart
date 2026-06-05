import 'package:drift/drift.dart';

@DataClassName('CredentialHandleRow')
class CredentialHandles extends Table {
  TextColumn get id => text()();
  TextColumn get providerId => text()();
  TextColumn get label => text()();
  TextColumn get secureKey => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

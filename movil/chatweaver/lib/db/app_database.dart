import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'daos/credential_handles_dao.dart';
import 'daos/messages_dao.dart';
import 'daos/model_configs_dao.dart';
import 'daos/sessions_dao.dart';
import 'tables/credential_handles_table.dart';
import 'tables/messages_table.dart';
import 'tables/model_configs_table.dart';
import 'tables/sessions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [ModelConfigs, Sessions, Messages, CredentialHandles],
  daos: [ModelConfigsDao, SessionsDao, MessagesDao, CredentialHandlesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  /// Constructor para tests: base de datos en memoria.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedModelConfigs();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _seedModelConfigs() async {
    final now = DateTime.now();
    final seed = <ModelConfigsCompanion>[
      ModelConfigsCompanion.insert(
        id: 'MiniMax-M',
        providerId: 'MiniMax',
        displayName: 'MiniMax M',
        contextWindow: 200000,
        supportsStreaming: const Value(true),
        createdAt: now,
      ),
      ModelConfigsCompanion.insert(
        id: 'MiniMax-XL',
        providerId: 'MiniMax',
        displayName: 'MiniMax XL',
        contextWindow: 200000,
        supportsStreaming: const Value(true),
        createdAt: now,
      ),
    ];
    for (final row in seed) {
      await into(modelConfigs).insertOnConflictUpdate(row);
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'chatweaver.db'));
    return NativeDatabase.createInBackground(file);
  });
}

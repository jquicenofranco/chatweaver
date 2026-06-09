import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedModelConfigs();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v1 -> v2: el seed original uso IDs de modelo que no existen
            // en la API real de MiniMax (`MiniMax-M`, `MiniMax-XL`).
            // Todo ocurre dentro de una transaccion:
            //   1. Insertar los modelos reales (idempotente).
            //   2. Re-apuntar sesiones que apuntaban a los IDs
            //      obsoletos a `MiniMax-M3`.
            //   3. Borrar los modelos obsoletos (FK ON requiere que
            //      el paso 2 haya pasado primero).
            await migrateV1ToV2();
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _seedModelConfigs() async {
    final now = DateTime.now();
    final seed = <ModelConfigsCompanion>[
      ModelConfigsCompanion.insert(
        id: 'MiniMax-M3',
        providerId: 'MiniMax',
        displayName: 'MiniMax M3',
        contextWindow: 1000000,
        supportsStreaming: const Value(true),
        createdAt: now,
      ),
      ModelConfigsCompanion.insert(
        id: 'MiniMax-M2.7',
        providerId: 'MiniMax',
        displayName: 'MiniMax M2.7',
        contextWindow: 204800,
        supportsStreaming: const Value(true),
        createdAt: now,
      ),
      ModelConfigsCompanion.insert(
        id: 'MiniMax-M2.7-highspeed',
        providerId: 'MiniMax',
        displayName: 'MiniMax M2.7 Highspeed',
        contextWindow: 204800,
        supportsStreaming: const Value(true),
        createdAt: now,
      ),
    ];
    for (final row in seed) {
      await into(modelConfigs).insertOnConflictUpdate(row);
    }
  }

  /// Usado por la migracion v1 -> v2. Reemplaza los modelos seed
  /// viejos (que no existen en la API real) por los reales, sin
  /// tocar modelos definidos por el usuario. Tambien re-apunta
  /// cualquier sesion huerfana a `MiniMax-M3` para no perder
  /// historial.
  ///
  /// Implementado como una sola transaccion para que la DB nunca
  /// quede en un estado inconsistente si una de las operaciones
  /// falla a mitad de camino.
  @visibleForTesting
  Future<void> migrateV1ToV2() async {
    const obsoleteIds = ['MiniMax-M', 'MiniMax-XL'];
    const fallbackModelId = 'MiniMax-M3';

    await transaction(() async {
      // 1. Insertar los modelos reales (insertOnConflictUpdate es
      //    idempotente: si ya estan, no hace nada).
      await _seedModelConfigs();

      // 2. Re-apuntar sesiones que apuntaban a IDs obsoletos al
      //    modelo flagship. Si el usuario no tiene `MiniMax-M3` por
      //    algun motivo, no tocamos sus sesiones.
      if (await _modelExists(fallbackModelId)) {
        await (update(sessions)
              ..where((t) => t.modelId.isIn(obsoleteIds)))
            .write(SessionsCompanion(modelId: const Value(fallbackModelId)));
      }

      // 3. Borrar los modelos obsoletos. Ahora es seguro porque
      //    `PRAGMA foreign_keys = ON` (seteado en beforeOpen) ya no
      //    tiene referencias apuntando a ellos.
      await (delete(modelConfigs)..where((t) => t.id.isIn(obsoleteIds)))
          .go();
    });
  }

  Future<bool> _modelExists(String id) async {
    final row = await (select(modelConfigs)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'chatweaver.db'));
    return NativeDatabase.createInBackground(file);
  });
}

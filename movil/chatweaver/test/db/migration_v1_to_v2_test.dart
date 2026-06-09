import 'package:chatweaver/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cubre la migracion v1 -> v2 del schema de ChatWeaver.
///
/// El seed historico uso IDs de modelo que NO existen en la API real
/// de MiniMax (`MiniMax-M`, `MiniMax-XL`). La migracion:
///   1. Borra esas filas obsoletas.
///   2. Inserta los IDs reales (`MiniMax-M3`, `MiniMax-M2.7`,
///      `MiniMax-M2.7-highspeed`).
///   3. Re-apunta cualquier sesion huerfana a `MiniMax-M3` para no
///      perder el historial.
///
/// Los metodos de migracion estan marcados `@visibleForTesting`
/// para poder invocarlos desde una DB ya inicializada (en lugar de
/// tener que forzar un ciclo close/reopen con archivo en disco).
void main() {
  late AppDatabase db;

  Future<void> seedV1State() async {
    // Simula el estado v1: insertar los IDs obsoletos y una sesion
    // apuntando a uno de ellos.
    final now = DateTime.now();
    await db.into(db.modelConfigs).insertOnConflictUpdate(
          ModelConfigsCompanion.insert(
            id: 'MiniMax-M',
            providerId: 'MiniMax',
            displayName: 'MiniMax M',
            contextWindow: 200000,
            createdAt: now,
          ),
        );
    await db.into(db.modelConfigs).insertOnConflictUpdate(
          ModelConfigsCompanion.insert(
            id: 'MiniMax-XL',
            providerId: 'MiniMax',
            displayName: 'MiniMax XL',
            contextWindow: 200000,
            createdAt: now,
          ),
        );
    await db.into(db.sessions).insert(
          SessionsCompanion.insert(
            id: 's-orphan',
            title: 'Sesion vieja',
            modelId: 'MiniMax-M',
            providerId: 'MiniMax',
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('onCreate siembra los 3 modelos reales de MiniMax', () async {
    final models = await db.modelConfigsDao.getAll();
    final ids = models.map((m) => m.id).toSet();
    expect(ids, containsAll(<String>{
      'MiniMax-M3',
      'MiniMax-M2.7',
      'MiniMax-M2.7-highspeed',
    }));
    expect(ids, isNot(contains('MiniMax-M')));
    expect(ids, isNot(contains('MiniMax-XL')));

    final m3 = models.firstWhere((m) => m.id == 'MiniMax-M3');
    expect(m3.providerId, 'MiniMax');
    expect(m3.contextWindow, 1000000);
  });

  test('migracion v1->v2 reemplaza IDs obsoletos y re-apunta sesiones',
      () async {
    // 1) Estado v1 simulado.
    await seedV1State();
    final initial = await db.modelConfigsDao.getAll();
    expect(initial.map((m) => m.id).toSet(),
        containsAll(<String>{'MiniMax-M', 'MiniMax-XL'}));

    // 2) Correr la migracion completa (transaccion atomica).
    await db.migrateV1ToV2();

    // 3) Verificar seed.
    final ids =
        (await db.modelConfigsDao.getAll()).map((m) => m.id).toSet();
    expect(ids, isNot(contains('MiniMax-M')));
    expect(ids, isNot(contains('MiniMax-XL')));
    expect(ids, containsAll(<String>{
      'MiniMax-M3',
      'MiniMax-M2.7',
      'MiniMax-M2.7-highspeed',
    }));

    // 4) Verificar re-apuntamiento de sesion huerfana.
    final session = await (db.select(db.sessions)
          ..where((t) => t.id.equals('s-orphan')))
        .getSingle();
    expect(session.modelId, 'MiniMax-M3',
        reason: 'La sesion huerfana debe re-apuntarse a M3.');
  });

  test('migracion es idempotente: correrla dos veces no duplica filas',
      () async {
    await seedV1State();
    await db.migrateV1ToV2();
    final afterFirst = await db.modelConfigsDao.getAll();

    await db.migrateV1ToV2();
    final afterSecond = await db.modelConfigsDao.getAll();

    expect(afterSecond.length, afterFirst.length,
        reason: 'La migracion debe ser idempotente (insertOnConflictUpdate).');
  });

  test('migracion no toca sesiones con modelId valido', () async {
    // Estado v1 + una sesion ya apuntando a un ID que va a seguir
    // existiendo (simulamos un modelo custom del usuario).
    final now = DateTime.now();
    await db.into(db.modelConfigs).insertOnConflictUpdate(
          ModelConfigsCompanion.insert(
            id: 'user-custom-model',
            providerId: 'MiniMax',
            displayName: 'User Model',
            contextWindow: 50000,
            createdAt: now,
          ),
        );
    await db.into(db.sessions).insert(
          SessionsCompanion.insert(
            id: 's-ok',
            title: 'OK',
            modelId: 'user-custom-model',
            providerId: 'MiniMax',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.migrateV1ToV2();

    final session = await (db.select(db.sessions)
          ..where((t) => t.id.equals('s-ok')))
        .getSingle();
    expect(session.modelId, 'user-custom-model',
        reason: 'La sesion valida NO debe tocarse.');
  });
}

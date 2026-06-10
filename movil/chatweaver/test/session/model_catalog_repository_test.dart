import 'package:chatweaver/db/app_database.dart';
import 'package:chatweaver/session/data/model_catalog_repository_impl.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests de [ModelCatalogRepositoryImpl] en memoria.
///
/// Cubre los metodos nuevos de spec 04 v2.0.0:
///   - [ModelCatalogRepositoryImpl.listByProvider]
///   - [ModelCatalogRepositoryImpl.listEnabledByProvider]
void main() {
  late AppDatabase db;
  late ModelCatalogRepositoryImpl repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // El onCreate del database siembra los 3 modelos MiniMax.
    // Esperamos a que la inicializacion async termine.
    await db.customSelect('SELECT 1').get();
    repo = ModelCatalogRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('listAll devuelve los 3 modelos del seed', () async {
    final models = await repo.listAll();
    expect(models.length, 3);
    expect(models.map((m) => m.id).toSet(), {
      'MiniMax-M3',
      'MiniMax-M2.7',
      'MiniMax-M2.7-highspeed',
    });
  });

  test('listByProvider("MiniMax") devuelve todos los del seed', () async {
    final models = await repo.listByProvider('MiniMax');
    expect(models.length, 3);
    expect(
      models.every((m) => m.providerId == 'MiniMax'),
      isTrue,
      reason: 'todos deben ser de MiniMax',
    );
  });

  test('listByProvider("desconocido") devuelve lista vacia', () async {
    final models = await repo.listByProvider('no-existe');
    expect(models, isEmpty);
  });

  test('listEnabledByProvider devuelve solo los enabled', () async {
    // Deshabilitamos uno de los modelos.
    await db.modelConfigsDao.setEnabled('MiniMax-M2.7', false);

    final models = await repo.listEnabledByProvider('MiniMax');
    expect(models.length, 2);
    expect(models.map((m) => m.id).toSet(), {
      'MiniMax-M3',
      'MiniMax-M2.7-highspeed',
    });
  });

  test('listEnabledByProvider respeta el providerId', () async {
    // Aunque deshabilitemos TODOS los MiniMax, listEnabledByProvider
    // de "otro" provider sigue dando vacio (no hay modelos de
    // otros providers en el seed).
    final models = await repo.listEnabledByProvider('otro');
    expect(models, isEmpty);
  });
}

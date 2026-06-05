# Fase 2 — Capa de base de datos (`db/`)

**Objetivo:** implementar el módulo `db/` completo: tablas Drift, `AppDatabase`, DAOs, `SecureCredentialStore`, mappers, y migraciones.
**Depende de:** Fase 1 (estructura de carpetas disponible).
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 2)

## Tareas
- [ ] Crear `lib/db/tables/` con las 4 tablas Drift (model_configs, sessions, messages, credential_handles).
- [ ] Ejecutar `build_runner` para generar `app_database.g.dart`.
- [ ] Crear `lib/db/daos/session_dao.dart` (singular, tipo `SessionRow`).
- [ ] Crear `lib/db/daos/message_dao.dart` (singular, tipo `MessageRow`).
- [ ] Crear `lib/db/daos/model_config_dao.dart` (singular, tipo `ModelConfigRow`).
- [ ] Crear `lib/db/daos/credential_handle_dao.dart` (singular, tipo `CredentialHandleRow`).
- [ ] Añadir DAOs como miembros de `AppDatabase`.
- [ ] Crear `lib/db/secure_credential_store.dart`.
- [ ] Crear `lib/db/credential_repository.dart` + `credential_repository_impl.dart`.
- [ ] Crear `lib/db/mappers/` con los mappers `SessionMapper`, `MessageMapper` (solo `toDomain()`, sin `toInsertable()`).
- [ ] Documentar convencion de migraciones: archivo `migration_N_to_M.dart` por cada upgrade de schema.
- [ ] Añadir placeholder `onUpgrade` en `AppDatabase` que haga `throw UnsupportedError` para saltos de version no esperados (fail-fast).
- [ ] Crear test: `test/db/migration_test.dart` (placeholder - se poblara cuando el esquema evolucione).
- [ ] Crear test: `test/db/credential_store_test.dart` (usa fake store en tests, no real Keychain).

## Criterios de aceptación
- [ ] `flutter analyze` limpio.
- [ ] `flutter test test/db/` pasa (usar `MockFlutterSecureStorage` con `mocktail`).
- [ ] Los 2 modelos MiniMax aparecen en la DB tras el primer arranque.
- [ ] `CredentialRepository` nunca expone el API key en texto plano fuera de la memoria.

## Tests
- [ ] `test/db/migration_test.dart`
- [ ] `test/db/credential_store_test.dart`

## Comandos
- [ ] `flutter pub get`
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter analyze`
- [ ] `flutter test test/db/`

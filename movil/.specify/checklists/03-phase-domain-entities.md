# Fase 3 — Entidades de dominio y repositorios (`session/`, `message/`)

**Objetivo:** implementar las entidades freezed en `domain/` de `session/` y `message/`, las interfaces de repositorio, y las implementaciones en `data/`.
**Depende de:** Fase 2 (`db/` disponible como implementación de los repositorios).
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 3)

## Tareas
- [ ] Crear `lib/session/domain/entities/chat_session.dart` (freezed).
- [ ] Crear `lib/session/domain/entities/model_definition.dart` (freezed).
- [ ] Crear `lib/message/domain/entities/message.dart` (freezed con enums).
- [ ] Crear `lib/message/domain/entities/token_usage.dart` (freezed).
- [ ] Crear `lib/db/credential_handle.dart` (freezed).
- [ ] Ejecutar `build_runner` para generar todos los `.freezed.dart`.
- [ ] Crear interfaces de repositorio en `session/domain/repositories/` y `message/domain/repositories/`.
- [ ] Crear `lib/session/data/sessions_repository_impl.dart`.
- [ ] Crear `lib/message/data/messages_repository_impl.dart`.
- [ ] Crear tests unitarios de mappers: `test/session/data/session_mapper_test.dart`, `test/message/data/message_mapper_test.dart`.
- [ ] Crear tests de repositorio con `MockAppDatabase` y `mocktail`.

## Criterios de aceptación
- [ ] `flutter analyze` limpio.
- [ ] Todos los `.freezed.dart` generados y versionados.
- [ ] Mapper cubre todos los campos de la entidad.
- [ ] Repositorio implementa todos los métodos de la interfaz.
- [ ] Tests de mapper verifican la bidireccionalidad (domain → row → domain, roundtrip).

## Tests
- [ ] `test/session/data/session_mapper_test.dart`
- [ ] `test/message/data/message_mapper_test.dart`

## Comandos
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter analyze`
- [ ] `flutter test test/session/`
- [ ] `flutter test test/message/`

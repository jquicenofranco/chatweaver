# Fase 13 — SessionsPanelScreen

**Objetivo:** implementar el CRUD de sesiones: listado, creación, renombrado, borrado.
**Depende de:** Fase 7 (providers), Fase 8 (casos de uso), Fase 10 (router).
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 13)

## Tareas
- [ ] Crear `lib/ui/sessions/sessions_panel_screen.dart`.
- [ ] Crear `lib/ui/sessions/providers/active_model_id_provider.dart`.
- [ ] Crear `lib/ui/sessions/widgets/session_tile.dart`.
- [ ] Crear `lib/ui/sessions/widgets/rename_session_dialog.dart`.
- [ ] Crear `lib/ui/sessions/widgets/delete_session_dialog.dart` (usa `ConfirmDialog`).
- [ ] Conectar `CreateSession` use case al FAB.
- [ ] Inyectar `activeModelIdProvider` desde la query param `modelId` en la ruta.
- [ ] Tests: `test/ui/sessions/sessions_panel_screen_test.dart`.

## Criterios de aceptación
- [ ] El Stream de sesiones se actualiza en tiempo real cuando se crea/renombra/borra una sesión (sin hacer refresh manual).
- [ ] Crear una sesión nueva navega a `/chat/:newId` inmediatamente.
- [ ] Renombrar y borrar no navegan; solo actualizan el Stream.
- [ ] El FAB solo aparece si hay un `modelId` activo.

## Tests
- [ ] `test/ui/sessions/sessions_panel_screen_test.dart`

## Comandos
- [ ] `flutter analyze`
- [ ] `flutter test test/ui/sessions/`

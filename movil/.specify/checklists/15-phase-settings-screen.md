# Fase 15 — SettingsScreen

**Objetivo:** implementar la pantalla de ajustes con gestión de credenciales, modelos, tema, e idioma.
**Depende de:** Fases 7, 9, 10.
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 15)

## Tareas
- [ ] Crear `lib/ui/settings/settings_screen.dart`.
- [ ] Crear `lib/ui/settings/widgets/credential_list_tile.dart`.
- [ ] Crear `lib/ui/settings/widgets/model_config_switch.dart`.
- [ ] Crear `lib/ui/settings/widgets/theme_selector.dart`.
- [ ] Crear `lib/ui/settings/widgets/language_selector.dart`.
- [ ] Crear `lib/ui/settings/widgets/advanced_section.dart`.
- [ ] Crear `lib/ui/settings/widgets/about_section.dart`.
- [ ] Conectar `ModelCatalogRepository.setEnabled` al toggle de cada modelo.
- [ ] Persistir `ThemeMode` en `shared_preferences` (solo la preferencia, no el token).
- [ ] Persistir locale en `shared_preferences`.
- [ ] Tests: `test/ui/settings/settings_screen_test.dart`.

## Criterios de aceptación
- [ ] Deshabilitar un modelo lo oculta del `ModelSelectorScreen` sin borrarlo de la DB.
- [ ] Borrar una credencial la elimina de `flutter_secure_storage` y de la tabla `credential_handles`.
- [ ] El tema seleccionado se aplica inmediatamente (sin restart de la app).
- [ ] No hay opción de exportar datos en MVP (se marca como "próximamente").

## Tests
- [ ] `test/ui/settings/settings_screen_test.dart`

## Comandos
- [ ] `flutter analyze`
- [ ] `flutter test test/ui/settings/`

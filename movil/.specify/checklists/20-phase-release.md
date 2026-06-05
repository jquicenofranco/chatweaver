# Fase 20 — Test final y release

**Objetivo:** test de integración del flujo completo happy path y preparación para release.
**Depende de:** Fases 1-19 (app completa).
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 20)

## Tareas
- [ ] Test de integración — Flujo happy path: `integration_test/first_use_flow_test.dart` (splash → modelo → token → sesión → chat).
- [ ] Test de integración — Manejo de errores: `integration_test/error_flows_test.dart` (token inválido muestra SnackBar, sesión no encontrada redirige, streaming abortado deja mensaje parcial).
- [ ] `flutter pub upgrade --major-versions` y resolver conflictos.
- [ ] `flutter analyze` 0 errores, 0 warnings.
- [ ] `flutter test` pasa (unit + widget + integration).
- [ ] Build de debug: `flutter build apk --debug`.
- [ ] Build de release: `flutter build apk --release`.
- [ ] `dart run build_runner build --delete-conflicting-outputs` corriendo en CI.
- [ ] Revisar `CHANGELOG.md` (o crearlo).
- [ ] Revisar `pubspec.yaml` version para el release tag.
- [ ] Verificar que `secureStorageProvider` tiene `aOptions: AndroidOptions(encryptedSharedPreferences: true)` y `iOptions` equivalentes.
- [ ] Verificar que no hay `print` statements en release (analizador lo detecta con `avoid_print`).

## Criterios de aceptación
- [ ] El flujo de primer uso se completa sin errores en `integration_test/first_use_flow_test.dart`.
- [ ] Los flujos de error se completan sin crashes en `integration_test/error_flows_test.dart`.
- [ ] Los builds de debug y release se generan correctamente.

## Tests
- [ ] `integration_test/first_use_flow_test.dart`
- [ ] `integration_test/error_flows_test.dart`

## Comandos
- [ ] `flutter pub upgrade --major-versions`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter build apk --debug`
- [ ] `flutter build apk --release`

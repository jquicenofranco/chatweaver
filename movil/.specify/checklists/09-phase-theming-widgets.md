# Fase 9 — Theming y widgets compartidos

**Objetivo:** implementar el tema Material 3 y los widgets compartidos reutilizables.
**Depende de:** Fase 7 (providers disponibles para theming).
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 9)

## Tareas
- [ ] Crear `lib/ui/theme/app_theme.dart` con light y dark.
- [ ] Crear `lib/ui/shared/primary_button.dart`.
- [ ] Crear `lib/ui/shared/loading_overlay.dart`.
- [ ] Crear `lib/ui/shared/error_view.dart`.
- [ ] Crear `lib/ui/shared/confirm_dialog.dart`.
- [ ] Crear `lib/ui/shared/empty_state_view.dart`.
- [ ] Crear `lib/ui/shared/icons.dart` (iconos placeholder para proveedores, si no se usan assets).
- [ ] Tests: `test/ui/shared/primary_button_test.dart`, `test/ui/shared/error_view_test.dart` usando `testWidgets`.

## Criterios de aceptación
- [ ] `PrimaryButton` muestra `CircularProgressIndicator` cuando `isLoading = true` y `onPressed` es null.
- [ ] `ErrorView` permite pasar un callback de reintentar (null = hide botón).
- [ ] `ConfirmDialog` recibe `title`, `message`, `confirmLabel` (default "Eliminar"), `isDestructive` (default true). Botón cancelar siempre presente.

## Tests
- [ ] `test/ui/shared/primary_button_test.dart`
- [ ] `test/ui/shared/error_view_test.dart`

## Comandos
- [ ] `flutter analyze`
- [ ] `flutter test test/ui/shared/`

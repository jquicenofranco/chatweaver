# Fase 11 — Splash + ModelSelector

**Objetivo:** implementar `SplashScreen` y `ModelSelectorScreen` con `availableModelsProvider` y `ModelCard`.
**Depende de:** Fase 10 (router), Fase 7 (providers).
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 11)

## Tareas
- [ ] Crear `lib/ui/splash/splash_screen.dart`.
- [ ] Crear `lib/ui/home/model_selector_screen.dart`.
- [ ] Crear `lib/ui/home/providers/available_models_provider.dart` (`FutureProvider` que delega a `modelCatalogRepositoryProvider`).
- [ ] Crear `lib/ui/home/widgets/model_card.dart`.
- [ ] Crear `lib/ui/home/widgets/disable_model_sheet.dart`.
- [ ] Implementar estado vacío (`EmptyStateView`) cuando no hay modelos habilitados.
- [ ] Implementar estado de error (`ErrorView`) cuando falla la carga del catálogo.
- [ ] Tests: `test/ui/home/model_selector_screen_test.dart` con `ProviderContainer` override.

## Criterios de aceptación
- [ ] La lista de modelos viene del catálogo local (`modelCatalogRepository`), no de la red.
- [ ] Deshabilitar un modelo actualiza `model_configs.enabled` y la lista se refresca.
- [ ] `EmptyStateView` tiene CTA "Ir a Ajustes" → `/settings`.
- [ ] Long-press en `ModelCard` muestra el bottom sheet sin navegar.

## Tests
- [ ] `test/ui/home/model_selector_screen_test.dart`

## Comandos
- [ ] `flutter analyze`
- [ ] `flutter test test/ui/home/`

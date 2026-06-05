# Fase 7 — Inyección de dependencias (`di/`)

**Objetivo:** implementar `lib/di/global_providers.dart` con todos los Riverpod providers globales que la app consume.
**Depende de:** Fases 2, 3, 4, 5, 6 (todos los módulos base disponibles).
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 7)

## Tareas
- [ ] Crear `lib/di/global_providers.dart` completo con todos los providers.
- [ ] Crear `test/di/global_providers_test.dart` que use `ProviderContainer` para verificar que cada provider se resuelve sin error circular.
- [ ] Verificar que `appDatabaseProvider` cierra la conexión en `onDispose`.
- [ ] Verificar que `hasAnyCredentialProvider` es `false` al inicio (sin credenciales guardadas) y `true` tras guardar una.

## Criterios de aceptación
- [ ] `flutter analyze` limpio.
- [ ] `test/di/global_providers_test.dart` pasa: todos los providers se resolved sin `StackOverflowError` ni `CircularReferenceError`.
- [ ] No hay singletons globales fuera de los providers de Riverpod (el `AppDatabase` vivo mientras el `ProviderScope` exista).

## Tests
- [ ] `test/di/global_providers_test.dart`

## Comandos
- [ ] `flutter analyze`
- [ ] `flutter test test/di/`

# Fase 1 — Bootstrap del proyecto y estructura base

**Objetivo:** configurar el proyecto Flutter con todas las dependencias, estructura de carpetas vacía, y el esqueleto de `main.dart`, `app.dart`, `bootstrap.dart`.
**Depende de:** —
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 1)

## Tareas
- [ ] Actualizar `pubspec.yaml` con todas las dependencias de producción y desarrollo listadas en §0.4.
- [ ] Ejecutar `flutter pub get` y verificar que no hay conflictos de versión.
- [ ] Crear la estructura de carpetas vacías según el diagrama de §0.3.
- [ ] Configurar `analysis_options.yaml`: `prefer_single_quotes: true`, `avoid_print: true` (los demas lints ya vienen por defecto en flutter.yaml).
- [ ] Crear `lib/main.dart`, `lib/app.dart`, `lib/bootstrap.dart` con el esqueleto выше.
- [ ] Crear archivo `.gitkeep` en cada carpeta vacía para preservar la estructura.
- [ ] Primer `flutter analyze` — debe pasar limpio (salvo warnings de imports no usados, que se resolverán en fases siguientes).

## Criterios de aceptación
- [ ] `flutter pub get` exitosa, sin conflicts.
- [ ] `flutter analyze` pasa con 0 errores, 0 warnings.
- [ ] La estructura de carpetas coincide con el diagrama de §0.3.

## Comandos
- [ ] `flutter pub get`
- [ ] `flutter analyze`

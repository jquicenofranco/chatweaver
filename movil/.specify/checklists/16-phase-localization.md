# Fase 16 — Localización

**Objetivo:** configurar `intl` con `.arb` files y las localizaciones generadas.
**Depende de:** Fase 9 (theme base).
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 16)

## Tareas
- [ ] Crear `lib/l10n/app_es.arb` y `lib/l10n/app_en.arb` con todas las keys usadas en la UI.
- [ ] Ejecutar generador de localizations o configurar `l10n.yaml`.
- [ ] Reemplazar todos los strings hardcodeados en pantallas por `AppLocalizations.of(context).keyName`.
- [ ] Formatear números de tokens con `NumberFormat('#,###', locale)` (ej. `1.234` en español).
- [ ] Formatear fechas relativas con `intl.DateFormat.relative()`.
- [ ] Tests de localizacion: verificar que `app_es.arb` y `app_en.arb` tienen las mismas keys.

## Criterios de aceptación
- [ ] `flutter analyze` no reporta strings sin usar de `AppLocalizations`.
- [ ] Los numbers de tokens usan el separador correcto por locale (`.` en español, `,` en inglés).
- [ ] Todos los textos visibles en la app usan `AppLocalizations`, no literales.

## Comandos
- [ ] `flutter pub get`
- [ ] `flutter analyze`

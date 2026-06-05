# Fase 17 — Accesibilidad

**Objetivo:** garantizar accesibilidad WCAG AA en toda la app.
**Depende de:** Fase 9 (theme base).
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 17)

## Tareas
- [ ] Agregar `Semantics` label a todos los botones que no tienen texto visible (iconos).
- [ ] Agregar `Semantics.liveRegion()` al `ListView` de mensajes para que el lector de pantalla anuncie cada chunk de streaming del assistant.
- [ ] Verificar ratio de contraste en `TokenMeter` (colores verde/amarillo/rojo sobre el fondo).
- [ ] Verificar que el `FocusTraversalGroup` funciona en tablet con teclado físico.
- [ ] Crear `test/ui/accessibility/smoke_test.dart` (usa `SemanticsTester`).
- [ ] Probar en dispositivo real (Android TalkBack, iOS VoiceOver) al menos una vez.

## Criterios de aceptación
- [ ] `SemanticsTester` pasa en los widgets principales (`MessageBubble`, `PromptInput`, `TokenMeter`).
- [ ] El lector de pantalla anuncia "Enviando…" cuando se manda un mensaje y "Respuesta completada" al terminar el stream.
- [ ] Todos los `InteractiveViewer` / `ListView` tienen dirección de scroll accesible.

## Tests
- [ ] `test/ui/accessibility/smoke_test.dart`

## Comandos
- [ ] `flutter analyze`
- [ ] `flutter test test/ui/accessibility/`

# Fase 10 — Navegación con go_router

**Objetivo:** configurar `go_router` con todas las rutas, redirects, y deep links.
**Depende de:** Fase 7 (providers disponibles), Fase 9 (theme disponible).
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 10)

## Tareas
- [ ] Crear `lib/ui/router/app_router.dart` con todas las rutas.
- [ ] Verificar que el redirect de splash no produce loop infinito (usar `valueOrNull` en lugar de `value` para no bloquear en loading).
- [ ] Probar que `context.go('/chat/xxx')` y `context.push('/token?modelId=yyy')` funcionan desde cualquier pantalla.
- [ ] Crear test: `test/ui/router/app_router_test.dart` (verifica que las rutas están registradas y el redirect de splash es correcto con y sin credenciales).

## Criterios de aceptación
- [ ] Navegación programa (`context.go`, `context.push`) y deep link (`/chat/abc`) funcionan.
- [ ] El redirect en `/` consulta `hasAnyCredentialProvider` sin bloquear la UI.
- [ ] No hay loop de redirect entre `/` y ninguna otra ruta.

## Tests
- [ ] `test/ui/router/app_router_test.dart`

## Comandos
- [ ] `flutter analyze`
- [ ] `flutter test test/ui/router/`

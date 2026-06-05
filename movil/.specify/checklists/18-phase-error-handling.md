# Fase 18 — Matriz de manejo de errores

**Objetivo:** verificar que cada estado vacío/error de cada pantalla está cubierto con el componente correcto.
**Depende de:** Fases 11, 12, 13, 14, 15 (pantallas implementadas).
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 18)

## Tareas
- [ ] Hacer revisión línea por línea de la matriz vs implementación real.
- [ ] Implementar `Banner` de context overflow en `ChatScreen` (no existe aún).
- [ ] Implementar botón "Reintentar" en `MessageBubble` con `status = failed`.
- [ ] Verificar que `ErrorView` con "Reintentar" se muestra en todas las pantallas que cargan datos de red o DB.
- [ ] Tests de integración: cada estado de error se puede alcanzar con la app en un estado conocido.

## Criterios de aceptación
- [ ] La matriz está completa y cada celda tiene un componente asignado.
- [ ] No hay `catch (e)` que silencie excepciones sin mostrar nada al usuario.
- [ ] Los errores de red muestran el `userMessage` de `LlmException`, nunca `DioException.message`.

## Comandos
- [ ] `flutter analyze`

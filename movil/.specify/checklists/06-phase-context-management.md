# Fase 6 — Gestión de contexto (`context/`)

**Objetivo:** implementar el Strategy Pattern para el manejo de la ventana de contexto: interfaz `ContextStrategy`, `SlidingWindowStrategy`, y `ContextWindowManager`.
**Depende de:** Fase 4 (`ILLMProvider` disponible) y Fase 5 (`calculateTokens` disponible).
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 6)

## Tareas
- [ ] Crear `lib/context/context_strategy.dart` (interfaz abstracta).
- [ ] Crear `lib/context/sliding_window_strategy.dart` (implementación default).
- [ ] Crear `lib/context/context_window_manager.dart`.
- [ ] Crear `test/context/sliding_window_strategy_test.dart`:
  - Mensaje que cabe solo: se devuelve completo.
  - Dos mensajes que juntos exceden budget: se descarta el más antiguo.
  - Budget < 100 tokens: devuelve lista vacía.
  - System prompt consume todo el budget: devuelve historial vacío.
  - Historial vacío: devuelve lista vacía (sin error).
- [ ] Crear `test/context/context_window_manager_test.dart`:
  - `trimHistory` reserva el system prompt.
  - `estimateNextSendTokens` devuelve valor positivo.
  - `usageRatio` devuelve valor entre 0.0 y 1.0+ (puede superar 1.0 si excede).
- [ ] Verificar que `SlidingWindowStrategy` no modifica la lista de entrada.

## Criterios de aceptación
- [ ] `SlidingWindowStrategy` es determinista: misma entrada produce misma salida.
- [ ] El margen de seguridad del 10% está implementado y testeado.
- [ ] `ContextWindowManager` no guarda estado mutable; es un value object con `_provider` como estrategia inyectada.
- [ ] `SlidingWindowStrategy` no tiene dependencias fuera de `dart:math`.

## Tests
- [ ] `test/context/sliding_window_strategy_test.dart`
- [ ] `test/context/context_window_manager_test.dart`

## Comandos
- [ ] `flutter analyze`
- [ ] `flutter test test/context/`

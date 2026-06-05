# Fase 19 — Performance y memoria

**Objetivo:** garantizar que la app no tiene memory leaks, rebuilds innecesarios, ni bottlenecks de rendimiento.
**Depende de:** Fases 11, 12, 13, 14, 15 (pantallas implementadas).
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 19)

## Tareas
- [ ] `ChatScreen` usa `ref.watch` selectivo: `ref.watch(chatControllerProvider(sessionId))` solo escucha `ChatState` (todo el estado), pero `messagesStreamProvider` y `sessionProvider` se watchean por separado para evitar rebuilds cruzados.
- [ ] `TokenMeter` usa `ref.watch(projectedTokensProvider)` que es un `Provider.autoDispose` que solo se recalcula cuando cambia el draft o los messages.
- [ ] `PromptInput` usa `onChanged` (no `watch`) para actualizar el draft, evitando un rebuild del input mismo.
- [ ] `ChatScreen` usa `ListView.builder` con `itemCount` y `itemBuilder` (no `ListView` con children).
- [ ] El `ListView` de `ChatScreen` es invertido (`reverse: true`) para que los mensajes nuevos aparezcan abajo.
- [ ] `SessionsPanelScreen` usa `ListView.separated` con `itemCount` y `itemBuilder`.
- [ ] `ModelSelectorScreen` usa `ListView.builder`.
- [ ] Todos los widgets que no dependen de estado variable usan `const` constructor.
- [ ] `ThemeData`, `ColorScheme`, `TextStyle` en el tema se declaran como `static const` donde es posible.
- [ ] `AppDatabase` se cierra en `onDispose` del `appDatabaseProvider`.
- [ ] Los `ScrollController` se disposen en `dispose()` de cada `StatefulWidget`.
- [ ] Los `CancelToken` de streams abortados se cancelan explicitamente en `abort()` del `ChatController`.
- [ ] No hay referencias estáticas a widgets ni contextos.
- [ ] Los `ProviderContainer` en tests se disposan al final del test.
- [ ] No hay imágenes de red en MVP. Si se añaden avatares de proveedor, usar `CachedNetworkImage`.
- [ ] Run `flutter analyze` con `--observe` para detectar memory leaks en dev.
- [ ] Profiler de Flutter DevTools: verificar que `ChatScreen` no hace más de 2 rebuilds por keystroke en el prompt input.
- [ ] Verificar con `testWidgets` que `PromptInput` no hace rebuild del widget padre al escribir.

## Criterios de aceptación
- [ ] `ChatScreen` con 100 mensajes no hace scroll janky.
- [ ] Escribir en `PromptInput` no dispara rebuild de la lista de mensajes.
- [ ] `flutter analyze` sin leaks/warnings.
- [ ] Ningún controller (ScrollController, FocusNode, TextEditingController) se deja sin dispose.

## Comandos
- [ ] `flutter analyze`

# Fase 14 — ChatScreen + ChatController + TokenMeter

**Objetivo:** implementar la pantalla de chat más compleja: streaming, `ChatController`, `ChatState`, `MessageBubble`, `PromptInput`, `TokenMeter`, y `projectedTokensProvider`.
**Depende de:** Fases 7, 8, 9, 10.
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 14)

## Tareas
- [ ] Crear `lib/ui/chat/chat_state.dart` (freezed).
- [ ] Crear `lib/ui/chat/chat_controller.dart`.
- [ ] Crear `lib/ui/chat/chat_screen.dart`.
- [ ] Crear `lib/ui/chat/providers/chat_providers.dart` (messagesStreamProvider, sessionProvider, chatControllerProvider).
- [ ] Crear `lib/ui/chat/providers/projected_tokens_provider.dart`.
- [ ] Crear `lib/ui/chat/widgets/message_bubble.dart`.
- [ ] Crear `lib/ui/chat/widgets/prompt_input.dart`.
- [ ] Crear `lib/ui/chat/widgets/streaming_indicator.dart`.
- [ ] Crear `lib/message/presentation/widgets/token_meter.dart` (reutilizable en Settings).
- [ ] Crear `lib/ui/chat/widgets/context_warning_banner.dart`.
- [ ] Tests: `test/ui/chat/chat_controller_test.dart` (con `MockSendMessage`, `MockILLMProvider`).
- [ ] Tests: `test/ui/chat/message_bubble_test.dart`.
- [ ] Tests: `test/message/presentation/widgets/token_meter_test.dart`.

## Criterios de aceptación
- [ ] Los mensajes aparecen en el ListView en orden cronológico (más antiguo arriba, más nuevo abajo).
- [ ] Al enviar, el mensaje del usuario aparece inmediatamente con `status = complete`; el del assistant con `status = streaming` y se actualiza token a token.
- [ ] El botón "Stop" aborta el stream y deja el texto parcial.
- [ ] `TokenMeter` se actualiza en tiempo real mientras se escribe el draft (sin enviar).
- [ ] `MessageBubble` de assistant con `status = streaming` muestra un caret parpadeante.
- [ ] `MessageBubble` con `status = failed` muestra badge rojo y el mensaje de error.
- [ ] No hay `maxLength` en el `PromptInput`.
- [ ] `SemanticLiveRegion` announce la respuesta completa del assistant al finalizar.

## Tests
- [ ] `test/ui/chat/chat_controller_test.dart`
- [ ] `test/ui/chat/message_bubble_test.dart`
- [ ] `test/message/presentation/widgets/token_meter_test.dart`

## Comandos
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter analyze`
- [ ] `flutter test test/ui/chat/`
- [ ] `flutter test test/message/`

# Fase 8 — Casos de uso

**Objetivo:** implementar todos los casos de uso del módulo `session/` y `message/`, incluyendo el crítico `SendMessage`.
**Depende de:** Fases 4, 5, 6, 7 (`ILLMProvider`, `ContextWindowManager`, repositorios disponibles).
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 8)

## Tareas
- [ ] Crear `lib/session/domain/usecases/create_session.dart`.
- [ ] Crear `lib/session/domain/usecases/list_sessions.dart`.
- [ ] Crear `lib/session/domain/usecases/rename_session.dart`.
- [ ] Crear `lib/session/domain/usecases/delete_session.dart`.
- [ ] Crear `lib/session/domain/exceptions/session_not_found_exception.dart`.
- [ ] Crear `lib/session/domain/usecases/send_message.dart` completo (spec §04 §10). `SendMessage` llama directamente a `MessagesRepository.listBySession()`, no a un caso de uso intermediario.
- [ ] Crear `lib/session/domain/usecases/providers.dart` con `createSessionProvider` y `sendMessageProvider`.
- [ ] Crear `lib/message/domain/usecases/append_message.dart`.
- [ ] Crear `lib/message/domain/usecases/providers.dart` con `appendMessageProvider`.
- [ ] Crear tests para cada caso de uso:
  - `test/session/domain/usecases/create_session_test.dart`
  - `test/session/domain/usecases/send_message_test.dart` (con `MockILLMProvider`, `MockSessionsRepository`, `MockMessagesRepository`).
- [ ] Verificar que `SendMessage` nunca propaga `DioException` ni `SocketException` al llamador; siempre las convierte a `LlmException`.

## Criterios de aceptación
- [ ] `SendMessage` es el único caso de uso que llama a `ILLMProvider.generateStream()`.
- [ ] `SendMessage` reserva espacio para `maxOutputTokens` en el budget de contexto.
- [ ] El mensaje del usuario actual **no** se trunca (va por encima del budget ya que se agrega después de `trimHistory`).
- [ ] Cancelar durante streaming deja el mensaje del assistant con el texto parcial recibido hasta el momento.
- [ ] El `CancelToken` se propaga hasta `Dio` para abortar la conexión HTTP.

## Tests
- [ ] `test/session/domain/usecases/create_session_test.dart`
- [ ] `test/session/domain/usecases/send_message_test.dart`

## Comandos
- [ ] `flutter analyze`
- [ ] `flutter test test/session/`

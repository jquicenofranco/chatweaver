# Fase 5 — Proveedor MiniMax

**Objetivo:** implementar el provider MiniMax completo: DTOs, `MiniMaxApiClient`, `MiniMaxAdapter`, y `MiniMaxProvider` con auto-registro.
**Depende de:** Fase 4 (`ILLMProvider`, `LLMFactory`, entidades `llm/` disponibles).
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 5)

## Tareas
- [ ] Crear `lib/llm/providers/minimax/dto/minimax_request_dto.dart`.
- [ ] Crear `lib/llm/providers/minimax/dto/minimax_response_dto.dart`.
- [ ] Ejecutar `build_runner` para generar `.freezed.dart` y `.g.dart`.
- [ ] Crear `lib/llm/providers/minimax/minimax_api_exception.dart` (excepcion especifica del API client).
- [ ] Crear `lib/llm/providers/minimax/minimax_api_client.dart` (streaming + non-streaming).
- [ ] Crear `lib/llm/providers/minimax/minimax_adapter.dart` (DTO → dominio).
- [ ] Crear `lib/llm/providers/minimax/minimax_provider.dart` (implementación ILLMProvider + `registerSelf`).
- [ ] Crear `test/llm/providers/minimax/minimax_adapter_test.dart` (verifica `toChunk` y `toDto` con datos conocidos).
- [ ] Crear `test/llm/providers/minimax/minimax_provider_test.dart` (test unitario del provider con `MockDio` y `MockMiniMaxApiClient`).
- [ ] **Test de integración SSE real:** `test/llm/providers/minimax/sse_parsing_test.dart` que pruebe el parsing de SSE con datos UTF-8 multi-byte y el sentinel `[DONE]`. Incluir test para `[DONE]` en misma linea que otro evento `data:`.

## Criterios de aceptación
- [ ] `MiniMaxProvider` implementa todos los métodos de `ILLMProvider`.
- [ ] `registerSelf` produce un builder que `LLMFactory` puede invocar correctamente.
- [ ] El test de SSE verifica que un payload con `data: [DONE]` termina el stream sin error.
- [ ] El test de SSE verifica que caracteres UTF-8 (ej. emojis, texto en español con acentos) no se cortocircuitan.
- [ ] El test de SSE verifica que líneas `: keep-alive` no generan output.

## Tests
- [ ] `test/llm/providers/minimax/minimax_adapter_test.dart`
- [ ] `test/llm/providers/minimax/minimax_provider_test.dart`
- [ ] `test/llm/providers/minimax/sse_parsing_test.dart`

## Comandos
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter analyze`
- [ ] `flutter test test/llm/`

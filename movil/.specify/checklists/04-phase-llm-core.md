# Fase 4 — Núcleo del módulo `llm/`

**Objetivo:** implementar las entidades de dominio compartidas del módulo `llm/`, la interfaz `ILLMProvider`, el `LLMFactory`, y la jerarquía de excepciones `LlmException`.
**Depende de:** Fase 1 (estructura base).
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 4)

## Tareas
- [ ] Crear `lib/llm/chat_message.dart` (ChatRole enum + ChatMessage freezed).
- [ ] Crear `lib/llm/generate_request.dart` (GenerateRequest freezed).
- [ ] Crear `lib/llm/generate_response.dart` (GenerateResponseChunk + LlmUsage freezed).
- [ ] Crear `lib/llm/illm_provider.dart` (interfaz abstracta).
- [ ] Crear `lib/llm/llm_factory.dart` (Factory + UnsupportedProviderException).
- [ ] Crear `lib/llm/llm_exception.dart` (jerarquía sealed).
- [ ] Ejecutar `build_runner` para generar `.freezed.dart`.
- [ ] Crear tests: `test/llm/llm_factory_test.dart` (verifica registro, `build`, `supports`, `supportedProviders`, lanzamiento de `UnsupportedProviderException`).
- [ ] Crear tests: `test/llm/llm_exception_test.dart` (verifica que todas las subclases tienen `userMessage` y `toString()` correcto).

## Criterios de aceptación
- [ ] `ILLMProvider` no depende de Flutter ni de Drift.
- [ ] `LLMFactory.register` es idempotente en tests (usar `LLMFactory` limpia en cada test, no singleton).
- [ ] Todas las subclases de `LlmException` son constructores `const`.
- [ ] Los tests de factory verifican que `build()` lanza `UnsupportedProviderException` con el `providerId` correcto.

## Tests
- [ ] `test/llm/llm_factory_test.dart`
- [ ] `test/llm/llm_exception_test.dart`

## Comandos
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter analyze`
- [ ] `flutter test test/llm/`

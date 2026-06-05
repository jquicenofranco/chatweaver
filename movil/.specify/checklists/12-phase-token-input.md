# Fase 12 — TokenInputScreen + ConnectionTestController

**Objetivo:** implementar la pantalla de ingreso y validación de API key con el `ConnectionTestController`.
**Depende de:** Fase 7 (providers), Fase 9 (widgets compartidos), Fase 10 (router).
**Referencia:** `plans/IMPLEMENTATION_PLAN.md` (sección Fase 12)

## Tareas
- [ ] Crear `lib/ui/home/connection_test_controller.dart`.
- [ ] Crear `lib/ui/home/token_input_screen.dart`.
- [ ] Crear `lib/ui/home/widgets/api_key_text_field.dart`.
- [ ] Crear `lib/ui/home/widgets/remember_token_switch.dart`.
- [ ] Crear `lib/ui/home/widgets/token_help_link.dart`.
- [ ] Integrar `url_launcher` para el link de ayuda.
- [ ] En `TokenInputScreen`: wrapear la llamada a `controller.test()` en try/catch y mostrar errores como `ScaffoldMessenger.showSnackBar(SnackBar(content: Text(error)))`.
- [ ] Guardar credencial en `CredentialRepository` si "Recordar" está ON.
- [ ] Tests: `test/ui/home/connection_test_controller_test.dart` con `ProviderContainer` override y `MockILLMProvider`.

## Criterios de aceptación
- [ ] El `TextField` es multilínea y monoespaciado.
- [ ] El botón está deshabilitado mientras el test corre (`isLoading = true`).
- [ ] Tras éxito, la credencial se guarda en `flutter_secure_storage` (no en SQLite).
- [ ] Si "Recordar" está OFF, el token se pasa directamente al provider sin persistir.
- [ ] El link de ayuda abre la URL del provider (para MiniMax: documentación del API token).

## Tests
- [ ] `test/ui/home/connection_test_controller_test.dart`

## Comandos
- [ ] `flutter analyze`
- [ ] `flutter test test/ui/home/`

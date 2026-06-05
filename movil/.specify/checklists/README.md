# Checklists de Implementación — ChatWeaver

Listado operativo de tareas derivado de [`plans/IMPLEMENTATION_PLAN.md`](../IMPLEMENTATION_PLAN.md). Cada fase tiene un archivo `NN-phase-slug.md` con cuatro secciones: **Tareas**, **Criterios de aceptación**, **Tests** y **Comandos**.

## Cómo usar
1. Tomar la fase N del plan.
2. Abrir el archivo `NN-phase-*.md` correspondiente.
3. Marcar `[x]` cada ítem a medida que se completa.
4. Antes de cerrar la fase, validar que todas las secciones estén en 0 pendientes.

## Índice de fases

| # | Fase | Archivo | Resumen |
|---|---|---|---|
| 1 | Bootstrap del proyecto y estructura base | [01-phase-bootstrap.md](01-phase-bootstrap.md) | Dependencias, estructura de carpetas, esqueleto de main.dart/app.dart/bootstrap.dart |
| 2 | Capa de base de datos (db/) | [02-phase-database.md](02-phase-database.md) | Tablas Drift, AppDatabase, DAOs, SecureCredentialStore, mappers |
| 3 | Entidades de dominio y repositorios | [03-phase-domain-entities.md](03-phase-domain-entities.md) | Entidades freezed, interfaces de repositorio, implementaciones data/ |
| 4 | Núcleo del módulo llm/ | [04-phase-llm-core.md](04-phase-llm-core.md) | ILLMProvider, LLMFactory, jerarquía LlmException, entidades de dominio |
| 5 | Proveedor MiniMax | [05-phase-minimax-provider.md](05-phase-minimax-provider.md) | DTOs, MiniMaxApiClient, MiniMaxAdapter, MiniMaxProvider con registerSelf |
| 6 | Gestión de contexto (context/) | [06-phase-context-management.md](06-phase-context-management.md) | ContextStrategy, SlidingWindowStrategy, ContextWindowManager |
| 7 | Inyección de dependencias (di/) | [07-phase-dependency-injection.md](07-phase-dependency-injection.md) | global_providers.dart con todos los Riverpod providers |
| 8 | Casos de uso | [08-phase-use-cases.md](08-phase-use-cases.md) | CreateSession, ListSessions, SendMessage, providers de casos de uso |
| 9 | Theming y widgets compartidos | [09-phase-theming-widgets.md](09-phase-theming-widgets.md) | AppTheme (light/dark), PrimaryButton, ErrorView, ConfirmDialog, EmptyStateView |
| 10 | Navegación con go_router | [10-phase-routing.md](10-phase-routing.md) | routerProvider con todas las rutas y redirect del splash |
| 11 | Splash + ModelSelector | [11-phase-splash-model-selector.md](11-phase-splash-model-selector.md) | SplashScreen, ModelSelectorScreen, availableModelsProvider, ModelCard |
| 12 | TokenInputScreen + ConnectionTestController | [12-phase-token-input.md](12-phase-token-input.md) | Pantalla de ingreso de API key, prueba de conexión, persistencia segura |
| 13 | SessionsPanelScreen | [13-phase-sessions-panel.md](13-phase-sessions-panel.md) | Listado, creación, renombrado, borrado de sesiones |
| 14 | ChatScreen + ChatController + TokenMeter | [14-phase-chat-screen.md](14-phase-chat-screen.md) | Streaming, ChatState, MessageBubble, PromptInput, projectedTokensProvider |
| 15 | SettingsScreen | [15-phase-settings-screen.md](15-phase-settings-screen.md) | Credenciales, modelos, tema, idioma, secciones avanzadas |
| 16 | Localización | [16-phase-localization.md](16-phase-localization.md) | app_es.arb, app_en.arb, reemplazo de strings hardcodeados |
| 17 | Accesibilidad | [17-phase-accessibility.md](17-phase-accessibility.md) | Semantics, live regions, ratios de contraste, FocusTraversalGroup |
| 18 | Matriz de manejo de errores | [18-phase-error-handling.md](18-phase-error-handling.md) | Validación de estados empty/error/loading en cada pantalla |
| 19 | Performance y memoria | [19-phase-performance.md](19-phase-performance.md) | Rebuilds selectivos, ListView.builder, const discipline, dispose correcto |
| 20 | Test final y release | [20-phase-release.md](20-phase-release.md) | Tests de integración, checklist de release, builds APK |

## Orden de ejecución
Las fases están diseñadas para ejecutarse en orden. Cada fase declara sus **Depende de:** explícitamente en su archivo. La Fase 7 (DI) y la Fase 9 (Theming) pueden solaparse; el resto es secuencial.

## Definición de Done
Una fase se considera completa cuando:
- Todas las tareas marcadas como `[x]`.
- `flutter analyze` pasa con 0 errores y 0 warnings.
- `flutter test` pasa al 100%.
- Los criterios de aceptación están cumplidos y verificados.
- Los archivos de código y test referenciados en la fase existen en el árbol.

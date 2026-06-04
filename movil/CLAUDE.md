# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

- `chatweaver/` — The Flutter application (the actual project root for `flutter` commands).
- `spec/` — Technical specifications for the app. **Read these before making non-trivial design or implementation decisions** — they are the source of truth.

All Flutter / Dart tooling must be run from inside `chatweaver/`.

## Specifications (source of truth)

Located in `spec/`. Read in this order when onboarding or before feature work:

1. `spec/01_Architecture_And_Folders.md` — Arquitectura modular, estructura de carpetas, patrones Strategy/Factory/Adapter, justificacion del prefijo `I` en `ILLMProvider`.
2. `spec/02_Local_Database_And_Context.md` — Esquemas Drift, entidades, DAOs, repositorios, y algoritmo completo de SlidingWindowStrategy con pseudocodigo.
3. `spec/03_LLM_Module_And_MiniMax.md` — Codigo completo de `ILLMProvider`, `LLMFactory`, `MiniMaxProvider`, `MiniMaxApiClient`, `MiniMaxAdapter`, DTOs, `LlmException`, `parseNetworkError`.
4. `spec/04_UI_State_And_Flow.md` — Pantallas, estado Riverpod por pantalla, `ChatController` con caso de uso `SendMessage`, widget `TokenMeter`, flujos de actualizacion de tokens en tiempo real.

The product is a **local-first** chat client for multiple LLM providers (MVP: MiniMax). No login, no backend. The app owns the conversation context and token budget.

## Common commands

Run these from the `chatweaver/` directory.

- Install dependencies: `flutter pub get`
- Run static analysis / lints: `flutter analyze`
- Format code: `dart format .`
- Run the full test suite: `flutter test`
- Run a single test file: `flutter test test/path/to/file_test.dart`
- Run a single test by name: `flutter test --plain-name "test description"`
- Launch the app (auto-detects device): `flutter run`
- Build for a specific platform: `flutter build apk`, `flutter build ios`, `flutter build web`
- Regenerate code (freezed / Drift / json_serializable): `dart run build_runner build --delete-conflicting-outputs`

## Project architecture

This is a freshly generated Flutter app — a single-module starter with no feature folders yet.

- `lib/main.dart` — Single entry point. Defines `MyApp` (root `MaterialApp` with theme) and `MyHomePage` / `_MyHomePageState` (a stateful counter widget serving as the home screen). All UI currently lives in this one file.
- `test/widget_test.dart` — Widget test for the counter increment behavior.
- `pubspec.yaml` — Declares `chatweaver` (SDK `^3.11.5`) with only `cupertino_icons` and `flutter_lints ^6.0.0` as dependencies. No state management, networking, or persistence packages are wired up — the spec calls for adding `flutter_riverpod`, `go_router`, `drift`, `dio`, `flutter_secure_storage`, `freezed`, etc.
- `analysis_options.yaml` — Inherits the recommended `package:flutter_lints/flutter.yaml` rule set.
- `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/` — Generated platform shells for all six Flutter targets; modify when adding platform-specific configuration.

There is no `lib/` subfolder structure (no `models/`, `services/`, `widgets/`, etc.) — when adding features, follow the modular structure defined in `spec/01_Architecture_And_Folders.md` (top-level modules `llm/`, `session/`, `message/`, `db/`, `context/`, `ui/`, each with optional `domain/data/presentation` subfolders). There is no `core/` folder.

## Notes for future work

- The project is not under git in this directory; initialize one before relying on history or VCS-aware tooling.
- When adding a new LLM provider (OpenAI, Ollama, etc.), the only files that should change are inside `lib/llm/providers/<provider_id>/` and the registry in `lib/di/global_providers.dart` (see `spec/03_LLM_Module_And_MiniMax.md`). UI and storage layers must not be touched. The factory (`LLMFactory`) is the single extension point.
- API keys must never be logged, persisted to SQLite, or written to `shared_preferences`. They live in `flutter_secure_storage` and only in-memory of the active `ILLMProvider` instance.
- The architecture is **modular top-level** (`llm/`, `session/`, `message/`, `db/`, `context/`, `ui/`). There is no `core/` folder. Cross-cutting concerns live in `di/` and `context/`.

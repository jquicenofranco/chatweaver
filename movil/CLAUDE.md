# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

- `chatweaver/` — The Flutter application (the actual project root for `flutter` commands).
- `spec/` — Technical specifications for the app. **Read these before making non-trivial design or implementation decisions** — they are the source of truth.

All Flutter / Dart tooling must be run from inside `chatweaver/`.

## Specifications (source of truth)

Located in `spec/`. Read in this order when onboarding or before feature work:

1. `spec/01_Architecture_And_Stack.md` — Stack, Clean Architecture layers, DI, folder layout.
2. `spec/02_Data_Models_And_Storage.md` — Drift schema, DAOs, entities, repositories.
3. `spec/03_Services_And_API.md` — LLM provider abstraction, token handling, context window, streaming.
4. `spec/04_UI_UX_Flow.md` — Screens, Riverpod state per screen, navigation, UX flows.

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

There is no `lib/` subfolder structure (no `models/`, `services/`, `widgets/`, etc.) — when adding features, follow the structure defined in `spec/01_Architecture_And_Stack.md` (feature folders with `data/`, `domain/`, `presentation/` and a shared `core/`).

## Notes for future work

- The project is not under git in this directory; initialize one before relying on history or VCS-aware tooling.
- When adding a new LLM provider (OpenAI, Ollama, etc.), the only files that should change are inside `lib/core/services/llm/providers/` and the registry in `llmProviderFactoryProvider` (see `spec/03_Services_And_API.md` §12). UI and storage layers must not be touched.
- API keys must never be logged, persisted to SQLite, or written to `shared_preferences`. They live in `flutter_secure_storage` and only in-memory of the active `LlmProvider` instance.

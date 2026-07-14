# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

- `chatweaver/` — The Flutter application. **All Flutter/Dart tooling must be run from inside this directory.**
- `.specify/spec/` — Normative technical specifications. **These are the source of truth**; read the relevant one before any non-trivial design or implementation decision.
- `.specify/plans/IMPLEMENTATION_PLAN.md` + `.specify/checklists/` — The 20-phase implementation plan and its per-phase checklists (tasks, acceptance criteria, tests, commands).

Code, comments, and specs are written in Spanish. Match that when editing.

## Specifications (source of truth)

Read in this order when onboarding or before feature work:

1. `.specify/spec/01_Architecture_And_Folders.md` — Modular architecture, folder structure, the Strategy/Factory/Adapter patterns, strict inter-module dependency rules (§4.2), why `ILLMProvider` keeps the `I` prefix.
2. `.specify/spec/02_Local_Database_And_Context.md` — Drift schemas, entities, DAOs, repositories, and the full `SlidingWindowStrategy` algorithm.
3. `.specify/spec/03_LLM_Module_And_MiniMax.md` — `ILLMProvider`, `LLMFactory`, `MiniMaxProvider`, `MiniMaxApiClient`, `MiniMaxAdapter`, DTOs, `LlmException`, `parseNetworkError`.
4. `.specify/spec/04_UI_State_And_Flow.md` — Screens, per-screen Riverpod state, `ChatController`, `TokenMeter`. **v2.0.0 changed the onboarding flow** — provider selection now comes first.
5. `.specify/spec/05_Thinking_Models_And_Reasoning_Display.md` — Reasoning/thinking-token support (DB v3, `reasoningDelta` chunks, `ReasoningPanel`).

The product is a **local-first** chat client for multiple LLM providers (MVP: MiniMax). No login, no backend, no server of ours. The app owns the conversation context and the token budget.

## Common commands

Run from `chatweaver/`.

- Install dependencies: `flutter pub get`
- Static analysis: `flutter analyze`
- Format: `dart format .`
- Full test suite: `flutter test`
- Single test file: `flutter test test/path/to/file_test.dart`
- Single test by name: `flutter test --plain-name "test description"`
- Run the app: `flutter run`
- **Regenerate code (freezed / Drift / json_serializable): `dart run build_runner build --delete-conflicting-outputs`** — required after touching any `@freezed`, `@DriftDatabase`, table, or DTO.
- Regenerate localizations: `flutter gen-l10n` (also runs automatically on build via `generate: true`).

Generated files (`*.g.dart`, `*.freezed.dart`, `lib/l10n/generated/`) **are committed** to the repo and excluded from the analyzer. Regenerate and commit them alongside the source change.

## Architecture

Modular **top-level** layout — there is no `core/` folder. Cross-cutting concerns live in `di/` and `context/`. Each module optionally has `domain/` / `data/` / `presentation/` subfolders with Clean Architecture applied internally (`presentation → domain ← data`).

| Module | Responsibility |
|---|---|
| `lib/llm/` | `ILLMProvider` contract, `LLMFactory` registry, `LlmException`, and per-provider code under `providers/<id>/` |
| `lib/session/` | `ChatSession`, `ModelDefinition`, repositories, and the use cases — including `SendMessage`, the core orchestrator |
| `lib/message/` | `Message`, `TokenUsage`, repositories, and the message-rendering widgets (`MessageBubble`, `ReasoningPanel`, `TokenMeter`) |
| `lib/db/` | Drift `AppDatabase` (4 tables, 4 DAOs), mappers, `SecureCredentialStore`, `CredentialRepository` |
| `lib/context/` | `ContextStrategy` (Strategy pattern) + `ContextWindowManager`, which owns the token-budget formula |
| `lib/ui/` | Screens, shared widgets, and the go_router config |
| `lib/di/global_providers.dart` | Every cross-cutting Riverpod provider |

### The three patterns that hold it together

- **Strategy** — `ILLMProvider` is the swappable interface. `SendMessage` only ever sees this abstraction, never a concrete provider.
- **Factory** — `LLMFactory` holds a map of builders. Providers register themselves **explicitly** via `MiniMaxProvider.registerSelf(factory)` from `global_providers.dart`. Auto-registration by import side-effect is deliberately avoided (Dart does not guarantee import order).
- **Adapter** — `MiniMaxAdapter` translates provider DTOs to/from domain types, so no provider-specific type ever reaches the UI or storage.

`availableProvidersProvider` derives the provider catalog at runtime from `LLMFactory.supportedProviders`, so registering a provider is what makes it appear in the UI.

### Adding a new LLM provider

The only things that change are `lib/llm/providers/<provider_id>/` (new directory) and one `registerSelf` line in `lib/di/global_providers.dart`. **UI and storage layers must not be touched.** The factory is the single extension point.

### Dependency rules (strict — spec 01 §4.2)

- Any module's `domain/` must **not** import Flutter, Drift, Dio, or concrete implementations — only `dart:*` and neutral packages (`equatable`, `freezed_annotation`).
- Drift row types never cross into `domain/` or `presentation/`; the mappers in `lib/db/mappers/` are the boundary.
- `session/` may depend on `message/` to orchestrate; `message/` knows nothing of `session/`.

### Credentials

API keys live **only** in `flutter_secure_storage` and in the memory of the active `ILLMProvider`. SQLite stores a `CredentialHandle` (id, providerId, metadata) — never the secret itself. `SecureCredentialStore` is the single read/write point for the key. The non-secret "show reasoning" toggle is the one thing that lives in `shared_preferences`.

### Database

Drift, currently `schemaVersion = 3` (`lib/db/app_database.dart`). Tables: `model_configs`, `sessions`, `messages`, `credential_handles`. `PRAGMA foreign_keys = ON` is set in `beforeOpen`, so migrations must order their writes to respect FKs.

Each schema bump adds an idempotent migration method (`migrateV1ToV2`, `migrateV2ToV3`) **plus a migration test** in `test/db/`. Follow that pattern: additive `ALTER TABLE ADD COLUMN` where possible, re-run the idempotent `_seedModelConfigs()` to backfill seeded rows, and wrap destructive steps in a transaction.

### Message flow

`ChatScreen` → `ChatController` → `SendMessage` use case → `ContextWindowManager.trimHistory()` → `ILLMProvider.generateStream()` → chunks persisted incrementally to Drift → UI re-renders from `messagesStreamProvider` (Drift is the single source of truth for message content, not controller state).

`SendMessage` keeps **two parallel buffers** — content and reasoning — and writes each to the DB per chunk, so partial output survives cancellation, errors, and truncated streams. `enableReasoning` is resolved per-message from `ModelDefinition.supportsReasoning`; models without it silently degrade.

### Navigation

`/` redirects to `/providers`. Onboarding is `/providers` → `/models?providerId=` → `/token?providerId=` → `/sessions?providerId=&modelId=` → `/chat/:sessionId`. Provider selection comes first (spec 04 v2.0.0) so the user can switch providers in one tap even with credentials already saved.

## Gotchas

- **`SendMessage` is built lazily inside `ChatController._resolveSendMessage()`, not in `global_providers.dart`.** Constructing it synchronously in DI throws `StateError` on a freshly created session, because `activeLlmProviderProvider(sessionId)` is still loading. Don't "clean this up" by hoisting it into the DI file.
- **The l10n template is `app_es.arb`, not the English one.** Add new keys there first; `app_en.arb` follows.
- The analyzer runs at language version 3.9 even though the SDK is newer, which produces a few non-obvious failures:
  - **dot-shorthands** (`.fromSeed`, `.center`) are not available — write the full type name.
  - `@JsonKey(name: 'x')` on a freezed factory parameter trips `invalid_annotation_target`; DTO files need `// ignore_for_file: invalid_annotation_target` in the header.
  - Use `(_, _)` for Dart 3 wildcards, not `(_, __)`.
- **mocktail cannot mock enums** (no `extends Fake implements MessageStatus`). Register real enum values instead of using `any()` in matchers.
- Dio's `response.data` is a `ResponseBody`; the byte stream is `response.data?.stream`, and `Stream<Uint8List>.transform(const Utf8Decoder())` needs a `.cast<List<int>>()` first.

## Lints

`analysis_options.yaml` turns on `strict-casts`, `strict-inference`, and `strict-raw-types`, plus `require_trailing_commas`, `sort_constructors_first`, `avoid_print`, and `unawaited_futures`. `flutter analyze` must be clean before a change is considered done.

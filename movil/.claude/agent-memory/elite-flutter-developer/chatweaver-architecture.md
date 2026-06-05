---
name: chatweaver-architecture
description: Capas modulares top-level de ChatWeaver (lib/llm, lib/session, lib/message, lib/db, lib/context, lib/ui, lib/di). No hay lib/core. Strategy + Factory + Adapter.
metadata:
  type: project
---

ChatWeaver es un cliente Flutter **local-first multi-provider LLM** (MVP: MiniMax).

**Layout modular top-level (sin `core/`)**:
- `lib/llm/` — Interfaz `ILLMProvider` (con prefijo `I` deliberado) + factory con registro + provider concreto MiniMax
- `lib/session/` — ChatSession, ModelDefinition, repos abstractos + impls, use cases (incluye `SendMessage`)
- `lib/message/` — Message, TokenUsage, repos abstractos + impls, widgets presentation
- `lib/db/` — Drift AppDatabase (schemaVersion=1, 4 tablas), SecureCredentialStore, CredentialRepository
- `lib/context/` — Strategy Pattern para truncado de contexto (SlidingWindowStrategy default)
- `lib/ui/` — Pantallas, widgets compartidos, router
- `lib/di/global_providers.dart` — Riverpod providers transversales

**Patrones de diseño**:
- **Strategy**: `ILLMProvider` es la interfaz intercambiable. `MiniMaxProvider` la implementa.
- **Factory**: `LLMFactory` mantiene un mapa de builders registrados explicitamente via `MiniMaxProvider.registerSelf(factory)` (NO side-effect de import).
- **Adapter**: `MiniMaxAdapter` traduce DTOs nativos <-> `ChatMessage`/`GenerateResponseChunk` para que la UI nunca vea tipos de provider.
- **CQRS**: use cases en `domain/usecases/`.

**Why**: Anadir un nuevo provider debe ser solo `lib/llm/providers/<id>/` + una linea en `global_providers.dart`. La UI y el storage no se tocan.

**How to apply**: Cuando se trabaja en ChatWeaver, mantener las reglas de dependencia estricta (spec 01 §4.2). Los DTOs de Drift nunca cruzan a `domain/` o `presentation/`. El API key nunca aparece en logs, SQLite, ni shared_preferences — solo en `flutter_secure_storage` y en memoria del `ILLMProvider` activo.

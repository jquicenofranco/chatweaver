/// Definicion de un proveedor LLM soportado por la app.
///
/// Catalogo derivado en runtime desde [LLMFactory.supportedProviders].
/// Cada provider se registra explicitamente via
/// `XxxProvider.registerSelf(factory)` y queda disponible en
/// [LLMFactory.supportedProviders] como un `String`.
///
/// Este value object es la representacion UI-friendly de un provider:
/// la pantalla de seleccion de proveedor lo consume (ver
/// `lib/ui/home/provider_selector_screen.dart`).
///
/// `id` se usa como clave estable (mismo string que se persiste en
/// `sessions.provider_id` y `credential_handles.provider_id`).
/// `name` es la etiqueta visible en la UI (i18n via [l10n]).
/// `description` es un subtitulo opcional (ej. "MiniMax AI").
class ProviderDefinition {
  const ProviderDefinition({
    required this.id,
    required this.name,
    this.description,
  });

  /// Identificador estable del provider. Matchea el string usado
  /// en [LLMFactory.register] (ej. `'MiniMax'`).
  final String id;

  /// Nombre visible en la UI. **No** traducido a i18n: la app solo
  /// soporta providers pre-registrados cuyo nombre es estable (ej.
  /// `'MiniMax'`). La traduccion vendria del lado del provider
  /// description, no del nombre.
  final String name;

  /// Descripcion corta (1 linea) para el subtitulo del card.
  /// Opcional. En MVP se resuelve desde metadata local; si se
  /// quisiera por provider en un futuro, esto es donde anadir el
  /// `String?` localization key.
  final String? description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderDefinition &&
          other.id == id &&
          other.name == name &&
          other.description == description;

  @override
  int get hashCode => Object.hash(id, name, description);

  @override
  String toString() =>
      'ProviderDefinition(id: $id, name: $name, description: $description)';
}

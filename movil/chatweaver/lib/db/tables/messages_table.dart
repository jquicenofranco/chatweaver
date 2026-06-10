import 'package:drift/drift.dart';

import 'sessions_table.dart';

/// Tabla `messages`.
///
/// **Spec 05 (T-09)**: columnas `reasoning TEXT` y
/// `thinking_tokens INTEGER`, ambas **nullable** para que la
/// migración v2 → v3 sea aditiva y no rompa mensajes pre-existentes
/// (C-TECH-04). Mensajes de modelos no-thinking quedan con
/// `reasoning = null`; la UI los trata como tales y no renderiza
/// el [ReasoningPanel].
@DataClassName('MessageRow')
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text()();
  TextColumn get content => text()();

  /// Trace de razonamiento del modelo (separado de `content`).
  /// NUNCA se mezcla con la respuesta final (C-BIZ-01).
  TextColumn get reasoning => text().nullable()();

  IntColumn get inputTokens => integer().nullable()();
  IntColumn get outputTokens => integer().nullable()();

  /// Thinking tokens autoritativos del provider. Distinto de
  /// `outputTokens` (C-TECH-06). Null para mensajes de modelos
  /// no-thinking o sin reporte del provider.
  IntColumn get thinkingTokens => integer().nullable()();

  TextColumn get status => text()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

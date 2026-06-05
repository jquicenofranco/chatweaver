---
name: chatweaver-dart-analyzer-quirks
description: Quirks de dart analyze con freezed+json_serializable y Drift en este proyecto (Dart 3.12 / analyzer 3.9).
metadata:
  type: project
---

El proyecto corre con Flutter 3.44.1 / Dart 3.12, pero el analyzer tiene language version 3.9. Esto causa:

1. **dot-shorthands** (`.fromSeed`, `.center`) NO estan habilitados. El starter `main.dart` original usaba esto; reventaba con `This requires the 'dot-shorthands' language feature to be enabled`.
2. **`@JsonKey(name: 'x')` en parametros de factory freezed** dispara `invalid_annotation_target`. Hay que usar `// ignore_for_file: invalid_annotation_target` en el header del archivo del DTO.
3. **Dart 3 wildcards**: `(_, __)` dispara `unnecessary_underscores` (info). Usar `(_, _)` en su lugar.
4. **Enums no se pueden `implements` con mocktail** (no se puede hacer `_FakeMessageStatus extends Fake implements MessageStatus`). Para matchers de enums, registrar valores reales (`m.MessageStatus.streaming`) en lugar de `any()`.
5. **`Stream<Uint8List>.transform<String>(const Utf8Decoder())`** requiere `.cast<List<int>>()` antes porque `Utf8Decoder` espera `StreamTransformer<List<int>, String>`.
6. **Dio `response.data` es `ResponseBody`** en versiones nuevas. Para obtener el byte stream: `response.data?.stream` (devuelve `Stream<Uint8List>`).

**Why**: Conocer estos quirks evita perder tiempo en bucles de fix-run-fix.

**How to apply**: Si el analyzer se queja de algo "raro" en este proyecto, revisar primero contra esta lista. La mayoria de issues de `flutter analyze` se resuelven con uno de estos patrones.

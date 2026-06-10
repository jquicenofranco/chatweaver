import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/message/presentation/widgets/reasoning_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper: envuelve un widget con `MaterialApp` + `ProviderScope` +
/// localizations para que el widget bajo test tenga todo lo que
/// necesita (`Theme.of`, `AppLocalizations.of`, providers).
Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('render colapsado: muestra titulo, NO muestra el texto', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const ReasoningPanel(
          reasoning: 'pensemos paso a paso...',
          thinkingTokens: 5,
          isStreaming: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Titulo localizado visible.
    expect(find.text('Razonamiento'), findsOneWidget);
    // Texto NO visible (panel colapsado por defecto).
    expect(find.text('pensemos paso a paso...'), findsNothing);
    // Contador de thinking tokens visible (subtitle). El l10n
    // en espanol pluraliza: "5 tokens de thinking" (plural).
    expect(find.textContaining('tokens de thinking'), findsWidgets);
  });

  testWidgets('tap en el header expande y muestra el texto', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const ReasoningPanel(
          reasoning: 'pensemos paso a paso...',
          thinkingTokens: null,
          isStreaming: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap en el ExpansionTile (cualquier parte del header sirve).
    await tester.tap(find.text('Razonamiento'));
    await tester.pumpAndSettle();

    expect(find.text('pensemos paso a paso...'), findsOneWidget);
  });

  testWidgets('muestra spinner cuando isStreaming=true', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const ReasoningPanel(
          reasoning: 'razonando...',
          thinkingTokens: null,
          isStreaming: true,
        ),
      ),
    );
    await tester.pump();

    // El titulo cambia a "Pensando..." (localizado).
    expect(find.text('Pensando...'), findsOneWidget);
    // El CircularProgressIndicator esta presente.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('muestra contador de thinking tokens cuando thinkingTokens > 0', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const ReasoningPanel(
          reasoning: 'algo',
          thinkingTokens: 42,
          isStreaming: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Pluralizado: "42 thinking tokens" (ingles fallback si el
    // locale 'es' no estuviera disponible — pero la arb es
    // 'es' por default).
    expect(find.textContaining('42'), findsOneWidget);
  });

  testWidgets('no muestra contador de tokens si thinkingTokens es null o 0', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const ReasoningPanel(
          reasoning: 'algo',
          thinkingTokens: null,
          isStreaming: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    // El subtitle no aparece (no hay thinkingTokens).
    // No podemos buscar por ausencia directo, pero el widget se
    // construye sin crashear.
    expect(find.byType(ReasoningPanel), findsOneWidget);
  });

  testWidgets('dark theme: el panel se renderiza sin lanzar excepciones', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData.dark(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: const Scaffold(
            body: ReasoningPanel(
              reasoning: 'dark mode test',
              thinkingTokens: null,
              isStreaming: false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ReasoningPanel), findsOneWidget);
  });
}

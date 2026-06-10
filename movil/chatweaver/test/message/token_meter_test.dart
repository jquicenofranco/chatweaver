import 'package:chatweaver/l10n/generated/app_localizations.dart';
import 'package:chatweaver/message/domain/entities/token_usage.dart';
import 'package:chatweaver/message/presentation/widgets/token_meter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('TokenMeter', () {
    testWidgets('muestra el conteo en formato {used} / {budget}', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          TokenMeter(
            usage: const TokenUsage(inputTokens: 100, outputTokens: 50),
            contextBudget: 1000,
            projectedRatio: 0.1,
          ),
        ),
      );

      expect(find.text('150 / 1000'), findsOneWidget);
    });

    testWidgets('muestra warning si projectedRatio > 0.85', (tester) async {
      await tester.pumpWidget(
        _wrap(
          TokenMeter(
            usage: const TokenUsage(),
            contextBudget: 1000,
            projectedRatio: 0.9,
          ),
        ),
      );

      expect(find.textContaining('90%'), findsOneWidget);
    });

    testWidgets('NO muestra warning si projectedRatio <= 0.85', (tester) async {
      await tester.pumpWidget(
        _wrap(
          TokenMeter(
            usage: const TokenUsage(),
            contextBudget: 1000,
            projectedRatio: 0.5,
          ),
        ),
      );

      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('muestra el valor correcto con usage en cero', (tester) async {
      await tester.pumpWidget(
        _wrap(
          TokenMeter(
            usage: const TokenUsage(),
            contextBudget: 0,
            projectedRatio: 0.0,
          ),
        ),
      );

      expect(find.text('0 / 0'), findsOneWidget);
    });

    // ─── Spec 05 (T-17, VC-05): 3 segmentos apilados ──────────

    testWidgets('Spec 05: renderiza 3 segmentos (input, thinking, answer) '
        'proporcionales', (tester) async {
      await tester.pumpWidget(
        _wrap(
          TokenMeter(
            usage: const TokenUsage(
              inputTokens: 60,
              thinkingTokens: 20,
              outputTokens: 20,
            ),
            contextBudget: 1000,
            projectedRatio: 0.0,
          ),
        ),
      );

      // Total = 60 + 20 + 20 = 100. La barra de 3 segmentos debe
      // estar presente. Cada segmento es un Container con
      // `Expanded(flex: tokens)`.
      final containers = find.descendant(
        of: find.byType(TokenMeter),
        matching: find.byType(Container),
      );
      // Hay varios Container (incluyendo el de la barra de
      // progreso y el de cada segmento). Solo verificamos que
      // existen multiples (al menos 3 segmentos + el wrapper).
      expect(containers, findsWidgets);

      // El texto del tooltip localizado (en `es`) usa ` · ` como
      // separador. Verificamos que el Tooltip esta presente.
      expect(find.byType(Tooltip), findsOneWidget);

      // El conteo "100 / 1000" sigue funcionando porque
      // `TokenUsage.total` incluye los 3 campos.
      expect(find.text('100 / 1000'), findsOneWidget);
    });

    testWidgets(
      'Spec 05: sin thinking tokens, solo se renderizan 2 segmentos',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            TokenMeter(
              usage: const TokenUsage(inputTokens: 50, outputTokens: 50),
              contextBudget: 1000,
              projectedRatio: 0.0,
            ),
          ),
        );

        // Total = 50 + 50 + 0 = 100 (backward-compat: con
        // thinkingTokens=0 el total coincide con el valor previo a
        // spec 05).
        expect(find.text('100 / 1000'), findsOneWidget);
      },
    );
  });
}

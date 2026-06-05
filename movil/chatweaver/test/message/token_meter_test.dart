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
    testWidgets('muestra el conteo en formato {used} / {budget}', (tester) async {
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
  });
}

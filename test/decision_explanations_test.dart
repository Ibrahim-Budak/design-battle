import 'package:design_battle/features/results/decision_explanations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('her sorunun her seçeneği için genel gerekçe vardır', () {
    expect(decisionRationales, hasLength(10));
    for (final options in decisionRationales) {
      expect(options, hasLength(3));
      for (final reason in options) {
        expect(reason.trim().length, greaterThan(70));
      }
    }
  });

  testWidgets(
    'farklı seçimde sonuç belgesinin referansına uygun açıklama görünür',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DecisionExplanation(
                questionIndex: 3,
                classChoice: 'C',
                referenceChoice: 'B',
              ),
            ),
          ),
        ),
      );
      expect(
        find.text('Referans neden B · İki sütunlu ızgara?'),
        findsOneWidget,
      );
      expect(find.text(decisionRationales[3][1]), findsOneWidget);
      expect(find.text(decisionRationales[3][2]), findsNothing);
    },
  );

  testWidgets('eşleşen seçimde açıklama görünmez', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DecisionExplanation(
            questionIndex: 0,
            classChoice: 'A',
            referenceChoice: 'A',
          ),
        ),
      ),
    );
    expect(find.textContaining('Referans neden'), findsNothing);
    expect(find.text(decisionRationales[0][0]), findsNothing);
  });

  testWidgets('geçersiz seçenek ve soru numarası açıklama göstermez', (
    tester,
  ) async {
    for (final item in [
      const DecisionExplanation(
        questionIndex: -1,
        classChoice: 'A',
        referenceChoice: 'B',
      ),
      const DecisionExplanation(
        questionIndex: 0,
        classChoice: 'X',
        referenceChoice: 'B',
      ),
      const DecisionExplanation(
        questionIndex: 0,
        classChoice: 'A',
        referenceChoice: 'X',
      ),
      const DecisionExplanation(
        questionIndex: 10,
        classChoice: 'A',
        referenceChoice: 'B',
      ),
    ]) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: item)));
      expect(find.textContaining('Referans neden'), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('açıklama dar mobil ekranda taşmaz', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: DecisionExplanation(
                questionIndex: 4,
                classChoice: 'A',
                referenceChoice: 'B',
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.textContaining('Referans neden B'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

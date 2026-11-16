import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_battle/features/preview/domain/design_config.dart';
import 'package:design_battle/features/preview/food_preview.dart';

Widget phone(DesignConfig design, {Brightness brightness = Brightness.light}) =>
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(350, 700),
          platformBrightness: brightness,
        ),
        child: Scaffold(
          body: Center(child: PhonePreview(config: design)),
        ),
      ),
    );

void main() {
  test('Demo modeli 10 kararı saklar, JSON ile döner', () {
    final reference = DesignConfig.demo();
    expect(
      [for (var i = 0; i < 10; i++) reference.selectedOption(i)],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    );
    expect(
      DesignConfig.fromJson(reference.toJson()).toJson(),
      reference.toJson(),
    );
    expect(
      () => DesignConfig.fromJson({
        ...reference.toJson(),
        'themeMode': 'invalid',
      }),
      throwsFormatException,
    );
    for (var i = 0; i < 10; i++) {
      for (var j = 0; j < 3; j++) {
        final changed = reference.choose(i, j);
        expect(changed.selectedOption(i), j);
        expect(reference.toJson(), DesignConfig.demo().toJson());
        for (var k = 0; k < 10; k++) {
          if (k != i) expect(changed[k], reference[k]);
        }
      }
    }
  });
  testWidgets('30 seçenek dar telefon örneğinde çizilir', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (var q = 0; q < 10; q++) {
      for (var opt = 0; opt < 3; opt++) {
        await tester.pumpWidget(phone(DesignConfig.demo().choose(q, opt)));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Soru ${q + 1} seçenek $opt',
        );
      }
    }
  });
  testWidgets('Üç renk ve tema uygulanır, sistem modu cihazı izler', (
    tester,
  ) async {
    final primaries = <Color>{};
    for (var i = 0; i < 3; i++) {
      await tester.pumpWidget(phone(DesignConfig.demo().choose(0, i)));
      await tester.pumpAndSettle();
      primaries.add(
        Theme.of(tester.element(find.byType(FoodSample))).colorScheme.primary,
      );
    }
    expect(primaries.length, 3);
    for (var i = 0; i < 3; i++) {
      await tester.pumpWidget(
        phone(DesignConfig.demo().choose(1, i), brightness: Brightness.dark),
      );
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(FoodSample))).brightness,
        i == 0 ? Brightness.light : Brightness.dark,
      );
    }
  });
  testWidgets('Liste, ızgara, vitrin ve kart bilgileri gerçekten değişir', (
    tester,
  ) async {
    for (var i = 0; i < 3; i++) {
      await tester.pumpWidget(
        phone(DesignConfig.demo().choose(3, i).choose(4, i)),
      );
      await tester.pumpAndSettle();
      final product = find.byType(ProductList);
      expect(
        find.descendant(of: product, matching: find.byType(GridView)),
        i == 1 ? findsOneWidget : findsNothing,
      );
      expect(
        find.descendant(of: product, matching: find.byType(ListView)),
        i == 1 ? findsNothing : findsOneWidget,
      );
      expect(find.textContaining('4.8'), i == 1 ? findsWidgets : findsNothing);
      expect(find.text('İndirimli'), i == 2 ? findsWidgets : findsNothing);
    }
  });
  testWidgets('Üç navigasyonla sepete gidilir ve eklenen ürün çıkarılır', (
    tester,
  ) async {
    for (var i = 0; i < 3; i++) {
      await tester.pumpWidget(phone(DesignConfig.demo().choose(6, i)));
      await tester.pumpAndSettle();
      final addButton = find
          .descendant(
            of: find.byType(ProductCard).first,
            matching: find.text('Sepete ekle'),
          )
          .first;
      await tester.ensureVisible(addButton);
      await tester.pumpAndSettle();
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      if (i == 1) {
        await tester.tap(find.byTooltip('Menüyü aç'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Sepet').last);
      await tester.pumpAndSettle();
      expect(find.text('Sepetim'), findsOneWidget);
      expect(find.text('Toplam: 220 TL'), findsOneWidget);
      await tester.tap(find.byTooltip('Ürünü çıkar'));
      await tester.pumpAndSettle();
      expect(find.text('Sepetinde henüz ürün yok.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }
  });
  testWidgets('Üç detay türü açılır ve sepete ekler', (tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.pumpWidget(phone(DesignConfig.demo().choose(9, i)));
      await tester.pumpAndSettle();
      await tester.tap(
        find
            .descendant(
              of: find.byType(ProductCard).first,
              matching: find.byType(InkWell),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(find.byType(FoodDetail), findsOneWidget);
      expect(find.text('Ürün detayı'), i == 2 ? findsNothing : findsOneWidget);
      expect(find.text('İçindekiler'), i == 1 ? findsOneWidget : findsNothing);
      await tester.ensureVisible(
        find.descendant(
          of: find.byType(FoodDetail),
          matching: find.text('Sepete ekle'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(FoodDetail),
          matching: find.text('Sepete ekle'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ürün sepete eklendi'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }
  });
  testWidgets('Kart düzeni, içeriği ve buton biçimlerinin 27 bileşimi taşmaz', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (var layout = 0; layout < 3; layout++) {
      for (var card = 0; card < 3; card++) {
        for (var button = 0; button < 3; button++) {
          final config = DesignConfig.demo()
              .choose(3, layout)
              .choose(4, card)
              .choose(5, button);
          await tester.pumpWidget(phone(config));
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$layout / $card / $button',
          );
          final products = find.byType(ProductCard);
          expect(products, findsWidgets);
          if (button == 0) {
            expect(
              find.descendant(
                of: products.first,
                matching: find.byType(FilledButton),
              ),
              findsOneWidget,
            );
          }
          if (button == 1) {
            expect(
              find.descendant(
                of: products.first,
                matching: find.byType(OutlinedButton),
              ),
              findsOneWidget,
            );
          }
          if (button == 2) {
            expect(
              find.descendant(
                of: products.first,
                matching: find.byTooltip('Sepete ekle'),
              ),
              findsOneWidget,
            );
          }
        }
      }
    }
  });
  testWidgets('Başlık, ikon ve kampanya varyasyonları farklıdır', (
    tester,
  ) async {
    for (var i = 0; i < 3; i++) {
      await tester.pumpWidget(
        phone(DesignConfig.demo().choose(2, i).choose(7, i).choose(8, i)),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Atatürk Mah. No: 12'),
        i == 1 ? findsOneWidget : findsNothing,
      );
      expect(
        find.text('Merhaba, hoş geldin!'),
        i == 2 ? findsOneWidget : findsNothing,
      );
      expect(
        find.byIcon(Icons.home_outlined),
        i == 1 ? findsOneWidget : findsNothing,
      );
      expect(find.byIcon(Icons.home), i == 1 ? findsNothing : findsOneWidget);
      expect(find.text('FIRSATLAR'), i == 2 ? findsOneWidget : findsNothing);
      expect(
        find.text('Lezzet molası'),
        i == 1 ? findsOneWidget : findsNothing,
      );
    }
  });
  testWidgets('Kategori filtresi örnek ürünleri filtreler', (tester) async {
    await tester.pumpWidget(phone(DesignConfig.demo()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kategoriler'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Burger'));
    await tester.pumpAndSettle();
    expect(find.text('Cheeseburger'), findsOneWidget);
    expect(find.text('Margherita Pizza'), findsNothing);
  });
}

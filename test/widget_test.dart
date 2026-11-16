import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_battle/app/app.dart';
import 'package:design_battle/features/preview/food_preview.dart';
import 'package:design_battle/features/preview/domain/design_config.dart';

void main() {
  testWidgets('Ana sayfa yönetici ve önizleme rotalarına gider', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DesignBattleApp());
    expect(find.text('Bir sınıf.\nOn karar.\nTek tasarım.'), findsOneWidget);
    await tester.tap(find.text('Yönetici alanı'));
    await tester.pumpAndSettle();
    expect(find.text('Yerel tasarım stüdyosu'), findsOneWidget);
    expect(find.byType(PhonePreview), findsOneWidget);
    await tester.ensureVisible(find.text('Katılımcı ekranı →'));
    await tester.tap(find.text('Katılımcı ekranı →'));
    await tester.pumpAndSettle();
    expect(find.text('Katılım henüz hazır değil'), findsOneWidget);
  });
  testWidgets('Mobil görünüm taşıp hata vermez', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DesignBattleApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Yönetici alanı'), findsOneWidget);
  });
  test('Örnek ürün kümesi şartnamedeki altı ürünü içerir', () {
    expect(sampleFoods.length, 6);
    expect(sampleFoods.first.price, 220);
    expect(sampleFoods.last.name, 'Sebzeli Makarna');
  });
  testWidgets('Katılım bağlantısı kodu okur, doğrulanmış gibi göstermez', (
    tester,
  ) async {
    await tester.pumpWidget(
      const DesignBattleApp(initialRoute: '/join?event=DENEME123'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bağlantıdaki etkinlik kodu: DENEME123'), findsOneWidget);
    expect(find.text('Katılım henüz hazır değil'), findsOneWidget);
  });
  testWidgets('Dar ekranda dört rota hata üretmeden açılır', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final route in ['/admin', '/join', '/preview', '/results', '/yok']) {
      await tester.pumpWidget(
        DesignBattleApp(key: ValueKey(route), initialRoute: route),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
    }
  });
  testWidgets('Yönetici yerel seçenekleri değiştirince önizleme yenilenir', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DesignBattleApp(initialRoute: '/admin'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<PhonePreview>(find.byType(PhonePreview))
          .config!
          .primaryColorId,
      'orange',
    );
    await tester.tap(find.text('B · Yeşil'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<PhonePreview>(find.byType(PhonePreview))
          .config!
          .primaryColorId,
      'green',
    );
    expect(
      Theme.of(tester.element(find.byType(FoodSample))).colorScheme.primary,
      ColorScheme.fromSeed(seedColor: const Color(0xff39865a)).primary,
    );
    await tester.tap(find.text('Varsayılana dön'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<PhonePreview>(find.byType(PhonePreview)).config!.toJson(),
      DesignConfig.demo().toJson(),
    );
  });
}

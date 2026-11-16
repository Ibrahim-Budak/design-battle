import 'dart:async';
import 'package:design_battle/features/event/settlement_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> event(
    String phase, {
    int question = 0,
    int round = 1,
    String status = 'active',
  }) => {
    'questionStatus': phase,
    'questionIndex': question,
    'round': round,
    'status': status,
    'allowedOptions': ['A', 'B', 'C'],
  };
  SettlementSnapshot snap(
    Map<String, dynamic>? data, {
    bool cache = false,
    bool pending = false,
  }) => SettlementSnapshot(
    data: data,
    fromCache: cache,
    hasPendingWrites: pending,
  );

  test('eski açık durum ile önbellek ve bekleyen yazı atlanır', () async {
    final result = await waitForSettlement(
      snapshots: Stream.fromIterable([
        snap(event('open')),
        snap(event('settling'), cache: true),
        snap(event('settling'), pending: true),
        snap(event('settling')),
      ]),
      question: 0,
      round: 1,
    );
    expect(result!['questionStatus'], 'settling');
  });
  test(
    'aynı tur başka yönetici tarafından tamamlandıysa tekrar saymaz',
    () async {
      for (final state in ['tie', 'closed']) {
        final result = await waitForSettlement(
          snapshots: Stream.value(snap(event(state))),
          question: 0,
          round: 1,
        );
        expect(result, isNull);
      }
    },
  );
  test('yeni tur, yeni soru veya duraklamada eski sayımı başlatmaz', () async {
    for (final data in [
      event('settling', round: 2),
      event('settling', question: 1),
      event('settling', status: 'paused'),
    ]) {
      await expectLater(
        waitForSettlement(
          snapshots: Stream.value(snap(data)),
          question: 0,
          round: 1,
        ),
        throwsStateError,
      );
    }
  });
  test(
    'sunucu kapanışı doğrulamıyorsa zaman aşımı hata ile sonuçlanır',
    () async {
      final controller = StreamController<SettlementSnapshot>();
      addTearDown(controller.close);
      final waiting = waitForSettlement(
        snapshots: controller.stream,
        question: 0,
        round: 1,
        timeout: const Duration(milliseconds: 30),
      );
      controller.add(snap(event('open')));
      await expectLater(waiting, throwsStateError);
    },
  );
  test('silinmiş belge ve beklenmedik durum kabul edilmez', () async {
    for (final data in [null, event('locked')]) {
      await expectLater(
        waitForSettlement(
          snapshots: Stream.value(snap(data)),
          question: 0,
          round: 1,
        ),
        throwsStateError,
      );
    }
  });
}

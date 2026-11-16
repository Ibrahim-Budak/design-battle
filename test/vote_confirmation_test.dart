import 'package:design_battle/features/event/vote_confirmation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('başarılı gönderim sunucudan doğrulanır', () async {
    var reads = 0;
    final result = await VoteConfirmation.submit(
      send: () async {},
      readFromServer: () async {
        reads++;
        return 'B';
      },
    );
    expect(result.status, VoteCheckStatus.recorded);
    expect(result.option, 'B');
    expect(reads, 1);
  });

  test(
    'gönderim hatası sonrası sunucuda kayıt varsa gerçek seçimi gösterir',
    () async {
      var sends = 0;
      final result = await VoteConfirmation.submit(
        send: () async {
          sends++;
          throw StateError('yanıt kayboldu');
        },
        readFromServer: () async => 'A',
      );
      expect(result.status, VoteCheckStatus.recorded);
      expect(result.option, 'A');
      expect(sends, 1, reason: 'otomatik yeniden oy gönderilmemeli');
    },
  );

  test(
    'farklı seçimle tekrar denendiğinde kayıtlı seçenek esas alınır',
    () async {
      final result = await VoteConfirmation.submit(
        send: () async {},
        readFromServer: () async => 'C',
      );
      expect(result.option, 'C');
    },
  );

  test('sunucuda belge yoksa bulunamadı sonucu döner', () async {
    final result = await VoteConfirmation.submit(
      send: () async => throw StateError('gönderilemedi'),
      readFromServer: () async => null,
    );
    expect(result.status, VoteCheckStatus.notFound);
    expect(result.option, isNull);
  });

  test('bağlantı kesildiğinde doğrulandı veya gönderilmedi demez', () async {
    final result = await VoteConfirmation.submit(
      send: () async => throw StateError('yanıt kayboldu'),
      readFromServer: () async => throw StateError('bağlantı yok'),
    );
    expect(result.status, VoteCheckStatus.unknown);
    expect(result.option, isNull);
  });

  test('hatalı sunucu kaydı başarı diye gösterilmez', () async {
    final result = await VoteConfirmation.check(() async => 'X');
    expect(result.status, VoteCheckStatus.unknown);
  });

  test('belirsiz durum yeniden kontrol edilince kayıt bulunabilir', () async {
    final first = await VoteConfirmation.check(
      () async => throw StateError('offline'),
    );
    final second = await VoteConfirmation.check(() async => 'B');
    expect(first.status, VoteCheckStatus.unknown);
    expect(second.status, VoteCheckStatus.recorded);
    expect(second.option, 'B');
  });
}

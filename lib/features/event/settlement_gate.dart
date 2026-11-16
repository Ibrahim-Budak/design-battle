/// Minimal event snapshot used to wait for a server-confirmed closing state.
class SettlementSnapshot {
  final Map<String, dynamic>? data;
  final bool fromCache;
  final bool hasPendingWrites;
  const SettlementSnapshot({
    required this.data,
    required this.fromCache,
    required this.hasPendingWrites,
  });
}

/// Wait for this exact question and round to be closed for voting on the server.
/// Null means another administrator already finalized this round.
Future<Map<String, dynamic>?> waitForSettlement({
  required Stream<SettlementSnapshot> snapshots,
  required int question,
  required int round,
  Duration timeout = const Duration(seconds: 15),
}) async {
  final snapshot = await snapshots
      .timeout(
        timeout,
        onTimeout: (sink) {
          sink.addError(
            StateError(
              'Oylamanın kapanışı sunucuda henüz doğrulanamadı. Bağlantıyı kontrol edip tekrar deneyin.',
            ),
          );
          sink.close();
        },
      )
      .firstWhere((snapshot) {
        if (snapshot.fromCache || snapshot.hasPendingWrites) return false;
        final data = snapshot.data;
        if (data == null ||
            data['questionIndex'] != question ||
            data['round'] != round ||
            data['status'] != 'active') {
          return true;
        }
        return data['questionStatus'] != 'open';
      });
  final data = snapshot.data;
  if (data == null ||
      data['questionIndex'] != question ||
      data['round'] != round ||
      data['status'] != 'active') {
    throw StateError('Etkinlik veya soru durumu değişti. Ekranı kontrol edin.');
  }
  final phase = data['questionStatus'];
  if (phase == 'closed' || phase == 'tie') return null;
  if (phase != 'settling') {
    throw StateError('Bu tur sonuç hesaplamasına hazır değil.');
  }
  return data;
}

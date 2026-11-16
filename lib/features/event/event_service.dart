import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../preview/domain/design_config.dart';

/// The admin is trusted. Ballots are immutable; totals are derived from the
/// server's vote documents, never from participant-supplied counters.
class EventService {
  final FirebaseFirestore db;
  EventService([FirebaseFirestore? firestore])
    : db = firestore ?? FirebaseFirestore.instance;
  DocumentReference<Map<String, dynamic>> event(String id) =>
      db.collection('events').doc(id);
  DocumentReference<Map<String, dynamic>> design(String id) =>
      event(id).collection('design').doc('current');
  CollectionReference<Map<String, dynamic>> votes(String id, int round) =>
      event(id).collection('rounds').doc('$round').collection('votes');
  CollectionReference<Map<String, dynamic>> participants(String id) =>
      event(id).collection('participants');
  CollectionReference<Map<String, dynamic>> results(String id) =>
      event(id).collection('results');

  Future<List<String>> _reference() async {
    final data =
        (await db
                .collection('private')
                .doc('reference')
                .get(const GetOptions(source: Source.server)))
            .data();
    final raw = data?['answers'];
    if (raw is! List ||
        raw.length != 10 ||
        raw.any((x) => x is! String || !['A', 'B', 'C'].contains(x))) {
      throw StateError(
        'Özel referans belgesi eksik veya geçersiz. README kurulum adımlarını izleyin.',
      );
    }
    return raw.cast<String>();
  }

  Future<String> createEvent(User user) async {
    if (user.isAnonymous) throw StateError('Yönetici girişi gerekli.');
    // Validate that scoring is provisioned, but never derive the projected
    // starting design from the private answer key. Future choices are applied
    // only when their votes are finalized.
    await _reference();
    final initial = DesignConfig.demo();
    final ref = db.collection('events').doc(); // Firestore's random 20-char ID.
    final batch = db.batch();
    batch.set(ref, {
      'title': 'Design Battle',
      'status': 'waiting',
      'questionStatus': 'locked',
      'questionIndex': 0,
      'round': 0,
      'allowedOptions': ['A', 'B', 'C'],
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(ref.collection('design').doc('current'), initial.toJson());
    await batch.commit();
    return ref.id;
  }

  Future<void> register(String id, String uid) async {
    final ref = participants(id).doc(uid);
    await db.runTransaction((tx) async {
      final exists = await tx.get(ref);
      if (!exists.exists) {
        tx.set(ref, {'joinedAt': FieldValue.serverTimestamp()});
      }
    });
  }

  Future<void> submitVote(
    String id,
    String uid,
    int expectedQuestion,
    int expectedRound,
    String option,
  ) async {
    final e = event(id), ballot = votes(id, expectedRound).doc(uid);
    await db.runTransaction((tx) async {
      final current = (await tx.get(e)).data();
      final previous = await tx.get(ballot);
      if (current == null ||
          current['status'] != 'active' ||
          current['questionStatus'] != 'open' ||
          current['questionIndex'] != expectedQuestion ||
          current['round'] != expectedRound ||
          !(current['allowedOptions'] as List).contains(option)) {
        throw StateError('Oylama artık açık değil.');
      }
      if (previous.exists) {
        throw StateError('Bu tur için zaten oy kullandınız.');
      }
      tx.set(ballot, {
        'option': option,
        'questionIndex': expectedQuestion,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> open(String id) async {
    await db.runTransaction((tx) async {
      final e = event(id), data = (await tx.get(e)).data();
      if (data == null ||
          data['questionStatus'] != 'locked' ||
          !['waiting', 'active'].contains(data['status'])) {
        throw StateError('Soru açılamıyor.');
      }
      tx.update(e, {
        'status': 'active',
        'questionStatus': 'open',
        'round': (data['round'] as int) + 1,
        'allowedOptions': ['A', 'B', 'C'],
      });
    });
  }

  Future<void> pause(String id, bool paused) async {
    await db.runTransaction((tx) async {
      final e = event(id), data = (await tx.get(e)).data();
      if (data == null ||
          (paused ? data['status'] != 'active' : data['status'] != 'paused')) {
        throw StateError('Etkinlik durumu değişti.');
      }
      tx.update(e, {'status': paused ? 'paused' : 'active'});
    });
  }

  Future<void> close(String id) async {
    await db.runTransaction((tx) async {
      final e = event(id), data = (await tx.get(e)).data();
      if (data == null ||
          data['status'] != 'active' ||
          data['questionStatus'] != 'open') {
        throw StateError('Açık bir oylama yok.');
      }
      tx.update(e, {'questionStatus': 'settling'});
    });
    await settle(id);
  }

  Future<void> settle(String id) async {
    final snapshot = await event(
      id,
    ).get(const GetOptions(source: Source.server));
    final data = snapshot.data();
    if (data == null || data['questionStatus'] != 'settling') {
      throw StateError('Hesaplanacak oylama yok.');
    }
    final round = data['round'] as int;
    final docs = await votes(
      id,
      round,
    ).get(const GetOptions(source: Source.server));
    final counts = <String, int>{'A': 0, 'B': 0, 'C': 0};
    for (final vote in docs.docs) {
      final option = vote.data()['option'];
      if (counts.containsKey(option)) {
        counts[option as String] = counts[option]! + 1;
      }
    }
    final allowed = List<String>.from(data['allowedOptions'] as List);
    if (allowed.isEmpty ||
        allowed.any((option) => !counts.containsKey(option))) {
      throw StateError('Oylama seçenekleri geçersiz.');
    }
    final max = allowed
        .map((option) => counts[option]!)
        .reduce((a, b) => a > b ? a : b);
    final tied = allowed.where((key) => counts[key] == max).toList();
    if (tied.length == 1) {
      await _finalize(id, round, tied.single, counts, false, 'settling');
    } else {
      await db.runTransaction((tx) async {
        final e = event(id), current = (await tx.get(e)).data();
        if (current == null ||
            current['round'] != round ||
            current['questionStatus'] != 'settling') {
          throw StateError('Soru durumu değişti.');
        }
        tx.update(e, {
          'questionStatus': 'tie',
          'tieOptions': tied,
          'tieCounts': counts,
        });
      });
    }
  }

  Future<void> resolveTie(String id, String winner) async {
    final data = (await event(
      id,
    ).get(const GetOptions(source: Source.server))).data();
    if (data == null ||
        data['questionStatus'] != 'tie' ||
        !(data['tieOptions'] as List).contains(winner)) {
      throw StateError('Geçersiz beraberlik kararı.');
    }
    final counts = Map<String, int>.from(data['tieCounts'] as Map);
    await _finalize(id, data['round'] as int, winner, counts, true, 'tie');
  }

  Future<void> _finalize(
    String id,
    int round,
    String winner,
    Map<String, int> counts,
    bool manual,
    String expectedStatus,
  ) async {
    await db.runTransaction((tx) async {
      final e = event(id), d = design(id);
      final current = (await tx.get(e)).data(),
          currentDesign = (await tx.get(d)).data();
      if (current == null ||
          currentDesign == null ||
          current['round'] != round ||
          current['questionStatus'] != expectedStatus) {
        throw StateError('Soru durumu değişti.');
      }
      if (manual && !(current['tieOptions'] as List).contains(winner)) {
        throw StateError('Kazanan beraberlikte değil.');
      }
      final index = current['questionIndex'] as int;
      final next = DesignConfig.fromJson(
        currentDesign,
      ).choose(index, winner.codeUnitAt(0) - 65);
      tx.set(results(id).doc('$index'), {
        'questionIndex': index,
        'winner': winner,
        'counts': counts,
        'round': round,
        'manual': manual,
      });
      tx.set(d, next.toJson());
      tx.update(e, {'questionStatus': 'closed'});
    });
  }

  Future<void> revote(String id) async {
    await db.runTransaction((tx) async {
      final e = event(id), data = (await tx.get(e)).data();
      if (data == null ||
          data['status'] != 'active' ||
          data['questionStatus'] != 'tie') {
        throw StateError('Yeniden oylama açılamıyor.');
      }
      tx.update(e, {
        'round': (data['round'] as int) + 1,
        'questionStatus': 'open',
        'allowedOptions': data['tieOptions'],
      });
    });
  }

  Future<void> next(String id) async {
    final current = (await event(
      id,
    ).get(const GetOptions(source: Source.server))).data();
    if (current == null ||
        current['questionStatus'] != 'closed' ||
        current['status'] != 'active') {
      throw StateError('Önce oylamayı tamamlayın.');
    }
    final index = current['questionIndex'] as int;
    if (index < 9) {
      await db.runTransaction((tx) async {
        final e = event(id), data = (await tx.get(e)).data();
        if (data == null ||
            data['questionStatus'] != 'closed' ||
            data['questionIndex'] != index ||
            data['status'] != 'active') {
          throw StateError('Etkinlik durumu değişti.');
        }
        tx.update(e, {
          'questionIndex': index + 1,
          'questionStatus': 'locked',
          'allowedOptions': ['A', 'B', 'C'],
        });
      });
      return;
    }
    final reference = await _reference();
    final all = await results(id).get(const GetOptions(source: Source.server));
    if (all.docs.length != 10) {
      throw StateError('On sorunun tamamı kesinleşmiş olmalı.');
    }
    final byId = {for (final d in all.docs) d.id: d.data()};
    if (List.generate(10, (i) => '$i').any((i) => !byId.containsKey(i))) {
      throw StateError('Soru sonuçları eksik.');
    }
    await db.runTransaction((tx) async {
      final e = event(id), data = (await tx.get(e)).data();
      if (data == null ||
          data['questionStatus'] != 'closed' ||
          data['questionIndex'] != 9 ||
          data['status'] != 'active') {
        throw StateError('Etkinlik durumu değişti.');
      }
      var score = 0;
      for (var i = 0; i < 10; i++) {
        final match = byId['$i']!['winner'] == reference[i];
        if (match) score++;
        tx.update(results(id).doc('$i'), {
          'reference': reference[i],
          'matches': match,
        });
      }
      tx.update(e, {'status': 'completed', 'score': score});
    });
  }
}

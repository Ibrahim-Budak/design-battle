import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../shared/layout.dart';
import '../preview/domain/design_config.dart';
import 'event_service.dart';

class ParticipantEvent extends StatefulWidget {
  final String code;
  const ParticipantEvent({super.key, required this.code});
  @override
  State<ParticipantEvent> createState() => _ParticipantEventState();
}

class _ParticipantEventState extends State<ParticipantEvent> {
  final service = EventService();
  User? user;
  String? error;
  bool loading = true, sending = false;
  int? selected, lastRound;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> eventStream;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? ballotStream;
  int? ballotStreamRound;
  @override
  void initState() {
    super.initState();
    eventStream = service.event(widget.code).snapshots();
    start();
  }

  Future<void> start() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      await auth.setPersistence(Persistence.LOCAL);
      var current = await auth.authStateChanges().first;
      if (current != null && !current.isAnonymous) {
        throw StateError(
          'Yönetici oturumu açık. Katılım için farklı bir tarayıcı profili kullanın.',
        );
      }
      current ??= (await auth.signInAnonymously()).user;
      if (current == null) throw StateError('Anonim oturum açılamadı.');
      final event =
          (await service
                  .event(widget.code)
                  .get(const GetOptions(source: Source.server)))
              .data();
      if (event == null) {
        throw StateError('Etkinlik bulunamadı. Bağlantıyı kontrol edin.');
      }
      if (event['status'] != 'completed') {
        await service.register(widget.code, current.uid);
      }
      if (mounted) setState(() => user = current);
    } catch (e) {
      if (mounted) setState(() => error = 'Katılım sağlanamadı: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> vote(int q, int round, String option) async {
    setState(() {
      sending = true;
      error = null;
    });
    try {
      await service.submitVote(widget.code, user!.uid, q, round, option);
    } catch (e) {
      if (mounted) setState(() => error = 'Oy gönderilemedi: $e');
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (user == null) {
      return Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error ?? 'Bağlantı kurulamadı.'),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: start, child: const Text('Tekrar dene')),
          ],
        ),
      );
    }
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: eventStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Etkinlik yüklenemedi. Bağlantıyı kontrol edin.');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!.data();
        if (data == null) return const Text('Etkinlik bulunamadı.');
        final index = data['questionIndex'] as int,
            round = data['round'] as int;
        final status = data['status'];
        final phase = data['questionStatus'];
        if (index < 0 || index >= 10) {
          return const Text('Etkinlik verisi geçersiz.');
        }
        if (lastRound != round) {
          lastRound = round;
          selected = null;
          ballotStreamRound = null;
          ballotStream = null;
          error = null;
        }
        if (status == 'completed') {
          return Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Etkinlik tamamlandı.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Katıldığınız için teşekkürler.'),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/results?event=${widget.code}',
                  ),
                  child: const Text('Sonuçları gör'),
                ),
              ],
            ),
          );
        }
        if (status == 'paused') {
          return const Panel(
            child: Text(
              'Etkinlik duraklatıldı. Yönetici devam ettirdiğinde bu ekran güncellenecek.',
            ),
          );
        }
        if (status != 'active' || phase != 'open') {
          return const Panel(
            child: Text(
              'Bir sonraki soru için bekleyin. Yönetici oylamayı açtığında ekran güncellenecek.',
            ),
          );
        }
        final allowed = List<String>.from(data['allowedOptions'] as List);
        if (ballotStreamRound != round) {
          ballotStreamRound = round;
          ballotStream = service
              .votes(widget.code, round)
              .doc(user!.uid)
              .snapshots(includeMetadataChanges: true);
        }
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          key: ValueKey(round),
          stream: ballotStream,
          builder: (context, v) {
            if (v.hasError) {
              return const Text(
                'Oy durumu alınamadı. Bağlantıyı kontrol edin.',
              );
            }
            if (!v.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (v.data!.metadata.isFromCache ||
                v.data!.metadata.hasPendingWrites) {
              return const Panel(
                child: Text(
                  'Sunucu bağlantısı ve oy durumu doğrulanıyor. Bağlantınız kesildiyse yeniden deneyin.',
                ),
              );
            }
            if (v.data!.exists) {
              return Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 32),
                    const SizedBox(height: 14),
                    const Text(
                      'Oyun kaydedildi.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Seçimin: ${v.data!.data()!['option']} · Sonraki soruyu bekle.',
                    ),
                  ],
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusPill('SORU ${index + 1} / 10'),
                const SizedBox(height: 18),
                Text(
                  DesignConfig.questions[index],
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 18),
                if (allowed.length < 3)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Beraberlik turu: yalnızca eşit seçenekler oylanabilir.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap:
                            !allowed.contains(String.fromCharCode(65 + i)) ||
                                sending
                            ? null
                            : () => setState(() => selected = i),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selected == i
                                  ? BattleColors.ink
                                  : BattleColors.line,
                              width: selected == i ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                String.fromCharCode(65 + i),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DesignConfig.labels[index][i],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            allowed.contains(
                                              String.fromCharCode(65 + i),
                                            )
                                            ? BattleColors.ink
                                            : BattleColors.muted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DesignConfig.optionDescriptions[index][i],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: BattleColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selected == i)
                                const Icon(Icons.check_circle, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: selected == null || sending
                        ? null
                        : () => vote(
                            index,
                            round,
                            String.fromCharCode(65 + selected!),
                          ),
                    child: Text(sending ? 'Gönderiliyor…' : 'Oyumu gönder'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

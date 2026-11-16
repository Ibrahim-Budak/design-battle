import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../shared/layout.dart';
import '../auth/firebase_bootstrap.dart';
import '../event/event_service.dart';
import '../preview/domain/design_config.dart';
import '../preview/food_preview.dart';

class ResultsPage extends StatelessWidget {
  final String? eventCode;
  const ResultsPage({super.key, this.eventCode});
  @override
  Widget build(BuildContext context) {
    final code = eventCode;
    if (!FirebaseBootstrap.ready ||
        code == null ||
        !RegExp(r'^[A-Za-z0-9]{20}$').hasMatch(code)) {
      return BattleShell(
        section: 'Sonuçlar',
        child: Center(
          child: Panel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tamamlanmış bir etkinlik seçin.'),
                TextButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (_) => false,
                  ),
                  child: const Text('← Ana sayfa'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return BattleShell(
      section: 'Sonuçlar',
      child: _ResultsContent(code: code),
    );
  }
}

class _ResultsContent extends StatefulWidget {
  final String code;
  const _ResultsContent({required this.code});
  @override
  State<_ResultsContent> createState() => _ResultsContentState();
}

class _ResultsContentState extends State<_ResultsContent> {
  final service = EventService();
  late Future<User?> session;
  @override
  void initState() {
    super.initState();
    session = _session();
  }

  Future<User?> _session() async {
    final auth = FirebaseAuth.instance;
    final existing = await auth.authStateChanges().first;
    return existing ?? (await auth.signInAnonymously()).user;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<User?>(
    future: session,
    builder: (context, auth) {
      if (auth.hasError) return const Center(child: Text('Oturum açılamadı.'));
      if (!auth.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: service.event(widget.code).snapshots(),
        builder: (context, event) {
          if (event.hasError) {
            return const Center(child: Text('Etkinlik yüklenemedi.'));
          }
          if (!event.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = event.data!.data();
          if (data == null) {
            return const Center(child: Text('Etkinlik bulunamadı.'));
          }
          if (data['status'] != 'completed') {
            return const Center(
              child: Text('Sonuçlar etkinlik tamamlandığında gösterilecek.'),
            );
          }
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: service.results(widget.code).snapshots(),
            builder: (context, r) {
              if (r.hasError) {
                return const Center(child: Text('Sonuçlar yüklenemedi.'));
              }
              if (!r.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final byIndex = {
                for (final d in r.data!.docs)
                  d.data()['questionIndex'] as int: d.data(),
              };
              if (byIndex.length != 10 ||
                  List.generate(
                    10,
                    (i) => i,
                  ).any((i) => !byIndex.containsKey(i))) {
                return const Center(child: Text('Sonuçlar eksik.'));
              }
              var reference = DesignConfig.demo();
              for (var i = 0; i < 10; i++) {
                final answer = byIndex[i]!['reference'] as String;
                reference = reference.choose(i, answer.codeUnitAt(0) - 65);
              }
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: service.design(widget.code).snapshots(),
                builder: (context, d) {
                  if (d.hasError) {
                    return const Center(child: Text('Tasarım yüklenemedi.'));
                  }
                  if (!d.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  DesignConfig classDesign;
                  try {
                    classDesign = DesignConfig.fromJson(d.data!.data()!);
                  } catch (_) {
                    return const Center(
                      child: Text('Tasarım verisi geçersiz.'),
                    );
                  }
                  final score = data['score'] as int;
                  return SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Eyebrow('ETKİNLİK TAMAMLANDI'),
                              const SizedBox(height: 10),
                              Text(
                                'İki tasarım, bir deneyim.',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$score / 10 eşleşme · %${score * 10}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Bu puan yalnızca etkinlik içi bir karşılaştırmadır; nesnel tasarım kalitesi değildir.',
                              ),
                              const SizedBox(height: 24),
                              LayoutBuilder(
                                builder: (context, c) {
                                  Widget column(
                                    String label,
                                    DesignConfig config,
                                  ) => Column(
                                    children: [
                                      Text(
                                        label,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Semantics(
                                        label: label,
                                        child: ExcludeSemantics(
                                          child: PhonePreview(config: config),
                                        ),
                                      ),
                                    ],
                                  );
                                  return c.maxWidth >= 680
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            column(
                                              'Sınıfın tasarımı',
                                              classDesign,
                                            ),
                                            column(
                                              'Referans tasarım',
                                              reference,
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            column(
                                              'Sınıfın tasarımı',
                                              classDesign,
                                            ),
                                            const SizedBox(height: 24),
                                            column(
                                              'Referans tasarım',
                                              reference,
                                            ),
                                          ],
                                        );
                                },
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                'Kararların dökümü',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              for (var i = 0; i < 10; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Panel(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${i + 1}. ${DesignConfig.questions[i]}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Sınıf: ${byIndex[i]!['winner']} · Referans: ${byIndex[i]!['reference']} · ${byIndex[i]!['matches'] == true ? 'Eşleşti' : 'Farklı'}${byIndex[i]!['manual'] == true ? ' · Manuel karar' : ''}',
                                        ),
                                        const SizedBox(height: 8),
                                        for (final option in ['A', 'B', 'C'])
                                          Builder(
                                            builder: (context) {
                                              final counts =
                                                  Map<String, dynamic>.from(
                                                    byIndex[i]!['counts']
                                                        as Map,
                                                  );
                                              final count =
                                                  (counts[option] as num)
                                                      .toInt();
                                              final total = counts.values
                                                  .fold<int>(
                                                    0,
                                                    (acc, n) =>
                                                        acc +
                                                        (n as num).toInt(),
                                                  );
                                              return Text(
                                                '$option: $count oy · %${total == 0 ? 0 : (count * 100 / total).round()}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: BattleColors.muted,
                                                ),
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}

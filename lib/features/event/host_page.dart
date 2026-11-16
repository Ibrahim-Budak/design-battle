import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../shared/layout.dart';
import '../auth/admin_auth_panel.dart';
import '../auth/firebase_bootstrap.dart';
import '../preview/domain/design_config.dart';
import '../preview/food_preview.dart';
import 'event_service.dart';

String participantUrl(Uri base, String code) => base
    .replace(fragment: '/join?event=${Uri.encodeQueryComponent(code)}')
    .toString();

class HostPage extends StatefulWidget {
  final String? eventCode;
  const HostPage({super.key, this.eventCode});
  @override
  State<HostPage> createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  bool busy = false;
  EventService? _service;
  Stream<User?>? _authStream;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _eventStream, _designStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _participantsStream,
      _votesStream;
  int? _votesRound;
  Future<void> action(Future<void> Function() run) async {
    setState(() => busy = true);
    try {
      await run();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('İşlem tamamlanamadı: $e')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.eventCode;
    if (!FirebaseBootstrap.ready ||
        code == null ||
        !RegExp(r'^[A-Za-z0-9]{20}$').hasMatch(code)) {
      return const BattleShell(
        section: 'Etkinlik yönetimi',
        child: Center(
          child: Text('Firebase veya etkinlik kodu kullanılamıyor.'),
        ),
      );
    }
    final service = _service ??= EventService();
    _authStream ??= FirebaseAuth.instance.authStateChanges();
    _eventStream ??= service.event(code).snapshots();
    _designStream ??= service.design(code).snapshots();
    _participantsStream ??= service.participants(code).snapshots();
    return BattleShell(
      section: 'Etkinlik yönetimi',
      child: StreamBuilder<User?>(
        stream: _authStream,
        builder: (context, auth) {
          if (auth.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final user = auth.data;
          if (user == null || user.isAnonymous) {
            return Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: AdminAuthPanel(),
                ),
              ),
            );
          }
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _eventStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Etkinlik yüklenemedi veya erişim reddedildi.'),
                );
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final data = snapshot.data!.data();
              if (data == null) {
                return Center(child: Text('Etkinlik bulunamadı.'));
              }
              if (data['createdBy'] != user.uid) {
                return Center(
                  child: Text('Bu etkinliği yalnızca sahibi yönetebilir.'),
                );
              }
              final index = data['questionIndex'] as int;
              final round = data['round'] as int;
              if (_votesRound != round) {
                _votesRound = round;
                _votesStream = service.votes(code, round).snapshots();
              }
              final status = data['status'] as String;
              final state = data['questionStatus'] as String;
              final statusLabel =
                  {
                    'waiting': 'Katılımcılar bekleniyor',
                    'active': 'Devam ediyor',
                    'paused': 'Duraklatıldı',
                    'completed': 'Tamamlandı',
                  }[status] ??
                  status;
              final phaseLabel =
                  {
                    'locked': 'Bekliyor',
                    'open': 'Açık',
                    'settling': 'Hesaplanıyor',
                    'tie': 'Beraberlik',
                    'closed': 'Kapalı',
                  }[state] ??
                  state;
              if (index < 0 || index >= 10) {
                return Center(child: Text('Etkinlik verisi geçersiz.'));
              }
              final link = participantUrl(Uri.base, code);
              return SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1300),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final info = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Eyebrow('CANLI ETKİNLİK'),
                              const SizedBox(height: 10),
                              Text(
                                'Sınıf birlikte tasarlıyor.',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 12),
                              Panel(
                                child: Wrap(
                                  spacing: 24,
                                  runSpacing: 16,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      color: Colors.white,
                                      padding: const EdgeInsets.all(8),
                                      child: QrImageView(
                                        data: link,
                                        size: 210,
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Eyebrow('KATILIM İÇİN OKUTUN'),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Kod: $code',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        StreamBuilder<
                                          QuerySnapshot<Map<String, dynamic>>
                                        >(
                                          stream: _participantsStream,
                                          builder: (context, p) {
                                            if (p.hasError) {
                                              return const Text(
                                                'Katılımcı sayısı alınamadı',
                                              );
                                            }
                                            if (!p.hasData) {
                                              return const Text(
                                                'Katılımcılar yükleniyor…',
                                              );
                                            }
                                            return Text(
                                              '${p.data!.docs.length} katılımcı',
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        OutlinedButton(
                                          onPressed: () async {
                                            try {
                                              await Clipboard.setData(
                                                ClipboardData(text: link),
                                              );
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Katılım bağlantısı kopyalandı.',
                                                    ),
                                                  ),
                                                );
                                              }
                                            } catch (_) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Bağlantı kopyalanamadı.',
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: const Text(
                                            'Bağlantıyı kopyala',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Panel(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        StatusPill('Soru ${index + 1} / 10'),
                                        StatusPill('Etkinlik: $statusLabel'),
                                        StatusPill('Oylama: $phaseLabel'),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      DesignConfig.questions[index],
                                      style: const TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    StreamBuilder<
                                      QuerySnapshot<Map<String, dynamic>>
                                    >(
                                      stream: _votesStream,
                                      builder: (context, v) {
                                        if (v.hasError) {
                                          return const Text('Oylar alınamadı.');
                                        }
                                        if (!v.hasData) {
                                          return const Text(
                                            'Oylar yükleniyor…',
                                          );
                                        }
                                        final counts = <String, int>{
                                          'A': 0,
                                          'B': 0,
                                          'C': 0,
                                        };
                                        for (final doc in v.data!.docs) {
                                          final x = doc.data()['option'];
                                          if (counts.containsKey(x)) {
                                            counts[x as String] =
                                                counts[x]! + 1;
                                          }
                                        }
                                        final total = counts.values.fold<int>(
                                          0,
                                          (a, b) => a + b,
                                        );
                                        return Column(
                                          children: [
                                            for (var j = 0; j < 3; j++)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 25,
                                                      child: Text(
                                                        String.fromCharCode(
                                                          65 + j,
                                                        ),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        DesignConfig
                                                            .labels[index][j],
                                                      ),
                                                    ),
                                                    Text(
                                                      '${counts[String.fromCharCode(65 + j)]} oy · %${total == 0 ? 0 : (counts[String.fromCharCode(65 + j)]! * 100 / total).round()}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        if (state == 'locked' &&
                                            [
                                              'waiting',
                                              'active',
                                            ].contains(status))
                                          FilledButton(
                                            onPressed: busy
                                                ? null
                                                : () => action(
                                                    () => service.open(code),
                                                  ),
                                            child: const Text('Oylamayı aç'),
                                          ),
                                        if (state == 'open' &&
                                            status == 'active')
                                          FilledButton(
                                            onPressed: busy
                                                ? null
                                                : () => action(
                                                    () => service.close(code),
                                                  ),
                                            child: const Text('Oylamayı kapat'),
                                          ),
                                        if (state == 'settling' &&
                                            status == 'active')
                                          FilledButton(
                                            onPressed: busy
                                                ? null
                                                : () => action(
                                                    () => service.settle(code),
                                                  ),
                                            child: const Text(
                                              'Sonuçları tekrar hesapla',
                                            ),
                                          ),
                                        if (status == 'active')
                                          OutlinedButton(
                                            onPressed: busy
                                                ? null
                                                : () => action(
                                                    () => service.pause(
                                                      code,
                                                      true,
                                                    ),
                                                  ),
                                            child: const Text('Duraklat'),
                                          ),
                                        if (status == 'paused')
                                          FilledButton(
                                            onPressed: busy
                                                ? null
                                                : () => action(
                                                    () => service.pause(
                                                      code,
                                                      false,
                                                    ),
                                                  ),
                                            child: const Text('Devam et'),
                                          ),
                                        if (state == 'closed' &&
                                            status == 'active')
                                          FilledButton(
                                            onPressed: busy
                                                ? null
                                                : () => action(
                                                    () => service.next(code),
                                                  ),
                                            child: Text(
                                              index == 9
                                                  ? 'Etkinliği bitir'
                                                  : 'Sonraki soru',
                                            ),
                                          ),
                                        if (status == 'completed')
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.pushNamed(
                                                  context,
                                                  '/results?event=$code',
                                                ),
                                            child: const Text(
                                              'Sonuçları göster',
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (state == 'tie') ...[
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Beraberlik var. Kazanan otomatik seçilmez.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          if (status == 'active')
                                            OutlinedButton(
                                              onPressed: busy
                                                  ? null
                                                  : () => action(
                                                      () =>
                                                          service.revote(code),
                                                    ),
                                              child: const Text(
                                                'Beraberliği yeniden oylat',
                                              ),
                                            ),
                                          for (final option
                                              in List<String>.from(
                                                data['tieOptions'] as List,
                                              ))
                                            OutlinedButton(
                                              onPressed:
                                                  busy || status != 'active'
                                                  ? null
                                                  : () => action(
                                                      () => service.resolveTie(
                                                        code,
                                                        option,
                                                      ),
                                                    ),
                                              child: Text('$option manuel seç'),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                          final preview =
                              StreamBuilder<
                                DocumentSnapshot<Map<String, dynamic>>
                              >(
                                stream: _designStream,
                                builder: (context, d) {
                                  if (d.hasError) {
                                    return const Text('Tasarım yüklenemedi.');
                                  }
                                  if (!d.hasData) {
                                    return const CircularProgressIndicator();
                                  }
                                  try {
                                    return Column(
                                      children: [
                                        const Eyebrow('KESİNLEŞEN TASARIM'),
                                        const SizedBox(height: 16),
                                        Semantics(
                                          label:
                                              'Canlı yemek uygulaması önizlemesi',
                                          child: ExcludeSemantics(
                                            child: PhonePreview(
                                              config: DesignConfig.fromJson(
                                                d.data!.data()!,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pushNamed(
                                            context,
                                            '/preview?event=$code',
                                          ),
                                          child: const Text(
                                            'Erişilebilir önizlemeyi aç',
                                          ),
                                        ),
                                      ],
                                    );
                                  } catch (_) {
                                    return const Text(
                                      'Tasarım verisi geçersiz.',
                                    );
                                  }
                                },
                              );
                          return c.maxWidth > 850
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 6, child: info),
                                    const SizedBox(width: 24),
                                    Expanded(flex: 4, child: preview),
                                  ],
                                )
                              : Column(
                                  children: [
                                    info,
                                    const SizedBox(height: 24),
                                    preview,
                                  ],
                                );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

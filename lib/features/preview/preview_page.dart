import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../shared/layout.dart';
import '../auth/firebase_bootstrap.dart';
import '../event/event_service.dart';
import 'domain/design_config.dart';
import 'food_preview.dart';

class PreviewPage extends StatelessWidget {
  final String? eventCode;
  const PreviewPage({super.key, this.eventCode});
  @override
  Widget build(BuildContext context) => BattleShell(
    section: 'Önizleme',
    child: SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Eyebrow('TASARIM STÜDYOSU'),
              const SizedBox(height: 10),
              Text(
                'Fikirler ekrana yansıyor.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              if (eventCode == null || !FirebaseBootstrap.ready) ...[
                const Text('Yerel örnek veri · Canlı etkinliğe bağlı değil'),
                const SizedBox(height: 24),
                const PhonePreview(),
              ] else ...[
                const Text(
                  'Etkinlik önizlemesi · Oylama sırasında yalnızca yöneticiye açık',
                ),
                const SizedBox(height: 24),
                StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, auth) {
                    if (!auth.hasData) {
                      return const Text('Önizlemeyi görmek için giriş yapın.');
                    }
                    return StreamBuilder<
                      DocumentSnapshot<Map<String, dynamic>>
                    >(
                      stream: EventService().design(eventCode!).snapshots(),
                      builder: (context, d) {
                        if (d.hasError) {
                          return const Text(
                            'Bu önizlemeye erişiminiz yok veya bağlantı kurulamadı.',
                          );
                        }
                        if (!d.hasData) {
                          return const CircularProgressIndicator();
                        }
                        try {
                          return PhonePreview(
                            config: DesignConfig.fromJson(d.data!.data()!),
                          );
                        } catch (_) {
                          return const Text('Tasarım bulunamadı.');
                        }
                      },
                    );
                  },
                ),
              ],
              const SizedBox(height: 24),
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
    ),
  );
}

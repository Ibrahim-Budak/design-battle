import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../shared/layout.dart';
import '../auth/anonymous_session.dart';
import '../auth/firebase_bootstrap.dart';
import '../event/participant_event.dart';

class JoinPage extends StatelessWidget {
  final String? eventCode;
  const JoinPage({super.key, this.eventCode});
  @override
  Widget build(BuildContext context) {
    if (FirebaseBootstrap.ready &&
        eventCode != null &&
        RegExp(r'^[A-Za-z0-9]{20}$').hasMatch(eventCode!)) {
      return BattleShell(
        section: 'Katılımcı alanı',
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ParticipantEvent(code: eventCode!),
              ),
            ),
          ),
        ),
      );
    }
    return BattleShell(
      section: 'Katılımcı alanı',
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  const StatusPill('KATILIM'),
                  const SizedBox(height: 24),
                  Text(
                    'Birlikte tasarlamaya hazır mısın?',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Etkinlik başladığında QR kodu okutarak sorulara katılabileceksin.',
                  ),
                  const SizedBox(height: 30),
                  Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.hourglass_empty_rounded,
                          color: BattleColors.muted,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Katılım henüz hazır değil',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Etkinlik doğrulaması ve oylama henüz hazır değil. Bu ekrandan henüz oy gönderilemez.',
                        ),
                        const SizedBox(height: 12),
                        const AnonymousSession(),
                        if (eventCode != null && eventCode!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Bağlantıdaki etkinlik kodu: $eventCode',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: BattleColors.muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
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
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import 'firebase_bootstrap.dart';

class AnonymousSession extends StatefulWidget {
  const AnonymousSession({super.key});
  @override
  State<AnonymousSession> createState() => _AnonymousSessionState();
}

class _AnonymousSessionState extends State<AnonymousSession> {
  String message = 'Anonim oturum hazırlanıyor…';
  @override
  void initState() {
    super.initState();
    if (FirebaseBootstrap.ready) start();
  }

  Future<void> start() async {
    setState(() => message = 'Anonim oturum hazırlanıyor…');
    try {
      final auth = FirebaseAuth.instance;
      await auth.setPersistence(Persistence.LOCAL);
      // Wait for Firebase to restore the persisted user before deciding to sign in.
      final existing = await auth.authStateChanges().first;
      if (existing != null && !existing.isAnonymous) {
        if (mounted) {
          setState(
            () => message =
                'Bu tarayıcıda yönetici oturumu açık. Katılımcı denemesi için başka bir tarayıcı kullanın.',
          );
        }
        return;
      }
      if (existing == null) await auth.signInAnonymously();
      if (mounted) {
        setState(
          () => message =
              'Anonim oturum hazır. Etkinlik bağlantısı henüz doğrulanmıyor; oylama henüz kullanılabilir değil.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(
          () => message =
              'Anonim oturum açılamadı (${e.code}). Bağlantıyı ve Firebase Authentication ayarlarını kontrol edin.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => message =
              'Anonim oturum açılamadı. Bağlantıyı ve Firebase Authentication ayarlarını kontrol edin.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!FirebaseBootstrap.ready) {
      return Text(
        FirebaseBootstrap.error ??
            'Firebase yapılandırılmadı; anonim oturum henüz kullanılamıyor.',
        style: const TextStyle(fontSize: 12, color: BattleColors.muted),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: const TextStyle(fontSize: 12, color: BattleColors.muted),
        ),
        if (message.startsWith('Anonim oturum açılamadı'))
          TextButton(onPressed: start, child: const Text('Tekrar dene')),
      ],
    );
  }
}

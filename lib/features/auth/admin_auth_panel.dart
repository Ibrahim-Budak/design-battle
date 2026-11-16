import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../shared/layout.dart';
import 'firebase_bootstrap.dart';

class AdminAuthPanel extends StatefulWidget {
  const AdminAuthPanel({super.key});
  @override
  State<AdminAuthPanel> createState() => _AdminAuthPanelState();
}

class _AdminAuthPanelState extends State<AdminAuthPanel> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? failure;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      setState(() => failure = 'E-posta ve parolanızı girin.');
      return;
    }
    setState(() {
      busy = true;
      failure = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );
      password.clear();
    } on FirebaseAuthException catch (_) {
      if (mounted) {
        setState(
          () => failure =
              'Giriş yapılamadı. Kimlik bilgilerini ve bağlantıyı kontrol edin.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => failure = 'Giriş sırasında bir hata oluştu. Tekrar deneyin.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!FirebaseBootstrap.ready) {
      return Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('YÖNETİCİ KİMLİĞİ'),
            const SizedBox(height: 10),
            Text(
              FirebaseBootstrap.error ??
                  'Firebase yapılandırılmadı. Yönetici girişi kullanılamıyor.',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kurulum adımları README dosyasındadır.',
              style: TextStyle(fontSize: 12, color: BattleColors.muted),
            ),
          ],
        ),
      );
    }
    return Panel(
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text('Oturum durumu alınamadı.');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          final user = snapshot.data;
          if (user == null || user.isAnonymous) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('YÖNETİCİ GİRİŞİ'),
                const SizedBox(height: 10),
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.username],
                  decoration: const InputDecoration(labelText: 'E-posta'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: password,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) {
                    if (!busy) signIn();
                  },
                  decoration: const InputDecoration(labelText: 'Parola'),
                ),
                if (failure != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      failure!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: busy ? null : signIn,
                  child: Text(busy ? 'Giriş yapılıyor…' : 'Giriş yap'),
                ),
              ],
            );
          }
          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('admins')
                .doc(user.uid)
                .get(const GetOptions(source: Source.server)),
            builder: (context, role) {
              String status;
              if (role.connectionState != ConnectionState.done) {
                status = 'Yetki kontrol ediliyor…';
              } else if (role.hasError) {
                status =
                    'Yönetici yetkisi doğrulanamadı. Bağlantıyı ve kuralları kontrol edin.';
              } else if (role.data?.exists == true) {
                status = 'Yönetici yetkisi doğrulandı.';
              } else {
                status = 'Bu hesap yönetici listesinde değil.';
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('YÖNETİCİ OTURUMU'),
                  const SizedBox(height: 10),
                  Text(
                    user.email ?? 'Hesap',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(status, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: const Text('Çıkış yap'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../shared/layout.dart';
import '../auth/firebase_bootstrap.dart';
import 'event_service.dart';

class AdminEventPanel extends StatefulWidget {
  const AdminEventPanel({super.key});
  @override
  State<AdminEventPanel> createState() => _AdminEventPanelState();
}

class _AdminEventPanelState extends State<AdminEventPanel> {
  bool busy = false;
  String? error;
  final code = TextEditingController();
  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  Future<void> create(User user) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final id = await EventService().createEvent(user);
      if (mounted) Navigator.pushNamed(context, '/host?event=$id');
    } catch (e) {
      if (mounted) setState(() => error = 'Etkinlik oluşturulamadı: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!FirebaseBootstrap.ready) return const SizedBox.shrink();
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, auth) {
        final user = auth.data;
        if (user == null || user.isAnonymous) return const SizedBox.shrink();
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('admins')
              .doc(user.uid)
              .get(const GetOptions(source: Source.server)),
          builder: (context, role) {
            if (role.connectionState != ConnectionState.done ||
                role.hasError ||
                role.data?.exists != true) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('GERÇEK ETKİNLİK'),
                    const SizedBox(height: 10),
                    const Text(
                      'Etkinlik oluşturun veya kodla devam edin.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Referans belgesi Firebase üzerinde yöneticiye özel kurulmuş olmalıdır.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: busy ? null : () => create(user),
                      child: Text(
                        busy ? 'Oluşturuluyor…' : 'Yeni etkinlik oluştur',
                      ),
                    ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: code,
                      decoration: const InputDecoration(
                        labelText: 'Mevcut etkinlik kodu',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final id = code.text.trim();
                        if (RegExp(r'^[A-Za-z0-9]{20}$').hasMatch(id)) {
                          Navigator.pushNamed(context, '/host?event=$id');
                        } else {
                          setState(
                            () => error =
                                'Geçerli bir 20 karakterli etkinlik kodu girin.',
                          );
                        }
                      },
                      child: const Text('Etkinliğe dön →'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

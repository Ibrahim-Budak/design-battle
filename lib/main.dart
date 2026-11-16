import 'package:flutter/material.dart';
import 'app/app.dart';
import 'features/auth/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
  runApp(const DesignBattleApp());
}

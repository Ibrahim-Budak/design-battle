import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../features/home/home_page.dart';
import '../features/admin/admin_page.dart';
import '../features/join/join_page.dart';
import '../features/preview/preview_page.dart';
import '../features/results/results_page.dart';
import '../shared/layout.dart';
import '../features/event/host_page.dart';
import 'theme.dart';

class DesignBattleApp extends StatelessWidget {
  const DesignBattleApp({super.key, this.initialRoute});
  final String? initialRoute;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Design Battle',
    initialRoute: initialRoute,
    debugShowCheckedModeBanner: false,
    theme: battleTheme(),
    locale: const Locale('tr'),
    supportedLocales: const [Locale('tr')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    onGenerateRoute: (settings) {
      final uri = Uri.tryParse(settings.name ?? '/') ?? Uri(path: '/');
      final Widget page = switch (uri.path) {
        '/' => const HomePage(),
        '/admin' => const AdminPage(),
        '/host' => HostPage(eventCode: uri.queryParameters['event']),
        '/join' => JoinPage(eventCode: uri.queryParameters['event']),
        '/preview' => PreviewPage(eventCode: uri.queryParameters['event']),
        '/results' => ResultsPage(eventCode: uri.queryParameters['event']),
        _ => const UnknownPage(),
      };
      return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
    },
  );
}

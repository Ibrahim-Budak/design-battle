import 'package:flutter/material.dart';
import '../app/theme.dart';

class BattleShell extends StatelessWidget {
  final Widget child;
  final String section;
  const BattleShell({super.key, required this.child, required this.section});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              color: BattleColors.paper,
              border: Border(bottom: BorderSide(color: BattleColors.line)),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (_) => false,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BrandMark(),
                      SizedBox(width: 10),
                      Text(
                        'design battle',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.7,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    section.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: BattleColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    ),
  );
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 35,
    height: 35,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: BattleColors.ink,
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Text(
      '✳',
      style: TextStyle(fontSize: 23, color: BattleColors.lime, height: 1),
    ),
  );
}

class Eyebrow extends StatelessWidget {
  final String text;
  const Eyebrow(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.8,
      color: BattleColors.muted,
    ),
  );
}

class Panel extends StatelessWidget {
  final Widget child;
  final Color color;
  const Panel({super.key, required this.child, this.color = Colors.white});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: BattleColors.line),
      borderRadius: BorderRadius.circular(22),
    ),
    child: child,
  );
}

class StatusPill extends StatelessWidget {
  final String text;
  const StatusPill(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xffeef0e7),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: BattleColors.ink,
      ),
    ),
  );
}

class UnknownPage extends StatelessWidget {
  const UnknownPage({super.key});
  @override
  Widget build(BuildContext context) => BattleShell(
    section: 'Sayfa bulunamadı',
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Bu sayfa bulunamadı.'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
            child: const Text('Ana sayfaya dön'),
          ),
        ],
      ),
    ),
  );
}

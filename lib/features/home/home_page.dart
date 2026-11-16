import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../shared/layout.dart';
import '../preview/food_preview.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => BattleShell(
    section: 'Birlikte tasarlama deneyimi',
    child: SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 760;
                final intro = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StatusPill('✳  BİRLİKTE DAHA İYİ'),
                    const SizedBox(height: 30),
                    Text(
                      'Bir sınıf.\nOn karar.\nTek tasarım.',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontSize: wide ? 58 : 42),
                    ),
                    const SizedBox(height: 22),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 450),
                      child: Text(
                        'Fikirlerinizi oylayın, tasarımın nasıl şekillendiğini görün. Bir yemek uygulamasını birlikte hayata geçirin.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: BattleColors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/admin'),
                          icon: const Icon(Icons.arrow_outward, size: 18),
                          label: const Text('Yönetici alanı'),
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/preview'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(48, 50),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            side: const BorderSide(color: BattleColors.line),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: const Text('Örnek önizlemeyi aç'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 38),
                    const Wrap(
                      spacing: 20,
                      runSpacing: 12,
                      children: [
                        InfoBit('01', 'QR ile katılım'),
                        InfoBit('02', '10 tasarım kararı'),
                        InfoBit('03', 'Birlikte karşılaştır'),
                      ],
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Yerel tasarım stüdyosu · Etkinlik ve oylama henüz etkin değil.',
                      style: TextStyle(color: BattleColors.muted, fontSize: 12),
                    ),
                  ],
                );
                final visual = Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffe9eddd),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Column(
                    children: [
                      Eyebrow('YEREL ÖRNEK · YEMEK UYGULAMASI'),
                      SizedBox(height: 22),
                      PhonePreview(),
                      SizedBox(height: 18),
                      Text(
                        'Fikirler, ekranda hayat bulur.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: BattleColors.muted,
                        ),
                      ),
                    ],
                  ),
                );
                return wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 5, child: intro),
                          const SizedBox(width: 48),
                          Expanded(flex: 4, child: visual),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [intro, const SizedBox(height: 40), visual],
                      );
              },
            ),
          ),
        ),
      ),
    ),
  );
}

class InfoBit extends StatelessWidget {
  final String number, label;
  const InfoBit(this.number, this.label, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        number,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: BattleColors.muted),
      ),
    ],
  );
}

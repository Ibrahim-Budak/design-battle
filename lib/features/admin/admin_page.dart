import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../shared/layout.dart';
import '../preview/domain/design_config.dart';
import '../preview/food_preview.dart';
import '../auth/admin_auth_panel.dart';
import '../event/admin_event_panel.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  DesignConfig config = DesignConfig.demo();
  @override
  Widget build(BuildContext context) => BattleShell(
    section: 'Yönetici / tasarım stüdyosu',
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 830;
              final editor = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('TASARIM STÜDYOSU / YEREL DENEME'),
                  const SizedBox(height: 10),
                  Text(
                    'Birlikte daha iyi tasarlayın.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '10 kararın etkisini keşfedin. Değişiklikler yalnızca bu tarayıcıdaki geçici önizlemeye uygulanır.',
                  ),
                  const SizedBox(height: 20),
                  const Panel(
                    color: Color(0xffecf2db),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Yerel tasarım stüdyosu',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tasarım stüdyosundaki seçimler etkinlik oylarından bağımsızdır.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: BattleColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AdminAuthPanel(),
                  const AdminEventPanel(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: Eyebrow('10 TASARIM KARARI')),
                      TextButton(
                        onPressed: () =>
                            setState(() => config = DesignConfig.demo()),
                        child: const Text('Varsayılana dön'),
                      ),
                    ],
                  ),
                  for (var i = 0; i < 10; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Panel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${(i + 1).toString().padLeft(2, '0')} / 10',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: BattleColors.muted,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              DesignConfig.questions[i],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 7,
                              runSpacing: 4,
                              children: [
                                for (var j = 0; j < 3; j++)
                                  ChoiceChip(
                                    label: Text(
                                      '${String.fromCharCode(65 + j)} · ${DesignConfig.labels[i][j]}',
                                    ),
                                    selected: config.selectedOption(i) == j,
                                    onSelected: (_) => setState(
                                      () => config = config.choose(i, j),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DesignConfig.optionDescriptions[i][config
                                  .selectedOption(i)],
                              style: const TextStyle(
                                fontSize: 12,
                                color: BattleColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Wrap(
                    spacing: 16,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/join'),
                        child: const Text('Katılımcı ekranı →'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/results'),
                        child: const Text('Sonuç ekranı →'),
                      ),
                    ],
                  ),
                ],
              );
              final preview = Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffe8eddf),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    const Eyebrow('YEREL ÖRNEK ÖNİZLEME'),
                    const SizedBox(height: 18),
                    PhonePreview(config: config),
                    const SizedBox(height: 18),
                    const Text(
                      'Deneme · Canlı etkinliğe bağlı değil',
                      style: TextStyle(fontSize: 11, color: BattleColors.muted),
                    ),
                  ],
                ),
              );
              return wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: SingleChildScrollView(child: editor),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 4,
                          child: SingleChildScrollView(child: preview),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [preview, const SizedBox(height: 24), editor],
                      ),
                    );
            },
          ),
        ),
      ),
    ),
  );
}

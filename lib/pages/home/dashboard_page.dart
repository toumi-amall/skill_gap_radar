import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/offers_store.dart';
import '../../data/skills_store.dart';
import '../../theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: Listenable.merge([mySkills, offers]),
      builder: (context, _) {
        final skills = mySkills.value;
        final list = offers.value;
        final avg = averageScore(list, skills);
        final missing = topMissing(list, skills);
        final color = AppColors.scoreColor(avg.toDouble());

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Dashboard', style: text.headlineLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'How your skills match the saved offers.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),

            // average score
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AVERAGE MATCH', style: text.labelSmall),
                    Text('$avg%', style: AppText.score(color)),
                    Text(
                      'across ${list.length} offers',
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: avg / 100,
                        minHeight: 8,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // radar: you vs market demand
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SKILL RADAR', style: text.labelSmall),
                    const SizedBox(height: AppSpacing.md),
                    _MarketRadar(skills: skills, list: list),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // top missing skills
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOP MISSING SKILLS', style: text.labelSmall),
                    const SizedBox(height: AppSpacing.md),
                    if (missing.isEmpty)
                      Text(
                        'You cover every skill in your saved offers.',
                        style: text.bodyMedium,
                      )
                    else
                      for (final m in missing.take(4))
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(m.key, style: text.titleMedium),
                                  ),
                                  Text(
                                    '${m.value}/${list.length} offers',
                                    style: text.bodySmall?.copyWith(
                                      color: AppColors.amber,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                                child: LinearProgressIndicator(
                                  value: m.value / list.length,
                                  minHeight: 6,
                                  color: AppColors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // offers with their score
            Text('Saved offers', style: text.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            for (final o in list)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Card(
                  child: ListTile(
                    title: Text(o.title, style: text.titleMedium),
                    subtitle: Text(o.company, style: text.bodySmall),
                    trailing: Text(
                      '${matchScore(o, skills)}%',
                      style: text.titleMedium?.copyWith(
                        color: AppColors.scoreColor(
                          matchScore(o, skills).toDouble(),
                        ),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MarketRadar extends StatelessWidget {
  final List<String> skills;
  final List<Offer> list;
  const _MarketRadar({required this.skills, required this.list});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final top =
        (demand(list).entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .take(6)
            .toList();

    if (top.length < 3) {
      return Text('Add more offers to see the radar.', style: text.bodyMedium);
    }

    final market = [
      for (final e in top) RadarEntry(value: e.value * 100 / list.length),
    ];
    final you = [
      for (final e in top) RadarEntry(value: hasSkill(skills, e.key) ? 100 : 0),
    ];

    return Column(
      children: [
        SizedBox(
          height: 260,
          child: RadarChart(
            RadarChartData(
              radarShape: RadarShape.polygon,
              radarBackgroundColor: Colors.transparent,
              tickCount: 4,
              ticksTextStyle: const TextStyle(
                color: Colors.transparent,
                fontSize: 0,
              ),
              tickBorderData: const BorderSide(color: RadarChartColors.grid),
              gridBorderData: const BorderSide(color: RadarChartColors.grid),
              radarBorderData: const BorderSide(color: RadarChartColors.grid),
              titleTextStyle: text.bodySmall ?? const TextStyle(),
              getTitle: (i, angle) => RadarChartTitle(text: top[i].key),
              dataSets: [
                RadarDataSet(
                  fillColor: RadarChartColors.offerFill,
                  borderColor: RadarChartColors.offerStroke,
                  entryRadius: 3,
                  borderWidth: 2,
                  dataEntries: market,
                ),
                RadarDataSet(
                  fillColor: RadarChartColors.userFill,
                  borderColor: RadarChartColors.userStroke,
                  entryRadius: 3,
                  borderWidth: 2,
                  dataEntries: you,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Dot(color: RadarChartColors.userStroke, label: 'You'),
            const SizedBox(width: AppSpacing.lg),
            _Dot(color: RadarChartColors.offerStroke, label: 'Market demand'),
          ],
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: AppSpacing.xs),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

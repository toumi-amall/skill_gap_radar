// lib/pages/stats/stats_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/offers_store.dart';
import '../../data/skills_store.dart';
import '../../data/stats_store.dart';
import '../../theme/app_theme.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: Listenable.merge([mySkills, offers, scoreHistory]),
      builder: (context, _) {
        final skills = mySkills.value;
        final list = offers.value;
        final history = scoreHistory.value;

        final d = demand(list);
        final top =
            (d.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
                .take(6)
                .toList();
        final covered = d.keys.where((s) => hasSkill(skills, s)).length;
        final coverage = d.isEmpty ? 0 : (covered * 100 / d.length).round();

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Statistics', style: text.headlineLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'What the market asks for, and how you progress.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),

            Row(
              children: [
                Expanded(
                  child: _Kpi(label: 'Offers', value: '${list.length}'),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _Kpi(label: 'Skills', value: '${skills.length}'),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _Kpi(label: 'Coverage', value: '$coverage%'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MOST DEMANDED SKILLS', style: text.labelSmall),
                    const SizedBox(height: AppSpacing.md),
                    if (top.isEmpty)
                      Text(
                        'Save an offer to see the demand.',
                        style: text.bodyMedium,
                      )
                    else ...[
                      _DemandChart(top: top, skills: skills),
                      const SizedBox(height: AppSpacing.md),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _Legend(
                            color: RadarChartColors.userStroke,
                            label: 'You have it',
                          ),
                          SizedBox(width: AppSpacing.lg),
                          _Legend(color: AppColors.amber, label: 'Missing'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROGRESS OVER TIME', style: text.labelSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Average match, after each change.',
                      style: text.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (history.length < 2)
                      Text(
                        'Add skills or save offers: the curve appears after a few changes.',
                        style: text.bodyMedium,
                      )
                    else
                      _ProgressChart(history: history),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Kpi extends StatelessWidget {
  final String label;
  final String value;
  const _Kpi({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: text.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemandChart extends StatelessWidget {
  final List<MapEntry<String, int>> top;
  final List<String> skills;
  const _DemandChart({required this.top, required this.skills});

  @override
  Widget build(BuildContext context) {
    final label = Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10);
    final maxCount = top.first.value;

    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          maxY: maxCount + 1.0,
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: RadarChartColors.grid, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text('${value.toInt()}', style: label),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= top.length) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    angle: -0.6,
                    space: 10,
                    child: Text(top[i].key, style: label),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < top.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: top[i].value.toDouble(),
                    width: 18,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    color: hasSkill(skills, top[i].key)
                        ? RadarChartColors.userStroke
                        : AppColors.amber,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressChart extends StatelessWidget {
  final List<int> history;
  const _ProgressChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final label = Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          minX: 0,
          maxX: (history.length - 1).toDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: RadarChartColors.grid, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: 25,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text('${value.toInt()}%', style: label),
                ),
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < history.length; i++)
                  FlSpot(i.toDouble(), history[i].toDouble()),
              ],
              isCurved: true,
              preventCurveOverShooting: true,
              color: RadarChartColors.userStroke,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: RadarChartColors.userFill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

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

// lib/pages/learn/learning_path_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/offers_store.dart';
import '../../data/skills_store.dart';
import '../../theme/app_theme.dart';

/// Official learning pages for the most common skills.
const _docs = {
  'Flutter': 'https://docs.flutter.dev',
  'Dart': 'https://dart.dev/language',
  'Python': 'https://docs.python.org/3/tutorial/',
  'SQL': 'https://www.w3schools.com/sql/',
  'Power BI': 'https://learn.microsoft.com/en-us/power-bi/',
  'Node.js': 'https://nodejs.org/en/learn',
  'React': 'https://react.dev/learn',
  'Git': 'https://git-scm.com/book',
  'Docker': 'https://docs.docker.com/get-started/',
  'Django': 'https://docs.djangoproject.com',
  'MongoDB': 'https://learn.mongodb.com',
};

Uri _videos(String skill) => Uri.https('www.youtube.com', '/results', {
  'search_query': '$skill tutorial for beginners',
});

class LearningPathPage extends StatelessWidget {
  const LearningPathPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Learning path')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([mySkills, offers]),
          builder: (context, _) {
            final skills = mySkills.value;
            final list = offers.value;
            final d = demand(list);
            final missing = topMissing(list, skills);
            final covered = d.length - missing.length;
            final coverage = d.isEmpty ? 0.0 : covered / d.length;

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text('Close the gap', style: text.headlineMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Learn what the offers ask for most. Tap "I learned it" once you can use a skill.',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PROGRESS', style: text.labelSmall),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '$covered of ${d.length} demanded skills covered',
                          style: text.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: LinearProgressIndicator(
                            value: coverage,
                            minHeight: 8,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                if (missing.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(
                        'Nothing missing. You cover every skill in your saved offers.',
                        style: text.bodyMedium,
                      ),
                    ),
                  )
                else
                  for (final m in missing)
                    _SkillStep(name: m.key, count: m.value, total: list.length),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SkillStep extends StatelessWidget {
  final String name;
  final int count;
  final int total;
  const _SkillStep({
    required this.name,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final docs = _docs[name];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(name, style: text.titleMedium)),
                  Text(
                    '$count/$total offers',
                    style: text.bodySmall?.copyWith(color: AppColors.amber),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (docs != null)
                    OutlinedButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse(docs),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.menu_book_outlined, size: 18),
                      label: const Text('Official docs'),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      _videos(name),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.play_circle_outline, size: 18),
                    label: const Text('Video tutorials'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.tonalIcon(
                onPressed: () {
                  addSkill(name, 1);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '$name added as Beginner. Raise its level in My skills as you progress.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('I learned it'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

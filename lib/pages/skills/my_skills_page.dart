// lib/pages/skills/my_skills_page.dart
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../data/skills_store.dart';

const _suggestions = [
  'Flutter',
  'Dart',
  'Python',
  'SQL',
  'Power BI',
  'Node.js',
  'React',
  'Git',
  'Docker',
  'Django',
];

class MySkillsPage extends StatefulWidget {
  const MySkillsPage({super.key});

  @override
  State<MySkillsPage> createState() => _MySkillsPageState();
}

class _MySkillsPageState extends State<MySkillsPage> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _add() {
    addSkill(_ctrl.text);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My skills')),
      body: SafeArea(
        child: ValueListenableBuilder<List<String>>(
          valueListenable: mySkills,
          builder: (_, skills, __) {
            final available = _suggestions
                .where(
                  (s) => !skills.any((m) => m.toLowerCase() == s.toLowerCase()),
                )
                .toList();

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text('What can you do?', style: text.headlineMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Add your skills. We compare them with each job offer.',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Input + add button
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) => _add(),
                        decoration: const InputDecoration(
                          labelText: 'Add a skill',
                          prefixIcon: Icon(Icons.add_circle_outline),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton.filled(
                      tooltip: 'Add',
                      onPressed: _add,
                      icon: const Icon(Icons.check),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // My skills
                Text('Your skills (${skills.length})', style: text.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                if (skills.isEmpty)
                  Text(
                    'No skills yet. Add one above or tap a suggestion.',
                    style: text.bodyMedium,
                  )
                else
                  Column(
                    children: [for (final s in skills) _SkillTile(name: s)],
                  ),
                const SizedBox(height: AppSpacing.lg),

                // Suggestions
                if (available.isNotEmpty) ...[
                  Text('Suggestions', style: text.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final s in available)
                        ActionChip(
                          label: Text(s),
                          avatar: const Icon(Icons.add, size: 16),
                          onPressed: () => addSkill(s),
                        ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SkillTile extends StatelessWidget {
  const _SkillTile({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(name, style: text.titleMedium)),
                  IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.close),
                    onPressed: () => removeSkill(name),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: SegmentedButton<int>(
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  segments: const [
                    ButtonSegment(value: 1, label: Text('Beginner')),
                    ButtonSegment(value: 2, label: Text('Intermediate')),
                    ButtonSegment(value: 3, label: Text('Advanced')),
                  ],
                  selected: {levelOf(name)},
                  onSelectionChanged: (s) => setSkillLevel(name, s.first),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

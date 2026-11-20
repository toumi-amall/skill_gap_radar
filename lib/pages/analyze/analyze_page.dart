// lib/pages/analyze/analyze_page.dart
import 'package:flutter/material.dart';

import '../../data/offers_store.dart';
import '../../data/skills_store.dart';
import '../../theme/app_theme.dart';

class AnalyzePage extends StatefulWidget {
  const AnalyzePage({super.key});

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  final _title = TextEditingController();
  final _company = TextEditingController();
  final _text = TextEditingController();
  Offer? _result;
  bool _nothingFound = false;

  @override
  void dispose() {
    _title.dispose();
    _company.dispose();
    _text.dispose();
    super.dispose();
  }

  void _analyze() {
    final required = extractSkills(_text.text);
    setState(() {
      _nothingFound = required.isEmpty && _text.text.trim().isNotEmpty;
      _result = required.isEmpty
          ? null
          : Offer(
              _title.text.trim().isEmpty
                  ? 'Untitled offer'
                  : _title.text.trim(),
              _company.text.trim().isEmpty
                  ? 'Unknown company'
                  : _company.text.trim(),
              required,
            );
    });
  }

  void _save() {
    final r = _result;
    if (r == null) return;
    addOffer(r);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Offer saved to your dashboard')),
    );
    _title.clear();
    _company.clear();
    _text.clear();
    setState(() => _result = null);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Analyze an offer', style: text.headlineLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Paste a job offer and compare it with your skills.',
          style: text.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _title,
          decoration: const InputDecoration(labelText: 'Job title'),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _company,
          decoration: const InputDecoration(labelText: 'Company'),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _text,
          minLines: 6,
          maxLines: 10,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            labelText: 'Offer text',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: _analyze,
          icon: const Icon(Icons.radar),
          label: const Text('Analyze'),
        ),
        if (_nothingFound) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No known skills found in this text. Try pasting the full offer.',
            style: text.bodyMedium,
          ),
        ],
        if (_result != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _ResultCard(offer: _result!, onSave: _save),
        ],
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Offer offer;
  final VoidCallback onSave;
  const _ResultCard({required this.offer, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ValueListenableBuilder<List<String>>(
      valueListenable: mySkills,
      builder: (_, skills, _) {
        final score = matchScore(offer, skills);
        final color = AppColors.scoreColor(score.toDouble());
        final matched = offer.required.where((s) => hasSkill(skills, s));
        final missing = offer.required.where((s) => !hasSkill(skills, s));

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer.title, style: text.titleMedium),
                Text(offer.company, style: text.bodySmall),
                const SizedBox(height: AppSpacing.md),
                Text('$score%', style: AppText.score(color)),
                Text('match with your skills', style: text.bodyMedium),
                const SizedBox(height: AppSpacing.lg),
                Text('YOU HAVE', style: text.labelSmall),
                const SizedBox(height: AppSpacing.sm),
                if (matched.isEmpty)
                  Text(
                    'None of the required skills yet.',
                    style: text.bodyMedium,
                  )
                else
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final s in matched)
                        Chip(
                          label: Text(s),
                          avatar: const Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.success,
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: AppSpacing.lg),
                Text('MISSING', style: text.labelSmall),
                const SizedBox(height: AppSpacing.sm),
                if (missing.isEmpty)
                  Text(
                    'You cover every required skill.',
                    style: text.bodyMedium,
                  )
                else
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final s in missing)
                        Chip(
                          label: Text(s),
                          avatar: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.amber,
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Save offer'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

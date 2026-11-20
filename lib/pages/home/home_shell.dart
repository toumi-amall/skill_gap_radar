import 'package:flutter/material.dart';

import '../../data/skills_store.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_controller.dart';
import '../analyze/analyze_page.dart';
import '../skills/my_skills_page.dart';
import '../welcome/welcome_page.dart';
import 'dashboard_page.dart';

class HomeShell extends StatefulWidget {
  final bool isGuest;
  const HomeShell({super.key, this.isGuest = false});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(onAnalyze: () => setState(() => _index = 2)),
      const DashboardPage(),
      const AnalyzePage(),
      _ProfileTab(isGuest: widget.isGuest),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.radar_outlined),
            selectedIcon: Icon(Icons.radar),
            label: 'Analyze',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final VoidCallback onAnalyze;
  const _HomeTab({required this.onAnalyze});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ValueListenableBuilder<List<String>>(
      valueListenable: mySkills,
      builder: (_, skills, _) {
        final skillCount = skills.length;
        final ready = skillCount >= 2;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Welcome back', style: text.headlineLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              ready
                  ? 'Your profile is ready for the next analysis.'
                  : 'Add a few skills to start your profile.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),

            // summary card
            _StatCard(
              title: 'Skills',
              value: '$skillCount',
              color: AppColors.radarDeep,
            ),
            const SizedBox(height: AppSpacing.lg),

            // skill list
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My skills', style: text.titleMedium),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MySkillsPage()),
                    );
                  },
                  child: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            if (skills.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'No skills yet. Add your skills to improve your score.',
                    style: text.bodyMedium,
                  ),
                ),
              )
            else
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final skill in skills)
                    Chip(
                      label: Text(skill),
                      avatar: const Icon(Icons.check, size: 16),
                    ),
                ],
              ),
            const SizedBox(height: AppSpacing.lg),

            // quick actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick actions', style: text.titleMedium),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MySkillsPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.psychology_outlined),
                            label: const Text('Add skills'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onAnalyze,
                            icon: const Icon(Icons.radar_outlined),
                            label: const Text('Analyze'),
                          ),
                        ),
                      ],
                    ),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: text.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final bool isGuest;
  const _ProfileTab({required this.isGuest});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Profile', style: text.headlineLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          isGuest
              ? 'You are using the app as a guest. Your data stays on this device.'
              : 'You are logged in.',
          style: text.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        Card(
          child: ListTile(
            leading: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            title: Text(
              isDark ? 'Switch to light mode' : 'Switch to dark mode',
            ),
            onTap: toggleThemeMode,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: ListTile(
            leading: const Icon(Icons.psychology_outlined),
            title: const Text('My skills'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MySkillsPage()),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const WelcomePage()),
              (route) => false,
            );
          },
          child: Text(isGuest ? 'Back to welcome' : 'Log out'),
        ),
      ],
    );
  }
}

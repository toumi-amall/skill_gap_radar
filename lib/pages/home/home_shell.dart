// lib/pages/home/home_shell.dart
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/theme_controller.dart';
import '../welcome/welcome_page.dart';

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
      const _HomeTab(),
      const _PlaceholderTab(
        icon: Icons.radar,
        title: 'Analyze a job offer',
        subtitle: 'Paste an offer here and compare it with your skills.',
      ),
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

// ---------------------------------------------------------------
// Tabs (placeholders, we will replace them one by one)
// ---------------------------------------------------------------

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Welcome back', style: text.headlineLarge),
        const SizedBox(height: AppSpacing.sm),
        Text('Your skill gaps will show up here.', style: text.bodyMedium),
        const SizedBox(height: AppSpacing.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Latest match', style: text.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text('No analysis yet. Start from the Analyze tab.',
                    style: text.bodyMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PlaceholderTab({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: text.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(subtitle, style: text.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
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
            title: Text(isDark ? 'Switch to light mode' : 'Switch to dark mode'),
            onTap: toggleThemeMode,
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
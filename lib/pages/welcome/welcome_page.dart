// lib/pages/welcome/welcome_page.dart
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/theme_controller.dart';
import '../../widgets/radar_logo.dart';
import '../auth/login_page.dart';
import '../auth/sign_up_page.dart';

class _Slide {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Slide(this.icon, this.title, this.subtitle);
}

const _slides = [
  _Slide(
    Icons.description_outlined,
    'Paste any job offer',
    'Copy the offer you want and let Skill Gap Radar read it for you.',
  ),
  _Slide(
    Icons.radar,
    'See your skill gaps',
    'Compare the offer with your skills on a radar chart and spot what is missing.',
  ),
  _Slide(
    Icons.school_outlined,
    'Follow your learning path',
    'Get a clear path to close the gaps and land the job.',
  ),
];

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              // Top bar: theme toggle + Skip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: 'Toggle theme',
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                    onPressed: toggleThemeMode,
                  ),
                  TextButton(
                    onPressed: _isLast ? null : () => _goTo(_slides.length - 1),
                    child: const Text('Skip'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const RadarLogo(size: 72),
              const SizedBox(height: AppSpacing.md),

              // Slides
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) {
                    final s = _slides[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Icon(s.icon, size: 80, color: AppColors.ink),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          s.title,
                          textAlign: TextAlign.center,
                          style: text.headlineLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          s.subtitle,
                          textAlign: TextAlign.center,
                          style: text.bodyMedium,
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Main button
              ElevatedButton(
                onPressed: () {
                  if (_isLast) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                    );
                  } else {
                    _goTo(_index + 1);
                  }
                },
                child: Text(_isLast ? 'Get started' : 'Next'),
              ),
              const SizedBox(height: AppSpacing.md),

              // Login link
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text('I already have an account'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
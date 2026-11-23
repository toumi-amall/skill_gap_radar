import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/auth_store.dart';
import 'data/session.dart';
import 'data/stats_store.dart';
import 'pages/home/home_shell.dart';
import 'pages/welcome/welcome_page.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await loadSession();
    if (isLoggedIn) await loadAllData();
  } catch (e) {
    debugPrint('Startup error: $e');
  }
  startTracking();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const SkillGapRadarApp());
}

class SkillGapRadarApp extends StatelessWidget {
  const SkillGapRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (_, mode, _) {
        SystemChrome.setSystemUIOverlayStyle(
          mode == ThemeMode.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
        );

        return MaterialApp(
          title: 'Skill Gap Radar',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: isLoggedIn ? const HomeShell() : const WelcomePage(),
        );
      },
    );
  }
}

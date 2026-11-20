import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/offers_store.dart';
import 'data/skills_store.dart';
import 'pages/welcome/welcome_page.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSkills();
  await loadOffers();
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
          home: const WelcomePage(),
        );
      },
    );
  }
}

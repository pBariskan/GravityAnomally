import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/main_menu_screen.dart';
import 'services/achievement_service.dart';
import 'services/persistence_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final persistence = PersistenceService();
  final achievements = AchievementService(persistence);
  await achievements.load();

  runApp(StrainApp(achievementService: achievements));
}

class StrainApp extends StatelessWidget {
  const StrainApp({super.key, required this.achievementService});

  final AchievementService achievementService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strain',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: MainMenuScreen(achievementService: achievementService),
    );
  }
}

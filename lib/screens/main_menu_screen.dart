import 'package:flutter/material.dart';

import '../models/challenge_mode.dart';
import '../services/achievement_service.dart';
import '../theme/world_theme.dart';
import 'codex_screen.dart';
import 'game_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key, required this.achievementService});

  final AchievementService achievementService;

  @override
  Widget build(BuildContext context) {
    final stats = achievementService.stats;
    final world = stats.currentWorld;
    final theme = WorldThemeData.forWorld(world);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'STRAIN',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 12,
                      color: theme.primary,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Peak Strain: ${stats.peakStrain.displayName}',
                    style: TextStyle(color: theme.text.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current World: ${world.displayName}',
                    style: TextStyle(color: theme.text.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 40),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.buttonFill,
                      foregroundColor: theme.background,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () => _startGame(context, ChallengeMode.none),
                    child: const Text('START / CONTINUE'),
                  ),
                  if (_hasChallenges()) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Challenge Modes',
                      style: TextStyle(color: theme.secondary, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children: ChallengeMode.values
                          .where((c) => c != ChallengeMode.none)
                          .where(
                            (c) => achievementService.isChallengeUnlocked(c),
                          )
                          .map(
                            (c) => OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.accent,
                                side: BorderSide(color: theme.primary),
                              ),
                              onPressed: () => _startGame(context, c),
                              child: Text(c.displayName),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(Icons.menu_book, color: theme.accent),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CodexScreen(
                        achievementService: achievementService,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasChallenges() => ChallengeMode.values
      .where((c) => c != ChallengeMode.none)
      .any(achievementService.isChallengeUnlocked);

  void _startGame(BuildContext context, ChallengeMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          achievementService: achievementService,
          challenge: mode,
        ),
      ),
    );
  }
}

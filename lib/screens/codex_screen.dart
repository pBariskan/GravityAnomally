import 'package:flutter/material.dart';

import '../models/achievement_id.dart';
import '../services/achievement_service.dart';
import '../theme/world_theme.dart';
import '../models/world_id.dart';

class CodexScreen extends StatelessWidget {
  const CodexScreen({super.key, required this.achievementService});

  final AchievementService achievementService;

  @override
  Widget build(BuildContext context) {
    final theme = WorldThemeData.forWorld(WorldId.microverse);

    return Scaffold(
      backgroundColor: const Color(0xFFF4E8D0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C4033),
        foregroundColor: const Color(0xFFF4E8D0),
        title: const Text(
          'Field Codex',
          style: TextStyle(fontFamily: 'serif', letterSpacing: 2),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: AchievementId.values.map((id) {
          final unlocked = achievementService.isUnlocked(id);
          return Card(
            color: const Color(0xFFFFF8E7),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unlocked ? id.codexTitle : '████████ ████████',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: unlocked
                          ? const Color(0xFF3E2723)
                          : const Color(0xFF9E9E9E),
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    unlocked ? id.codexObservation : id.redactedHint,
                    style: TextStyle(
                      color: unlocked
                          ? const Color(0xFF5D4037)
                          : const Color(0xFFBDBDBD),
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                  if (unlocked)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '— Dr. Strain, ${DateTime.now().year}',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

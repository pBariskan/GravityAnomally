import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../game/game_controller.dart';
import '../game/strain_painter.dart';
import '../models/challenge_mode.dart';
import '../services/achievement_service.dart';
import '../theme/world_theme.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.achievementService,
    this.challenge = ChallengeMode.none,
  });

  final AchievementService achievementService;
  final ChallengeMode challenge;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  GameController? _controller;
  Ticker? _ticker;
  Duration? _lastTick;

  @override
  void dispose() {
    _ticker?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _initController(Size size) {
    if (_controller != null) return;
    final world = widget.achievementService.stats.currentWorld;
    _controller = GameController(
      world: world,
      challenge: widget.challenge,
      achievementService: widget.achievementService,
      playWidth: size.width,
      playHeight: size.height,
    );
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (_controller == null) return;
    if (_lastTick == null) {
      _lastTick = elapsed;
      return;
    }
    final dt = (elapsed - _lastTick!).inMicroseconds / 1e6;
    _lastTick = elapsed;
    _controller!.update(dt.clamp(0, 1 / 30));
  }

  @override
  Widget build(BuildContext context) {
    final world = widget.achievementService.stats.currentWorld;
    final theme = WorldThemeData.forWorld(world);

    return Scaffold(
      backgroundColor: theme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          _initController(size);
          final c = _controller!;

          return ListenableBuilder(
            listenable: c,
            builder: (context, _) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: c.flipGravity,
            child: Stack(
              children: [
                CustomPaint(
                  size: size,
                  painter: StrainPainter(controller: c, theme: theme),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: theme.text),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              c.tier.displayName,
                              style: TextStyle(
                                color: theme.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Orbs ${c.collectibles}',
                              style: TextStyle(color: theme.text),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (c.phase == GamePhase.organismCountdown)
                  Center(
                    child: Text(
                      c.organismTimer.ceil().toString(),
                      style: TextStyle(
                        fontSize: 64,
                        color: theme.accent.withValues(alpha: 0.35),
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                if (c.phase == GamePhase.gameOver ||
                    c.phase == GamePhase.worldCleared)
                  _EndOverlay(
                    controller: c,
                    theme: theme,
                    onDismiss: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),
          );
        },
      ),
    );
  }
}

class _EndOverlay extends StatelessWidget {
  const _EndOverlay({
    required this.controller,
    required this.theme,
    required this.onDismiss,
  });

  final GameController controller;
  final WorldThemeData theme;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final cleared = controller.phase == GamePhase.worldCleared;
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              cleared ? 'WORLD CLEARED' : 'RUN ENDED',
              style: TextStyle(
                color: theme.accent,
                fontSize: 24,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Peak: ${controller.peakTierThisRun.displayName}',
              style: TextStyle(color: theme.text),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onDismiss,
              style: FilledButton.styleFrom(backgroundColor: theme.buttonFill),
              child: const Text('CONTINUE'),
            ),
          ],
        ),
      ),
    );
  }
}

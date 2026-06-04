import 'dart:math';

import 'package:flutter/material.dart';

import '../config/game_config.dart';
import '../models/evolution_tier.dart';
import '../models/world_id.dart';
import '../theme/world_theme.dart';
import 'entities.dart';
import 'game_controller.dart';

class StrainPainter extends CustomPainter {
  StrainPainter({required this.controller, required this.theme})
      : super(repaint: controller);

  final GameController controller;
  final WorldThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final playRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(playRect, Paint()..color = theme.playfield);

    for (final w in controller.walls) {
      _drawWall(canvas, w);
    }

    for (final o in controller.orbs) {
      if (!o.collected) _drawOrb(canvas, o);
    }

    _drawPlayer(canvas);

    if (controller.phase == GamePhase.organismCountdown) {
      _drawCountdownRing(canvas);
    }

    if (controller.world == WorldId.neural && !controller.flipReady) {
      _drawCooldownIndicator(canvas);
    }

    if (controller.isBlindActive) {
      canvas.drawRect(
        playRect,
        Paint()..color = Colors.black.withValues(alpha: 0.92),
      );
    }
  }

  void _drawWall(Canvas canvas, WallSegment w) {
    final paint = Paint()..color = theme.obstacle;
    canvas.drawRect(Rect.fromLTWH(w.x, 0, w.width, w.gapTop), paint);
    canvas.drawRect(
      Rect.fromLTWH(
        w.x,
        w.gapBottom,
        w.width,
        controller.ceilingY - w.gapBottom + 80,
      ),
      paint,
    );
  }

  void _drawOrb(Canvas canvas, CollectibleOrb o) {
    final pulse =
        0.85 + 0.15 * sin(DateTime.now().millisecondsSinceEpoch / 280.0);
    final r = GameConfig.collectibleRadius * pulse;
    final paint = Paint()
      ..color = o.safe
          ? theme.collectible
          : theme.collectible.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(o.x, o.y), r, paint);
    canvas.drawCircle(
      Offset(o.x, o.y),
      r * 0.5,
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );
  }

  void _drawPlayer(Canvas canvas) {
    final r =
        GameConfig.playerRadiusForTier(controller.tier) * controller.morphScale;
    final paint = Paint()..color = theme.player;
    canvas.drawCircle(Offset(controller.playerX, controller.playerY), r, paint);
    canvas.drawCircle(
      Offset(controller.playerX, controller.playerY),
      r * 0.55,
      Paint()..color = theme.accent.withValues(alpha: 0.5),
    );
  }

  void _drawCountdownRing(Canvas canvas) {
    final progress =
        controller.organismTimer / GameConfig.organismSurvivalSeconds;
    final r = GameConfig.playerRadiusForTier(EvolutionTier.organism) + 18;
    final rect = Rect.fromCircle(
      center: Offset(controller.playerX, controller.playerY),
      radius: r,
    );
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = theme.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  void _drawCooldownIndicator(Canvas canvas) {
    final paint = Paint()
      ..color = theme.secondary.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(
      Offset(controller.playerX, controller.playerY),
      GameConfig.playerRadiusForTier(controller.tier) + 6,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant StrainPainter oldDelegate) => true;
}

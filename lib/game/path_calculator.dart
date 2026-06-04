import '../config/game_config.dart';

/// Estimates viable Y positions through an upcoming gap using deterministic physics.
class PathCalculator {
  static List<double> viableYPositions({
    required double floorY,
    required double ceilingY,
    required double gapTop,
    required double gapBottom,
    required double startY,
    required double startVy,
    required double gravitySign,
    required double gravityStrength,
    required double distanceToGap,
    required double forwardSpeed,
    int samples = 12,
  }) {
    final timeToGap = distanceToGap / forwardSpeed;
    final viable = <double>{};
    final margin = GameConfig.pathGapMargin;

    for (var flips = 0; flips <= 2; flips++) {
      final flipTimes = _flipSchedules(timeToGap, flips, samples);
      for (final schedule in flipTimes) {
        final y = _simulateY(
          startY: startY,
          startVy: startVy,
          gravitySign: gravitySign,
          gravityStrength: gravityStrength,
          floorY: floorY,
          ceilingY: ceilingY,
          duration: timeToGap,
          flipTimes: schedule,
        );
        if (y >= gapTop + margin && y <= gapBottom - margin) {
          viable.add(y);
        }
      }
    }

    if (viable.isEmpty) {
      viable.add((gapTop + gapBottom) / 2);
    }
    return viable.toList();
  }

  /// Smallest flip count (0–2) needed from a nominal corridor start to enter the gap.
  static int minFlipsForGap({
    required double floorY,
    required double ceilingY,
    required double gapTop,
    required double gapBottom,
    required double gravityStrength,
    double travelTimeSeconds = 2.0,
    int samples = 12,
  }) {
    final startY = (floorY + ceilingY) / 2;
    final margin = GameConfig.pathGapMargin;
    var worst = 0;

    for (final gravitySign in [-1.0, 1.0]) {
      var minForSign = 3;
      for (var flips = 0; flips <= 2; flips++) {
        final flipTimes = _flipSchedules(travelTimeSeconds, flips, samples);
        var reachable = false;
        for (final schedule in flipTimes) {
          final y = _simulateY(
            startY: startY,
            startVy: 0,
            gravitySign: gravitySign,
            gravityStrength: gravityStrength,
            floorY: floorY,
            ceilingY: ceilingY,
            duration: travelTimeSeconds,
            flipTimes: schedule,
          );
          if (y >= gapTop + margin && y <= gapBottom - margin) {
            reachable = true;
            break;
          }
        }
        if (reachable) {
          minForSign = flips;
          break;
        }
      }
      final required = minForSign == 3 ? 2 : minForSign;
      if (required > worst) worst = required;
    }

    return worst;
  }

  static List<List<double>> _flipSchedules(
    double duration,
    int flipCount,
    int samples,
  ) {
    if (flipCount == 0) return [[]];
    final schedules = <List<double>>[];
    for (var i = 1; i <= samples; i++) {
      final t = duration * i / (samples + 1);
      if (flipCount == 1) {
        schedules.add([t]);
      } else {
        for (var j = i + 1; j <= samples; j++) {
          final t2 = duration * j / (samples + 1);
          schedules.add([t, t2]);
        }
      }
    }
    return schedules.isEmpty ? [[]] : schedules;
  }

  static double _simulateY({
    required double startY,
    required double startVy,
    required double gravitySign,
    required double gravityStrength,
    required double floorY,
    required double ceilingY,
    required double duration,
    required List<double> flipTimes,
    double dt = 1 / 120,
  }) {
    var y = startY;
    var vy = startVy;
    var gSign = gravitySign;
    var t = 0.0;
    var flipIndex = 0;

    while (t < duration) {
      if (flipIndex < flipTimes.length && t >= flipTimes[flipIndex]) {
        gSign = -gSign;
        vy = -gSign * GameConfig.flipVelocity;
        flipIndex++;
      }
      final g = gSign * gravityStrength;
      vy += g * dt;
      y += vy * dt;
      y = y.clamp(floorY + 8, ceilingY - 8);
      t += dt;
    }
    return y;
  }

  static double safeSpawnRatio({
    required double runProgress,
    required int worldIndex,
  }) {
    final worldFactor = worldIndex * 0.02;
    final progress = runProgress.clamp(0.0, 1.0);
    final early = GameConfig.earlySafeSpawnRatio;
    final late = GameConfig.lateSafeSpawnRatio;
    return early + (late - early) * progress + worldFactor;
  }
}

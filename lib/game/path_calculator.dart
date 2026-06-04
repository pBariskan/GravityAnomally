import '../config/game_config.dart';

/// Estimates viable Y positions through an upcoming gap using deterministic physics.
class PathCalculator {
  static List<double> viableYPositions({
    required double playHeight,
    required double floorY,
    required double ceilingY,
    required double gapTop,
    required double gapBottom,
    required double startY,
    required double startVy,
    required double gravitySigned,
    required double distanceToGap,
    required double forwardSpeed,
    int samples = 12,
  }) {
    final timeToGap = distanceToGap / forwardSpeed;
    final viable = <double>{};

    for (var flips = 0; flips <= 2; flips++) {
      final flipTimes = _flipSchedules(timeToGap, flips, samples);
      for (final schedule in flipTimes) {
        final y = _simulateY(
          startY: startY,
          startVy: startVy,
          gravitySigned: gravitySigned,
          floorY: floorY,
          ceilingY: ceilingY,
          duration: timeToGap,
          flipTimes: schedule,
        );
        if (y >= gapTop + 12 && y <= gapBottom - 12) {
          viable.add(y);
        }
      }
    }

    if (viable.isEmpty) {
      viable.add((gapTop + gapBottom) / 2);
    }
    return viable.toList();
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
    required double gravitySigned,
    required double floorY,
    required double ceilingY,
    required double duration,
    required List<double> flipTimes,
    double dt = 1 / 120,
  }) {
    var y = startY;
    var vy = startVy;
    var g = gravitySigned;
    var t = 0.0;
    var flipIndex = 0;

    while (t < duration) {
      if (flipIndex < flipTimes.length && t >= flipTimes[flipIndex]) {
        g = -g;
        vy = -vy;
        flipIndex++;
      }
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

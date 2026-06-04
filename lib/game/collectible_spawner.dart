import 'dart:math';

import '../config/game_config.dart';
import 'entities.dart';
import 'path_calculator.dart';
class CollectibleSpawner {
  CollectibleSpawner(this._rng);

  final Random _rng;

  CollectibleOrb? maybeSpawn({
    required WallSegment wall,
    required WallSegment? nextWall,
    required double playerX,
    required double playerY,
    required double playerVy,
    required double gravitySigned,
    required double forwardSpeed,
    required double floorY,
    required double ceilingY,
    required double runProgress,
    required int worldIndex,
    required Set<double> usedY,
  }) {
    if (_rng.nextDouble() > 0.55) return null;

    final distance = wall.x - playerX;
    if (distance < 80 || distance > 520) return null;

    final viable = PathCalculator.viableYPositions(
      playHeight: ceilingY - floorY,
      floorY: floorY,
      ceilingY: ceilingY,
      gapTop: wall.gapTop,
      gapBottom: wall.gapBottom,
      startY: playerY,
      startVy: playerVy,
      gravitySigned: gravitySigned,
      distanceToGap: distance,
      forwardSpeed: forwardSpeed,
    );

    final safeRatio = PathCalculator.safeSpawnRatio(
      runProgress: runProgress,
      worldIndex: worldIndex,
    );
    final placeSafe = _rng.nextDouble() < safeRatio;

    double y;
    double x = wall.x - GameConfig.wallWidth * 0.8;

    if (placeSafe && viable.isNotEmpty) {
      y = viable[_rng.nextInt(viable.length)];
    } else {
      // Temptation: off-path or greedy break
      if (_rng.nextBool()) {
        y = _rng.nextBool() ? wall.gapTop - 28 : wall.gapBottom + 28;
      } else {
        y = floorY + _rng.nextDouble() * (ceilingY - floorY);
      }
      x -= 30;
    }

    y = y.clamp(floorY + 16, ceilingY - 16);
    if (usedY.any((uy) => (uy - y).abs() < 24)) return null;
    usedY.add(y);

    return CollectibleOrb(x: x, y: y, safe: placeSafe);
  }
}

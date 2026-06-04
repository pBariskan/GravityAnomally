import '../config/game_config.dart';
import '../models/world_id.dart';
import 'path_calculator.dart';

/// Couples forward speed and wall spacing from run progress and physics feasibility.
class DifficultyCurve {
  DifficultyCurve._();

  static double forwardSpeed(double runProgress, {double speedMultiplier = 1}) {
    return GameConfig.forwardSpeedForProgress(runProgress) * speedMultiplier;
  }

  static double minFlipPeriodSeconds(WorldId world) {
    return GameConfig.minFlipPeriodSeconds(GameConfig.gravityForWorld(world));
  }

  static ({double gapTop, double gapBottom}) nominalGapBounds({
    required double floorY,
    required double ceilingY,
    required WorldId world,
    double viralShrink = 0,
  }) {
    final gapH = GameConfig.gapHeightForWorld(world, viralShrink: viralShrink);
    final center = (floorY + ceilingY) / 2;
    return (gapTop: center - gapH / 2, gapBottom: center + gapH / 2);
  }

  static int minFlipsForWorld({
    required WorldId world,
    required double floorY,
    required double ceilingY,
    double viralShrink = 0,
  }) {
    final gap = nominalGapBounds(
      floorY: floorY,
      ceilingY: ceilingY,
      world: world,
      viralShrink: viralShrink,
    );
    return PathCalculator.minFlipsForGap(
      floorY: floorY,
      ceilingY: ceilingY,
      gapTop: gap.gapTop,
      gapBottom: gap.gapBottom,
      gravityStrength: GameConfig.gravityForWorld(world),
    );
  }

  /// Minimum center-to-center spacing (px) so `n_min` flips fit in the travel window.
  static double minSpacingPx({
    required double speed,
    required WorldId world,
    required double floorY,
    required double ceilingY,
    double viralShrink = 0,
  }) {
    final nMin = minFlipsForWorld(
      world: world,
      floorY: floorY,
      ceilingY: ceilingY,
      viralShrink: viralShrink,
    );
    final tau = minFlipPeriodSeconds(world);
    final minSeconds = nMin * tau + GameConfig.flipTimingSlackSeconds;
    return speed * minSeconds;
  }

  /// Desired spacing from pacing interval at this progress.
  static double desiredSpacingPx({
    required double runProgress,
    required double speed,
  }) {
    final interval = GameConfig.wallSpawnIntervalForProgress(runProgress);
    return speed * interval;
  }

  /// Actual spacing: never tighter than physics floor.
  static double wallSpacing({
    required double runProgress,
    required double speed,
    required WorldId world,
    required double floorY,
    required double ceilingY,
    double viralShrink = 0,
  }) {
    final desired = desiredSpacingPx(runProgress: runProgress, speed: speed);
    final minPx = minSpacingPx(
      speed: speed,
      world: world,
      floorY: floorY,
      ceilingY: ceilingY,
      viralShrink: viralShrink,
    );
    return desired > minPx ? desired : minPx;
  }

  /// Minimum seconds between walls at the player line for current tuning.
  static double minWallIntervalSeconds({
    required double runProgress,
    required double speed,
    required WorldId world,
    required double floorY,
    required double ceilingY,
    double viralShrink = 0,
  }) {
    final spacing = wallSpacing(
      runProgress: runProgress,
      speed: speed,
      world: world,
      floorY: floorY,
      ceilingY: ceilingY,
      viralShrink: viralShrink,
    );
    if (speed <= 0) return 0;
    return spacing / speed;
  }
}

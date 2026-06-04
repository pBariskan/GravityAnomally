import 'package:flutter_test/flutter_test.dart';
import 'package:strain/config/game_config.dart';
import 'package:strain/game/difficulty_curve.dart';
import 'package:strain/game/path_calculator.dart';
import 'package:strain/models/world_id.dart';

void main() {
  const floorY = GameConfig.floorPadding;
  const ceilingY = 800.0 - GameConfig.ceilingPadding;
  const world = WorldId.microverse;

  group('DifficultyCurve', () {
    test('forwardSpeed increases monotonically with runProgress', () {
      var prev = DifficultyCurve.forwardSpeed(0);
      for (var i = 1; i <= 10; i++) {
        final p = i / 10.0;
        final next = DifficultyCurve.forwardSpeed(p);
        expect(next, greaterThanOrEqualTo(prev));
        prev = next;
      }
      expect(DifficultyCurve.forwardSpeed(0), GameConfig.forwardSpeedStart);
      expect(DifficultyCurve.forwardSpeed(1), GameConfig.forwardSpeedEnd);
    });

    test('wall interval meets physics floor at start and end of run', () {
      for (final progress in [0.0, 0.5, 1.0]) {
        final speed = DifficultyCurve.forwardSpeed(progress);
        final tau = DifficultyCurve.minFlipPeriodSeconds(world);
        final nMin = DifficultyCurve.minFlipsForWorld(
          world: world,
          floorY: floorY,
          ceilingY: ceilingY,
        );
        final minInterval = nMin * tau + GameConfig.flipTimingSlackSeconds;
        final actualInterval = DifficultyCurve.minWallIntervalSeconds(
          runProgress: progress,
          speed: speed,
          world: world,
          floorY: floorY,
          ceilingY: ceilingY,
        );
        expect(
          actualInterval,
          greaterThanOrEqualTo(minInterval - 1e-6),
          reason: 'progress=$progress',
        );
      }
    });

    test('spacing is at least desired or physics minimum', () {
      for (final progress in [0.0, 1.0]) {
        final speed = DifficultyCurve.forwardSpeed(progress);
        final spacing = DifficultyCurve.wallSpacing(
          runProgress: progress,
          speed: speed,
          world: world,
          floorY: floorY,
          ceilingY: ceilingY,
        );
        final desired = DifficultyCurve.desiredSpacingPx(
          runProgress: progress,
          speed: speed,
        );
        final minPx = DifficultyCurve.minSpacingPx(
          speed: speed,
          world: world,
          floorY: floorY,
          ceilingY: ceilingY,
        );
        expect(spacing, greaterThanOrEqualTo(desired - 1e-6));
        expect(spacing, greaterThanOrEqualTo(minPx - 1e-6));
      }
    });
  });

  group('PathCalculator', () {
    test('one flip from corridor center reaches gap center', () {
      const gapH = GameConfig.baseGapHeight;
      final center = (floorY + ceilingY) / 2;
      final gapTop = center - gapH / 2;
      final gapBottom = center + gapH / 2;
      const travelTime = 2.0;

      var reached = false;
      for (final gravitySign in [-1.0, 1.0]) {
        final y = PathCalculator.viableYPositions(
          floorY: floorY,
          ceilingY: ceilingY,
          gapTop: gapTop,
          gapBottom: gapBottom,
          startY: center + 30,
          startVy: 0,
          gravitySign: gravitySign,
          gravityStrength: GameConfig.gravityStrength,
          distanceToGap: travelTime * GameConfig.forwardSpeedStart,
          forwardSpeed: GameConfig.forwardSpeedStart,
          samples: 16,
        );
        if (y.any((v) => v >= gapTop + 12 && v <= gapBottom - 12)) {
          reached = true;
        }
      }
      expect(reached, isTrue);
    });

    test('minFlipsForGap is between 0 and 2 for default gap', () {
      final gap = DifficultyCurve.nominalGapBounds(
        floorY: floorY,
        ceilingY: ceilingY,
        world: world,
      );
      final n = PathCalculator.minFlipsForGap(
        floorY: floorY,
        ceilingY: ceilingY,
        gapTop: gap.gapTop,
        gapBottom: gap.gapBottom,
        gravityStrength: GameConfig.gravityStrength,
      );
      expect(n, inInclusiveRange(0, 2));
    });
  });
}

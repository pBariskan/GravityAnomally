import 'dart:math' as math;

import '../models/evolution_tier.dart';
import '../models/world_id.dart';

/// Central tuning for all physics and world rules. Never modified at runtime by upgrades.
class GameConfig {
  GameConfig._();

  // --- Baseline physics (World 1 / Microverse) ---
  /// Forward speed at run start / end (px/s); [DifficultyCurve] eases between them.
  static const double forwardSpeedStart = 130.0;
  static const double forwardSpeedEnd = 220.0;
  /// Ease exponent on run progress (>1 keeps early run slower longer).
  static const double difficultyEaseExponent = 2.0;

  /// Tuned so one flip arc ≈ 0.4× base gap height (see difficulty_curve tests).
  static const double gravityStrength = 1400.0; // px/s²
  /// Instant Y velocity on flip; sign combines with gravity direction after flip.
  static const double flipVelocity = -520.0;

  static const double playerXRatio = 0.22; // fraction of playfield width

  static const double floorPadding = 48.0;
  static const double ceilingPadding = 48.0;

  static const double playerBaseRadius = 14.0;
  static const double morphPopDuration = 0.35;
  static const double morphShrinkDuration = 0.25;

  // --- Difficulty curve ---
  /// Extra seconds of timing slack when deriving minimum wall spacing.
  static const double flipTimingSlackSeconds = 0.15;
  static const double pathGapMargin = 12.0;

  // --- Evolution ---
  static const int collectiblesPerTier = 10;
  static const int tierCount = 6;
  static const double organismSurvivalSeconds = 10.0;

  // --- Walls (World 1 baseline) ---
  static const double wallWidth = 28.0;
  static const double baseGapHeight = 140.0;
  static const double minGapHeight = 72.0;
  /// Desired seconds between walls at run start / end (spacing = speed × interval).
  static const double wallSpawnIntervalStart = 2.5;
  static const double wallSpawnIntervalMin = 1.2;
  /// Spawn X offset beyond the right screen edge (normal mode).
  static const double wallSpawnBeyondScreen = 64.0;
  static const double wallDespawnBehindPlayer = 48.0;
  /// How far ahead of the screen edge to keep spawning walls (× playWidth).
  static const double wallSpawnLookaheadPlayWidths = 1.5;

  // --- Collectibles ---
  static const double collectibleRadius = 10.0;
  static const double earlySafeSpawnRatio = 0.98;
  static const double lateSafeSpawnRatio = 0.80;

  // --- World 2 Deep Ocean ---
  static const double oceanGapAmplitudeBase = 36.0;
  static const double oceanGapAmplitudeRamp = 1.08;
  static const double oceanGapFrequencyBase = 0.004;
  static const double oceanGapFrequencyRamp = 1.05;

  // --- World 3 Neural ---
  static const double neuralFlipCooldown = 0.3;
  static const double neuralGapHeightBonus = 24.0;

  // --- World 4 Cosmic ---
  static const double cosmicGravityMultiplier = 0.6;
  static const double cosmicGapHeightReduction = 28.0;

  // --- World 5 Viral ---
  static const int viralShrinkEveryNWalls = 4;
  static const double viralGapShrinkAmount = 12.0;

  // --- Challenge modes ---
  static const double speedRunMultiplier = 1.2;

  // --- Blind mode ---
  static const double blindFlashMinInterval = 2.5;
  static const double blindFlashMaxInterval = 6.0;
  static const double blindFlashDuration = 0.35;

  static double gravityForWorld(WorldId world) {
    switch (world) {
      case WorldId.cosmic:
        return gravityStrength * cosmicGravityMultiplier;
      default:
        return gravityStrength;
    }
  }

  static double easedProgress(double runProgress) {
    final p = runProgress.clamp(0.0, 1.0);
    return math.pow(p, difficultyEaseExponent).toDouble();
  }

  static double forwardSpeedForProgress(double runProgress) {
    final t = easedProgress(runProgress);
    return forwardSpeedStart + t * (forwardSpeedEnd - forwardSpeedStart);
  }

  /// Desired wall spawn interval (seconds) for current run progress [0, 1].
  static double wallSpawnIntervalForProgress(double runProgress) {
    final t = easedProgress(runProgress);
    return wallSpawnIntervalStart +
        t * (wallSpawnIntervalMin - wallSpawnIntervalStart);
  }

  /// Minimum seconds between flips at given gravity (one full velocity reversal).
  static double minFlipPeriodSeconds(double gravityMagnitude) {
    final g = gravityMagnitude.abs();
    if (g <= 0) return 0;
    return 2 * flipVelocity.abs() / g;
  }

  static double gapHeightForWorld(WorldId world, {double viralShrink = 0}) {
    var gap = baseGapHeight;
    switch (world) {
      case WorldId.neural:
        gap += neuralGapHeightBonus;
        break;
      case WorldId.cosmic:
        gap -= cosmicGapHeightReduction;
        break;
      case WorldId.viral:
        gap -= viralShrink;
        break;
      default:
        break;
    }
    return gap.clamp(minGapHeight, baseGapHeight + neuralGapHeightBonus);
  }

  static double playerRadiusForTier(EvolutionTier tier) {
    return playerBaseRadius + tier.index * 3.5;
  }

  static int collectiblesFloorForTier(EvolutionTier tier) =>
      tier.index * collectiblesPerTier;
}

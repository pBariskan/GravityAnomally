import '../models/evolution_tier.dart';
import '../models/world_id.dart';

/// Central tuning for all physics and world rules. Never modified at runtime by upgrades.
class GameConfig {
  GameConfig._();

  // --- Baseline physics (World 1 / Microverse) ---
  static const double gravityMagnitude = 9.8;
  static const double forwardSpeed = 220.0; // px/s, world scrolls left
  static const double playerXRatio = 0.22; // fraction of playfield width

  static const double floorPadding = 48.0;
  static const double ceilingPadding = 48.0;

  static const double playerBaseRadius = 14.0;
  static const double morphPopDuration = 0.35;
  static const double morphShrinkDuration = 0.25;

  // --- Evolution ---
  static const int collectiblesPerTier = 10;
  static const int tierCount = 6;
  static const double organismSurvivalSeconds = 10.0;

  // --- Walls (World 1 baseline) ---
  static const double wallWidth = 28.0;
  static const double baseGapHeight = 140.0;
  static const double minGapHeight = 72.0;
  static const double wallSpacing = 320.0;
  static const double firstWallOffset = 480.0;
  static const double wallFrequencyRampPerWall = 0.92; // spacing multiplier, decreases over run

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
        return gravityMagnitude * cosmicGravityMultiplier;
      default:
        return gravityMagnitude;
    }
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

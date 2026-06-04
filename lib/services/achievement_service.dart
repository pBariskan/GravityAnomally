import '../models/achievement_id.dart';
import '../models/challenge_mode.dart';
import '../models/evolution_tier.dart';
import '../models/game_event.dart';
import '../models/persistent_stats.dart';
import '../models/world_id.dart';
import 'persistence_service.dart';

class AchievementService {
  AchievementService(this._persistence);

  final PersistenceService _persistence;
  PersistentStats stats = PersistentStats();

  final List<void Function(AchievementId)> _unlockListeners = [];

  void addUnlockListener(void Function(AchievementId) listener) {
    _unlockListeners.add(listener);
  }

  Future<void> load() async {
    stats = await _persistence.loadStats();
  }

  Future<void> _save() => _persistence.saveStats(stats);

  bool isUnlocked(AchievementId id) =>
      stats.unlockedAchievements.contains(id.name);

  bool isChallengeUnlocked(ChallengeMode mode) {
    if (mode == ChallengeMode.none) return true;
    return stats.unlockedChallenges.contains(mode.name);
  }

  void _unlock(AchievementId id) {
    if (isUnlocked(id)) return;
    stats.unlockedAchievements.add(id.name);
    for (final l in _unlockListeners) {
      l(id);
    }
    _unlockChallengeForAchievement(id);
  }

  void _unlockChallenge(ChallengeMode mode) {
    if (mode == ChallengeMode.none) return;
    stats.unlockedChallenges.add(mode.name);
  }

  void _unlockChallengeForAchievement(AchievementId id) {
    switch (id) {
      case AchievementId.rapidCell:
        _unlockChallenge(ChallengeMode.speedRun);
        break;
      default:
        break;
    }
  }

  Future<void> handleEvent(GameEvent event) async {
    switch (event) {
      case TierReachedEvent(:final tier):
        _onTierReached(tier);
        break;
      case CollectibleCollectedEvent():
        break;
      case WallHitEvent():
        break;
      case WorldClearedEvent(:final world):
        _onWorldCleared(world);
        break;
      case RunStartedEvent():
        stats.totalRuns++;
        await _save();
        return;
      case RunEndedEvent e:
        await _onRunEnded(e);
        return;
      default:
        return;
    }
    await _save();
  }

  void _onTierReached(EvolutionTier tier) {
    final key = tier.name;
    stats.tierReachCounts[key] = (stats.tierReachCounts[key] ?? 0) + 1;

    final achievement = switch (tier) {
      EvolutionTier.molecule => AchievementId.reachMolecule,
      EvolutionTier.organelle => AchievementId.reachOrganelle,
      EvolutionTier.cell => AchievementId.reachCell,
      EvolutionTier.tissue => AchievementId.reachTissue,
      EvolutionTier.organ => AchievementId.reachOrgan,
      EvolutionTier.organism => AchievementId.reachOrganism,
    };
    _unlock(achievement);

    if (tier == EvolutionTier.organism) {
      stats.organismReachCount++;
      if (stats.organismReachCount >= 5) _unlock(AchievementId.organismTimes5);
      if (stats.organismReachCount >= 25) {
        _unlock(AchievementId.organismTimes25);
      }
      if (stats.organismReachCount >= 100) {
        _unlock(AchievementId.organismTimes100);
      }
      if (stats.organismReachCount >= 5) {
        _unlockChallenge(ChallengeMode.blind);
      }
    }
  }

  void _onWorldCleared(WorldId world) {
    stats.worldsCleared[world.name] = true;
    final achievement = switch (world) {
      WorldId.microverse => AchievementId.clearMicroverse,
      WorldId.deepOcean => AchievementId.clearDeepOcean,
      WorldId.neural => AchievementId.clearNeural,
      WorldId.cosmic => AchievementId.clearCosmic,
      WorldId.viral => AchievementId.clearViral,
    };
    _unlock(achievement);

    if (stats.worldsCleared.length >= WorldId.values.length) {
      // all cleared tracked per-world
    }
  }

  Future<void> recordOrganismInWorld(WorldId world) async {
    stats.organismReachedPerWorld[world.name] = true;
    if (WorldId.values.every(
      (w) => stats.organismReachedPerWorld[w.name] == true,
    )) {
      _unlock(AchievementId.organismInEveryWorld);
    }
    await _save();
  }

  Future<void> onCollectibleCollected(int runTotal) async {
    stats.totalCollectibles++;
    if (stats.totalCollectibles >= 10) _unlock(AchievementId.collect10Total);
    if (stats.totalCollectibles >= 50) _unlock(AchievementId.collect50Total);
    if (stats.totalCollectibles >= 100) {
      _unlock(AchievementId.collect100Total);
    }
    if (stats.totalCollectibles >= 500) {
      _unlock(AchievementId.collect500Total);
    }
    if (stats.totalCollectibles >= 1000) {
      _unlock(AchievementId.collect1000Total);
    }
    if (runTotal >= 30) _unlock(AchievementId.collect30InRun);
    await _save();
  }

  Future<void> _onRunEnded(RunEndedEvent e) async {
    if (e.finalTier.index > stats.peakStrainIndex) {
      stats.peakStrainIndex = e.finalTier.index;
    }

    if (e.collectiblesThisRun > stats.bestRunCollectibles) {
      stats.bestRunCollectibles = e.collectiblesThisRun;
    }

    final previousBest = stats.personalBestScore;
    if (e.score > previousBest) {
      if (previousBest > 0) _unlockChallenge(ChallengeMode.mirror);
      stats.personalBestScore = e.score;
    }

    if (e.flawless && e.reachedOrganism) {
      _unlock(AchievementId.flawlessRun);
    }
    if (e.phoenixAchieved) _unlock(AchievementId.phoenixRun);
    if (e.wallHits >= 10 && e.reachedOrganism) {
      _unlock(AchievementId.batteredSurvivor);
    }
    if (e.runDurationSeconds <= 30 &&
        e.finalTier.index >= EvolutionTier.cell.index) {
      _unlock(AchievementId.rapidCell);
    }

    if (e.reachedOrganism) {
      await recordOrganismInWorld(e.world);
    }

    if (e.clearedWorld) {
      final next = e.world.next;
      if (next != null && next.index > stats.unlockedWorldIndex) {
        stats.unlockedWorldIndex = next.index;
      }
    }

    await _save();
  }

  int runScore(int collectibles, EvolutionTier peakTierInRun) =>
      collectibles * 10 + peakTierInRun.index * 25;
}

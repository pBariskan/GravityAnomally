import 'evolution_tier.dart';
import 'world_id.dart';

class PersistentStats {
  PersistentStats({
    this.peakStrainIndex = 0,
    this.totalCollectibles = 0,
    this.totalRuns = 0,
    this.tierReachCounts = const {},
    this.worldsCleared = const {},
    this.unlockedWorldIndex = 0,
    this.organismReachCount = 0,
    this.bestRunCollectibles = 0,
    this.unlockedAchievements = const {},
    this.unlockedChallenges = const {},
    this.organismReachedPerWorld = const {},
    this.personalBestScore = 0,
  });

  int peakStrainIndex;
  int totalCollectibles;
  int totalRuns;
  Map<String, int> tierReachCounts;
  Map<String, bool> worldsCleared;
  int unlockedWorldIndex;
  int organismReachCount;
  int bestRunCollectibles;
  Set<String> unlockedAchievements;
  Set<String> unlockedChallenges;
  Map<String, bool> organismReachedPerWorld;
  int personalBestScore;

  EvolutionTier get peakStrain =>
      EvolutionTier.fromIndex(peakStrainIndex.clamp(0, 5));

  WorldId get currentWorld => WorldId.fromIndex(unlockedWorldIndex);

  bool isWorldCleared(WorldId w) => worldsCleared[w.name] == true;

  int tierReachCount(EvolutionTier t) => tierReachCounts[t.name] ?? 0;

  Map<String, dynamic> toJson() => {
        'peakStrainIndex': peakStrainIndex,
        'totalCollectibles': totalCollectibles,
        'totalRuns': totalRuns,
        'tierReachCounts': tierReachCounts,
        'worldsCleared': worldsCleared,
        'unlockedWorldIndex': unlockedWorldIndex,
        'organismReachCount': organismReachCount,
        'bestRunCollectibles': bestRunCollectibles,
        'unlockedAchievements': unlockedAchievements.toList(),
        'unlockedChallenges': unlockedChallenges.toList(),
        'organismReachedPerWorld': organismReachedPerWorld,
        'personalBestScore': personalBestScore,
      };

  factory PersistentStats.fromJson(Map<String, dynamic> json) {
    return PersistentStats(
      peakStrainIndex: json['peakStrainIndex'] as int? ?? 0,
      totalCollectibles: json['totalCollectibles'] as int? ?? 0,
      totalRuns: json['totalRuns'] as int? ?? 0,
      tierReachCounts: Map<String, int>.from(
        (json['tierReachCounts'] as Map?)?.cast<String, int>() ?? {},
      ),
      worldsCleared: Map<String, bool>.from(
        (json['worldsCleared'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), v == true),
            ) ??
            {},
      ),
      unlockedWorldIndex: json['unlockedWorldIndex'] as int? ?? 0,
      organismReachCount: json['organismReachCount'] as int? ?? 0,
      bestRunCollectibles: json['bestRunCollectibles'] as int? ?? 0,
      unlockedAchievements: Set<String>.from(
        (json['unlockedAchievements'] as List?)?.cast<String>() ?? [],
      ),
      unlockedChallenges: Set<String>.from(
        (json['unlockedChallenges'] as List?)?.cast<String>() ?? [],
      ),
      organismReachedPerWorld: Map<String, bool>.from(
        (json['organismReachedPerWorld'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), v == true),
            ) ??
            {},
      ),
      personalBestScore: json['personalBestScore'] as int? ?? 0,
    );
  }

  PersistentStats copy() => PersistentStats.fromJson(toJson());
}

import 'evolution_tier.dart';
import 'world_id.dart';

sealed class GameEvent {}

class RunStartedEvent extends GameEvent {}

class RunEndedEvent extends GameEvent {
  RunEndedEvent({
    required this.finalTier,
    required this.collectiblesThisRun,
    required this.wallHits,
    required this.world,
    required this.clearedWorld,
    required this.flawless,
    required this.reachedOrganism,
    required this.phoenixAchieved,
    required this.runDurationSeconds,
    required this.score,
  });

  final EvolutionTier finalTier;
  final int collectiblesThisRun;
  final int wallHits;
  final WorldId world;
  final bool clearedWorld;
  final bool flawless;
  final bool reachedOrganism;
  final bool phoenixAchieved;
  final double runDurationSeconds;
  final int score;
}

class TierReachedEvent extends GameEvent {
  TierReachedEvent(this.tier);
  final EvolutionTier tier;
}

class TierLostEvent extends GameEvent {
  TierLostEvent(this.tier);
  final EvolutionTier tier;
}

class CollectibleCollectedEvent extends GameEvent {
  CollectibleCollectedEvent(this.runTotal);
  final int runTotal;
}

class WallHitEvent extends GameEvent {
  WallHitEvent(this.tierAfter);
  final EvolutionTier tierAfter;
}

class WorldClearedEvent extends GameEvent {
  WorldClearedEvent(this.world);
  final WorldId world;
}

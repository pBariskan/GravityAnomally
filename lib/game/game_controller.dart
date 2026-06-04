import 'dart:math';

import 'package:flutter/foundation.dart';

import '../config/game_config.dart';
import '../models/challenge_mode.dart';
import '../models/evolution_tier.dart';
import '../models/game_event.dart';
import '../models/world_id.dart';
import '../services/achievement_service.dart';
import 'collectible_spawner.dart';
import 'entities.dart';
import 'wall_spawner.dart';

enum GamePhase { playing, organismCountdown, gameOver, worldCleared }

class GameController extends ChangeNotifier {
  final WorldId world;
  final ChallengeMode challenge;
  final AchievementService achievementService;
  final double playWidth;
  final double playHeight;

  final Random _rng;
  late WallSpawner _wallSpawner;
  late CollectibleSpawner _collectibleSpawner;

  // Physics — never buffed by progression
  double get _gravityMag => GameConfig.gravityForWorld(world);
  double get _forwardSpeed {
    var s = GameConfig.forwardSpeed;
    if (challenge == ChallengeMode.speedRun) s *= GameConfig.speedRunMultiplier;
    return s;
  }

  final bool mirrorMode;
  bool get _mirror => challenge == ChallengeMode.mirror;

  double get playerX =>
      _mirror
          ? playWidth * (1 - GameConfig.playerXRatio)
          : playWidth * GameConfig.playerXRatio;

  double floorY = GameConfig.floorPadding;
  double ceilingY = 0;

  double playerY = 0;
  double velocityY = 0;
  double gravitySign = 1; // +1 = downward acceleration in screen coords

  EvolutionTier tier = EvolutionTier.molecule;
  int collectibles = 0;
  int wallHits = 0;
  bool flawlessSoFar = true;

  GamePhase phase = GamePhase.playing;
  double runTime = 0;
  double distanceTraveled = 0;
  double organismTimer = 0;
  double morphScale = 1;
  double morphAnim = 0;
  bool morphGrowing = true;

  double flipCooldownRemaining = 0;
  bool flipReady = true;
  double blindFlashTimer = 0;
  double blindFlashRemaining = 0;
  double _nextBlindFlashIn = 3;

  final List<WallSegment> walls = [];
  final List<CollectibleOrb> orbs = [];
  final Set<double> _usedOrbY = {};

  bool reachedOrganismThisRun = false;
  bool hitMoleculeWall = false;
  bool phoenixCandidate = false;
  bool deEvolvedFromOrganism = false;
  bool droppedToMoleculeAfterOrganism = false;
  EvolutionTier peakTierThisRun = EvolutionTier.molecule;

  int get score =>
      collectibles * 10 + tier.index * 25 + (world.index + 1) * 5;

  double get runProgress =>
      (distanceTraveled / 8000).clamp(0.0, 1.0);

  GameController({
    required this.world,
    required this.challenge,
    required this.achievementService,
    required this.playWidth,
    required this.playHeight,
    int? seed,
  }) : mirrorMode = challenge == ChallengeMode.mirror,
       _rng = Random(seed ?? DateTime.now().millisecondsSinceEpoch) {
    _wallSpawner = WallSpawner(
      world: world,
      playHeight: playHeight,
      playWidth: playWidth,
      rng: _rng,
      mirror: challenge == ChallengeMode.mirror,
    );
    _collectibleSpawner = CollectibleSpawner(_rng);
    reset();
  }

  void reset() {
    ceilingY = playHeight - GameConfig.ceilingPadding;
    floorY = GameConfig.floorPadding;
    playerY = (floorY + ceilingY) / 2;
    velocityY = 0;
    gravitySign = 1;
    tier = EvolutionTier.molecule;
    collectibles = 0;
    wallHits = 0;
    flawlessSoFar = true;
    phase = GamePhase.playing;
    runTime = 0;
    distanceTraveled = 0;
    organismTimer = 0;
    morphScale = 1;
    morphAnim = 0;
    flipCooldownRemaining = 0;
    flipReady = true;
    blindFlashTimer = 0;
    blindFlashRemaining = 0;
    _nextBlindFlashIn = 3;
    walls.clear();
    orbs.clear();
    _usedOrbY.clear();
    reachedOrganismThisRun = false;
    hitMoleculeWall = false;
    phoenixCandidate = false;
    deEvolvedFromOrganism = false;
    droppedToMoleculeAfterOrganism = false;
    peakTierThisRun = EvolutionTier.molecule;
    _wallSpawner.reset();
    _spawnInitial();
    achievementService.handleEvent(RunStartedEvent());
  }

  void _spawnInitial() {
    final spawned = _wallSpawner.spawnPending(playWidth * 2);
    walls.addAll(spawned);
  }

  void flipGravity() {
    if (phase != GamePhase.playing) return;
    if (world == WorldId.neural && flipCooldownRemaining > 0) return;
    gravitySign = -gravitySign;
    velocityY = -velocityY;
    if (world == WorldId.neural) {
      flipCooldownRemaining = GameConfig.neuralFlipCooldown;
      flipReady = false;
    }
    notifyListeners();
  }

  void update(double dt) {
    if (phase == GamePhase.gameOver || phase == GamePhase.worldCleared) {
      return;
    }

    runTime += dt;
    distanceTraveled += _forwardSpeed * dt;

    if (challenge == ChallengeMode.blind) {
      _updateBlind(dt);
    }

    if (flipCooldownRemaining > 0) {
      flipCooldownRemaining -= dt;
      if (flipCooldownRemaining <= 0) {
        flipCooldownRemaining = 0;
        flipReady = true;
      }
    }

    if (morphAnim > 0) {
      morphAnim -= dt;
      if (morphAnim <= 0) morphScale = 1;
    }

    if (phase == GamePhase.organismCountdown) {
      organismTimer -= dt;
      if (organismTimer <= 0) {
        phase = GamePhase.worldCleared;
        achievementService.handleEvent(WorldClearedEvent(world));
        _endRun(clearedWorld: true);
      }
      notifyListeners();
      return;
    }

    // Physics
    final g = gravitySign * _gravityMag;
    velocityY += g * dt;
    playerY += velocityY * dt;

    if (playerY - _playerRadius <= floorY ||
        playerY + _playerRadius >= ceilingY) {
      _gameOver();
      return;
    }

    _scrollWorld(dt);
    _checkCollisions();
    _trySpawnContent();

    notifyListeners();
  }

  double get _playerRadius => GameConfig.playerRadiusForTier(tier) * morphScale;

  void _updateBlind(double dt) {
    if (blindFlashRemaining > 0) {
      blindFlashRemaining -= dt;
      return;
    }
    blindFlashTimer += dt;
    if (blindFlashTimer >= _nextBlindFlashIn) {
      blindFlashRemaining = GameConfig.blindFlashDuration;
      blindFlashTimer = 0;
      _nextBlindFlashIn = GameConfig.blindFlashMinInterval +
          _rng.nextDouble() *
              (GameConfig.blindFlashMaxInterval -
                  GameConfig.blindFlashMinInterval);
    }
  }

  void _scrollWorld(double dt) {
    final dx = _forwardSpeed * dt;
    final sign = _mirror ? 1 : -1;
    for (final w in walls) {
      w.x += dx * sign;
    }
    for (final o in orbs) {
      o.x += dx * sign;
    }
    walls.removeWhere((w) {
      final remove = _mirror ? w.x > playWidth + 80 : w.passed;
      if (remove) _wallSpawner.pruneOceanWalls((x) => x == w);
      return remove;
    });
    orbs.removeWhere(
      (o) => o.collected || (_mirror ? o.x > playWidth + 40 : o.x < -40),
    );

    _wallSpawner.updateOceanGaps(_forwardSpeed, dt);

    final spawned = _wallSpawner.spawnPending(
      _mirror ? -GameConfig.firstWallOffset : playWidth,
    );
    for (final w in spawned) {
      walls.add(w);
      _wallSpawner.trackOceanWall(w);
    }
  }

  void _trySpawnContent() {
    for (final w in walls) {
      if (orbs.any((o) => (o.x - w.x).abs() < 40)) continue;
      final nextIdx = walls.indexOf(w) + 1;
      final next = nextIdx < walls.length ? walls[nextIdx] : null;
      final orb = _collectibleSpawner.maybeSpawn(
        wall: w,
        nextWall: next,
        playerX: playerX,
        playerY: playerY,
        playerVy: velocityY,
        gravitySigned: gravitySign * _gravityMag,
        forwardSpeed: _forwardSpeed,
        floorY: floorY,
        ceilingY: ceilingY,
        runProgress: runProgress,
        worldIndex: world.index,
        usedY: _usedOrbY,
      );
      if (orb != null) orbs.add(orb);
    }
  }

  void _checkCollisions() {
    for (final w in walls) {
      if (w.collidesCircle(playerX, playerY, _playerRadius)) {
        _onWallHit();
        break;
      }
    }

    for (final o in orbs) {
      if (o.intersects(playerX, playerY, _playerRadius)) {
        o.collected = true;
        _onCollectible();
      }
    }
  }

  void _onCollectible() {
    collectibles++;
    achievementService.onCollectibleCollected(collectibles);
    achievementService.handleEvent(CollectibleCollectedEvent(collectibles));

    final newTierIndex = collectibles ~/ GameConfig.collectiblesPerTier;
    final capped = newTierIndex.clamp(0, EvolutionTier.values.length - 1);
    final newTier = EvolutionTier.fromIndex(capped);
    if (newTier.index > tier.index) {
      _evolveUp(newTier);
    }
    notifyListeners();
  }

  void _evolveUp(EvolutionTier newTier) {
    tier = newTier;
    if (tier.index > peakTierThisRun.index) peakTierThisRun = tier;
    morphGrowing = true;
    morphAnim = GameConfig.morphPopDuration;
    morphScale = 1.35;
    achievementService.handleEvent(TierReachedEvent(tier));

    if (tier == EvolutionTier.organism) {
      reachedOrganismThisRun = true;
      if (droppedToMoleculeAfterOrganism) phoenixCandidate = true;
      phase = GamePhase.organismCountdown;
      organismTimer = GameConfig.organismSurvivalSeconds;
    }
    notifyListeners();
  }

  void _onWallHit() {
    wallHits++;
    flawlessSoFar = false;

    if (tier == EvolutionTier.molecule) {
      hitMoleculeWall = true;
      _gameOver();
      return;
    }

    if (tier == EvolutionTier.organism) deEvolvedFromOrganism = true;

    final prev = tier;
    tier = tier.previous ?? EvolutionTier.molecule;
    if (reachedOrganismThisRun && tier == EvolutionTier.molecule) {
      droppedToMoleculeAfterOrganism = true;
    }
    collectibles = GameConfig.collectiblesFloorForTier(tier);
    morphGrowing = false;
    morphAnim = GameConfig.morphShrinkDuration;
    morphScale = 0.75;

    achievementService.handleEvent(TierLostEvent(tier));
    achievementService.handleEvent(WallHitEvent(tier));

    if (prev == EvolutionTier.organism) {
      phase = GamePhase.playing;
      organismTimer = 0;
    }

    notifyListeners();
  }

  void _gameOver() {
    if (phase == GamePhase.gameOver) return;
    phase = GamePhase.gameOver;
    _endRun(clearedWorld: false);
    notifyListeners();
  }

  void _endRun({required bool clearedWorld}) {
    achievementService.handleEvent(
      RunEndedEvent(
        finalTier: tier,
        collectiblesThisRun: collectibles,
        wallHits: wallHits,
        world: world,
        clearedWorld: clearedWorld,
        flawless: flawlessSoFar,
        reachedOrganism: reachedOrganismThisRun,
        phoenixAchieved: phoenixCandidate,
        runDurationSeconds: runTime,
        score: score,
      ),
    );
  }

  bool get isBlindActive =>
      challenge == ChallengeMode.blind && blindFlashRemaining > 0;
}

import 'dart:math';

import '../config/game_config.dart';
import '../models/world_id.dart';
import 'entities.dart';

class WallSpawner {
  WallSpawner({
    required this.world,
    required this.playHeight,
    required this.playWidth,
    required Random rng,
    this.mirror = false,
  })  : _rng = rng,
        _floorY = GameConfig.floorPadding,
        _ceilingY = playHeight - GameConfig.ceilingPadding {
    _resetSpawnCursor();
  }

  final WorldId world;
  final double playHeight;
  final double playWidth;
  final bool mirror;
  final Random _rng;

  final double _floorY;
  final double _ceilingY;

  int _wallCount = 0;
  late double _nextSpawnX;
  double _spacing = GameConfig.wallSpacing;
  double _viralShrink = 0;
  double _runOscillationPhase = 0;

  double get viralShrink => _viralShrink;

  void _resetSpawnCursor() {
    _nextSpawnX = mirror
        ? playWidth + GameConfig.firstWallOffset
        : GameConfig.firstWallOffset;
  }

  List<WallSegment> spawnPending(double cameraMaxX) {
    final spawned = <WallSegment>[];
    if (mirror) {
      while (_nextSpawnX > playWidth - 120) {
        spawned.add(_createWall(_nextSpawnX));
        _advanceAfterSpawn();
        _nextSpawnX -= _spacing;
      }
    } else {
      while (_nextSpawnX < cameraMaxX + playWidth * 1.5) {
        spawned.add(_createWall(_nextSpawnX));
        _advanceAfterSpawn();
        _nextSpawnX += _spacing;
      }
    }
    return spawned;
  }

  void _advanceAfterSpawn() {
    _wallCount++;
    _spacing *= GameConfig.wallFrequencyRampPerWall;
    _spacing = _spacing.clamp(180.0, GameConfig.wallSpacing);
    if (world == WorldId.viral &&
        _wallCount % GameConfig.viralShrinkEveryNWalls == 0) {
      _viralShrink += GameConfig.viralGapShrinkAmount;
    }
  }

  WallSegment _createWall(double x) {
    final gapH = GameConfig.gapHeightForWorld(world, viralShrink: _viralShrink);
    final playable = _ceilingY - _floorY;
    final margin = 40.0;
    var gapCenter = _floorY +
        margin +
        _rng.nextDouble() * (playable - gapH - margin * 2) +
        gapH / 2;

    if (world == WorldId.deepOcean) {
      final amp = GameConfig.oceanGapAmplitudeBase *
          pow(GameConfig.oceanGapAmplitudeRamp, _wallCount / 20.0);
      final freq = GameConfig.oceanGapFrequencyBase *
          pow(GameConfig.oceanGapFrequencyRamp, _wallCount / 25.0);
      _runOscillationPhase += 1.7;
      gapCenter += sin(_runOscillationPhase * freq * 100 + x * freq) * amp;
      gapCenter = gapCenter.clamp(
        _floorY + gapH / 2 + margin,
        _ceilingY - gapH / 2 - margin,
      );
    }

    final gapTop = gapCenter - gapH / 2;
    final gapBottom = gapCenter + gapH / 2;

    return WallSegment(
      id: _wallCount,
      x: x,
      width: GameConfig.wallWidth,
      gapTop: gapTop,
      gapBottom: gapBottom,
    );
  }

  void reset() {
    _wallCount = 0;
    _spacing = GameConfig.wallSpacing;
    _viralShrink = 0;
    _runOscillationPhase = 0;
    _activeOceanWalls.clear();
    _resetSpawnCursor();
  }

  /// Deep Ocean: gap drifts while the wall approaches the player.
  void updateOceanGaps(double scrollSpeed, double dt) {
    if (world != WorldId.deepOcean) return;
    for (final w in _activeOceanWalls) {
      final amp = GameConfig.oceanGapAmplitudeBase *
          pow(GameConfig.oceanGapAmplitudeRamp, w.id / 20.0);
      final freq = GameConfig.oceanGapFrequencyBase *
          pow(GameConfig.oceanGapFrequencyRamp, w.id / 25.0);
      final gapH = (w.gapBottom - w.gapTop);
      final center = (w.gapTop + w.gapBottom) / 2;
      final newCenter = center +
          sin(_runOscillationPhase + w.x * freq * 0.02) * amp * dt * 3.5;
      final clamped = newCenter.clamp(
        _floorY + gapH / 2 + 40,
        _ceilingY - gapH / 2 - 40,
      );
      w.gapTop = clamped - gapH / 2;
      w.gapBottom = clamped + gapH / 2;
    }
    _runOscillationPhase += dt * scrollSpeed * 0.004;
  }

  final List<WallSegment> _activeOceanWalls = [];

  void trackOceanWall(WallSegment w) {
    if (world == WorldId.deepOcean) _activeOceanWalls.add(w);
  }

  void pruneOceanWalls(bool Function(WallSegment) remove) {
    _activeOceanWalls.removeWhere(remove);
  }
}

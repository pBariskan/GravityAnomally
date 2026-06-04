enum CollisionKind { wall, collectible }

class WallSegment {
  static const CollisionKind collisionKind = CollisionKind.wall;
  WallSegment({
    required this.x,
    required this.gapTop,
    required this.gapBottom,
    required this.width,
    this.id = 0,
  });

  final int id;
  double x;
  final double width;
  double gapTop;
  double gapBottom;

  bool passedBehind(double playerX, [double margin = 0]) =>
      x + width < playerX - margin;

  /// Solid pillars only — the gap is safe.
  bool collidesCircle(double cx, double cy, double radius) {
    if (cx + radius < x || cx - radius > x + width) return false;
    if (cy - radius >= gapTop && cy + radius <= gapBottom) return false;
    return true;
  }
}

class CollectibleOrb {
  static const CollisionKind collisionKind = CollisionKind.collectible;
  CollectibleOrb({
    required this.x,
    required this.y,
    required this.safe,
    this.collected = false,
  });

  double x;
  double y;
  final bool safe;
  bool collected;

  bool intersects(double cx, double cy, double playerR, double orbRadius) {
    if (collected) return false;
    final dx = x - cx;
    final dy = y - cy;
    final sum = playerR + orbRadius;
    return dx * dx + dy * dy < sum * sum;
  }
}

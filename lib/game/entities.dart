class WallSegment {
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

  bool get passed => x + width < 0;

  bool collidesCircle(double cx, double cy, double radius) {
    if (cx + radius < x || cx - radius > x + width) return false;
    if (cy - radius < gapTop || cy + radius > gapBottom) return false;
    return true;
  }
}

class CollectibleOrb {
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

  bool intersects(double cx, double cy, double playerR) {
    if (collected) return false;
    final dx = x - cx;
    final dy = y - cy;
    const r = 10.0;
    return dx * dx + dy * dy < (playerR + r) * (playerR + r);
  }
}

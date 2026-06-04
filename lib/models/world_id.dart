enum WorldId {
  microverse,
  deepOcean,
  neural,
  cosmic,
  viral;

  static WorldId fromIndex(int i) =>
      WorldId.values[i.clamp(0, WorldId.values.length - 1)];

  String get displayName {
    switch (this) {
      case WorldId.microverse:
        return 'Microverse';
      case WorldId.deepOcean:
        return 'Deep Ocean';
      case WorldId.neural:
        return 'Neural';
      case WorldId.cosmic:
        return 'Cosmic';
      case WorldId.viral:
        return 'Viral';
    }
  }

  WorldId? get next =>
      index < WorldId.values.length - 1 ? fromIndex(index + 1) : null;
}

enum EvolutionTier {
  molecule,
  organelle,
  cell,
  tissue,
  organ,
  organism;

  static EvolutionTier fromIndex(int i) =>
      EvolutionTier.values[i.clamp(0, EvolutionTier.values.length - 1)];

  static EvolutionTier? fromIndexOrNull(int i) {
    if (i < 0 || i >= EvolutionTier.values.length) return null;
    return EvolutionTier.values[i];
  }

  String get displayName {
    switch (this) {
      case EvolutionTier.molecule:
        return 'Molecule';
      case EvolutionTier.organelle:
        return 'Organelle';
      case EvolutionTier.cell:
        return 'Cell';
      case EvolutionTier.tissue:
        return 'Tissue';
      case EvolutionTier.organ:
        return 'Organ';
      case EvolutionTier.organism:
        return 'Organism';
    }
  }

  EvolutionTier? get next =>
      index < EvolutionTier.values.length - 1 ? fromIndex(index + 1) : null;

  EvolutionTier? get previous =>
      index > 0 ? fromIndex(index - 1) : null;
}

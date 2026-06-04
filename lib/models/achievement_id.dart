enum AchievementId {
  reachMolecule,
  reachOrganelle,
  reachCell,
  reachTissue,
  reachOrgan,
  reachOrganism,
  organismTimes5,
  organismTimes25,
  organismTimes100,
  collect10Total,
  collect50Total,
  collect100Total,
  collect500Total,
  collect1000Total,
  collect30InRun,
  clearMicroverse,
  clearDeepOcean,
  clearNeural,
  clearCosmic,
  clearViral,
  organismInEveryWorld,
  flawlessRun,
  phoenixRun,
  batteredSurvivor,
  rapidCell,
}

extension AchievementIdX on AchievementId {
  String get codexTitle {
    switch (this) {
      case AchievementId.reachMolecule:
        return 'Specimen α — Molecular Phase';
      case AchievementId.reachOrganelle:
        return 'Specimen β — Organelle Emergence';
      case AchievementId.reachCell:
        return 'Specimen γ — Cellular Boundary';
      case AchievementId.reachTissue:
        return 'Specimen δ — Tissue Cohesion';
      case AchievementId.reachOrgan:
        return 'Specimen ε — Organ Differentiation';
      case AchievementId.reachOrganism:
        return 'Specimen ζ — Organismic Integration';
      case AchievementId.organismTimes5:
        return 'Field Note — Quintuple Integration';
      case AchievementId.organismTimes25:
        return 'Field Note — Persistent Holobiont';
      case AchievementId.organismTimes100:
        return 'Field Note — Apex Strain Record';
      case AchievementId.collect10Total:
        return 'Orb Sampling — Initiate';
      case AchievementId.collect50Total:
        return 'Orb Sampling — Accumulation';
      case AchievementId.collect100Total:
        return 'Orb Sampling — Saturation';
      case AchievementId.collect500Total:
        return 'Orb Sampling — Mass Harvest';
      case AchievementId.collect1000Total:
        return 'Orb Sampling — Total Assimilation';
      case AchievementId.collect30InRun:
        return 'Single-Pass Uptake';
      case AchievementId.clearMicroverse:
        return 'Microverse Expedition Cleared';
      case AchievementId.clearDeepOcean:
        return 'Bathypelagic Traverse Cleared';
      case AchievementId.clearNeural:
        return 'Synaptic Corridor Cleared';
      case AchievementId.clearCosmic:
        return 'Vacuum Drift Cleared';
      case AchievementId.clearViral:
        return 'Capsid Run Cleared';
      case AchievementId.organismInEveryWorld:
        return 'Pan-Biome Integration';
      case AchievementId.flawlessRun:
        return 'Wall-Avoidant Phenotype';
      case AchievementId.phoenixRun:
        return 'Regression–Recursion Cycle';
      case AchievementId.batteredSurvivor:
        return 'Damage-Tolerant Apex';
      case AchievementId.rapidCell:
        return 'Accelerated Cellularization';
    }
  }

  String get codexObservation {
    switch (this) {
      case AchievementId.reachMolecule:
        return 'Subject observed at minimal structural complexity. Baseline viable.';
      case AchievementId.reachOrganelle:
        return 'Internal compartments noted. Metabolic throughput increasing.';
      case AchievementId.reachCell:
        return 'Membrane integrity established. Coherent unit locomotion.';
      case AchievementId.reachTissue:
        return 'Multi-cellular cooperation detected across strain field.';
      case AchievementId.reachOrgan:
        return 'Specialized substructures coordinating movement.';
      case AchievementId.reachOrganism:
        return 'Full integrative phenotype achieved. Countdown phase initiated.';
      case AchievementId.organismTimes5:
        return 'Organismic state reached on five independent observation windows.';
      case AchievementId.organismTimes25:
        return 'Twenty-five documented apex integrations. Population stable.';
      case AchievementId.organismTimes100:
        return 'Centennial organismic threshold — exceptional persistence.';
      case AchievementId.collect10Total:
        return 'Ten luminescent orbs catalogued across all expeditions.';
      case AchievementId.collect50Total:
        return 'Fifty orbs assimilated. Energy reserves statistically significant.';
      case AchievementId.collect100Total:
        return 'Century mark of orb uptake recorded in field ledger.';
      case AchievementId.collect500Total:
        return 'Five hundred orbs — strain metabolism hyperactive.';
      case AchievementId.collect1000Total:
        return 'Millennial orb harvest. Subject exhibits compulsive uptake.';
      case AchievementId.collect30InRun:
        return 'Thirty orbs within one continuous traversal — greedy but efficient.';
      case AchievementId.clearMicroverse:
        return 'Microverse survival window completed. Next biome accessible.';
      case AchievementId.clearDeepOcean:
        return 'Oscillating aperture navigation mastered in pelagic zone.';
      case AchievementId.clearNeural:
        return 'Cooldown-gated inversion protocol survived in neural matrix.';
      case AchievementId.clearCosmic:
        return 'Reduced gravitation field transited without ceiling impact.';
      case AchievementId.clearViral:
        return 'Compressing apertures outlasted. Viral biome catalogued complete.';
      case AchievementId.organismInEveryWorld:
        return 'Apex phenotype confirmed in all five biomes.';
      case AchievementId.flawlessRun:
        return 'No wall contact for entire run. Pristine trajectory.';
      case AchievementId.phoenixRun:
        return 'Full de-evolution to molecule, then re-ascension to organism in one run.';
      case AchievementId.batteredSurvivor:
        return 'Ten wall impacts endured; organismic tier still attained.';
      case AchievementId.rapidCell:
        return 'Cellular tier within thirty seconds of run onset.';
    }
  }

  String get redactedHint =>
      '[REDACTED — observation criteria classified. Continue field work.]';
}

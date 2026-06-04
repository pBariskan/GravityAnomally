enum ChallengeMode {
  none,
  speedRun,
  mirror,
  blind;

  String get displayName {
    switch (this) {
      case ChallengeMode.none:
        return 'Standard';
      case ChallengeMode.speedRun:
        return 'Speed Run';
      case ChallengeMode.mirror:
        return 'Mirror Mode';
      case ChallengeMode.blind:
        return 'Blind Mode';
    }
  }

  String get ruleDescription {
    switch (this) {
      case ChallengeMode.none:
        return 'Baseline strain protocol.';
      case ChallengeMode.speedRun:
        return 'All motion +20% — reflexes under compression.';
      case ChallengeMode.mirror:
        return 'Obstacles approach from the right.';
      case ChallengeMode.blind:
        return 'Irregular photic blackout events.';
    }
  }
}

enum PhaseType {
  phase("Phase"),
  controlPhase("ControlPhase"),
  manualPhase("ManualPhase"),
  sequencePhase("SequencePhase");

  final String name;
  const PhaseType(this.name);

  static final Map<String, PhaseType> byName = {};

  static PhaseType? getByName(String name) {
    if (byName.isEmpty) {
      for (PhaseType type in PhaseType.values) {
        byName[type.name] = type;
      }
    }
    return byName[name];
  }
}
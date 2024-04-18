enum  JobState {
  inactive("Inactive"),
  active("Active"),
  paused("Paused"),
  error("Error"),
  aborted("Aborted"),
  complete("Complete");


  final String name;
  const JobState(this.name);

  static final Map<String, JobState> byName = {};

  static JobState? getByName(String name) {
    if (byName.isEmpty) {
      for (JobState status in JobState.values) {
        byName[status.name] = status;
      }
    }
    return byName[name];
  }
}
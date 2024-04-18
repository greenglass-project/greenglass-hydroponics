enum Severity {
  info("Info"),
  warning("Warning"),
  error("Error");

  final String name;

  const Severity(this.name);

  static final Map<String, Severity> byName = {};

  static Severity? getByName(String name) {
    if (byName.isEmpty) {
      for (Severity s in Severity.values) {
        byName[s.name] = s;
      }
    }
    return byName[name];
  }
}

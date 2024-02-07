enum MetricDirection {
  read("read"),
  write("write");

  final String name;

  const MetricDirection(this.name);

  static final Map<String, MetricDirection> byName = {};

  static MetricDirection? getByName(String name) {
    if (byName.isEmpty) {
      for (MetricDirection status in MetricDirection.values) {
        byName[status.name] = status;
      }
    }
    return byName[name];
  }
}
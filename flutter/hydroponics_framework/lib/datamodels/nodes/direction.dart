enum Direction {
  input("Input"),
  output("Output");

  final String name;
  const Direction(this.name);

  static final Map<String, Direction> byName = {};

  static Direction? getByName(String name) {
    if (byName.isEmpty) {
      for (Direction value in Direction.values) {
        byName[value.name] = value;
      }
    }
    return byName[name];
  }

}
enum MetricDataType {
  int8("Int8"),
  int16("Int16"),
  int32("Int32"),
  int64("Int64"),
  uInt8("UInt8"),
  uInt16("UInt16"),
  uInt32("UInt32"),
  uInt64("UInt32"),
  float("Float"),
  double("Double"),
  boolean("Boolean"),
  string("String"),
  dateTime("DateTime"),
  text("Text"),
  unknown("Unknown");

  final String name;
  const MetricDataType(this.name);

  static final Map<String, MetricDataType> byName = {};

  static MetricDataType? getByName(String name) {
    if (byName.isEmpty) {
      for (MetricDataType status in MetricDataType.values) {
        byName[status.name] = status;
      }
    }
    return byName[name];
  }
  //MyEnum.values.byName
}

class StringValue  {
  final String value;
  StringValue(this.value);
  Map<String,dynamic> toJson() => { "value" : value};
  static StringValue fromJson(Map<String,dynamic> json) => StringValue(json["value"]);
}
class IntValue {
  final int value;
  IntValue(this.value);
  Map<String,dynamic> toJson() => {"value" : value};
  static IntValue fromJson(Map<String,dynamic> json) => IntValue(json["value"]);
}
class DoubleValue {
  final double value;
  DoubleValue(this.value);
  Map<String,dynamic> toJson() => {"value" : value};
  static DoubleValue fromJson(Map<String,dynamic> json) => DoubleValue(json["value"]);
}
class BoolValue {
  final bool value;
  BoolValue(this.value);
  Map<String,dynamic> toJson() => {"value" : value};
  static BoolValue fromJson(Map<String,dynamic> json) => BoolValue(json["value"]);
}
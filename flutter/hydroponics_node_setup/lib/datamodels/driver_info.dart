class DriverInfo {
  final String name;
  final String type;

  DriverInfo(this.name, this.type);

  static DriverInfo fromJson(Map<String,dynamic> map)  {
    return DriverInfo(
      map["name"],
      map["type"]
    );
  }
}
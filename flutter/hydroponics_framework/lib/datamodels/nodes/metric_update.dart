import 'metric_data_type.dart';

class MetricUpdate {
  late String nodeId;
  late String name;
  late MetricDataType type;
  late dynamic value;

  MetricUpdate(this.nodeId, this.name, this.type, this.value);

  MetricUpdate.fromJson(Map<String, dynamic> json) {
    nodeId = json["nodeId"];
    name = json["name"];
    type =  MetricDataType.getByName(json["type"])!;
    switch(type) {
      case MetricDataType.int8 :
      case MetricDataType.int16 :
      case MetricDataType.int32 :
      case MetricDataType.int64 :
      case MetricDataType.uInt8 :
      case MetricDataType.uInt16 :
      case MetricDataType.uInt32 :
      case MetricDataType.uInt64 :
        value = json["value"] as int;
        break;

      case MetricDataType.float :
      case MetricDataType.double :
        value = json["value"] as double;
        break;

      case MetricDataType.boolean :
        value = json["value"] == "true";
        break;

      case MetricDataType.dateTime :
        value = DateTime.parse(json["value"] as String);
        break;

      case MetricDataType.string :
      case MetricDataType.text :
        value = json["value"] as String;
        break;
      case MetricDataType.unknown:
        value = null;
        break;
    }
  }

  Map<String, Object> toMap() {
    Map<String, Object> map = {};
    map["nodeId"] = nodeId;
    map["name"] = name;
    map["type"] = type.name;

    switch(type) {
      case MetricDataType.int8 :
      case MetricDataType.int16 :
      case MetricDataType.int32 :
      case MetricDataType.int64 :
      case MetricDataType.uInt8 :
      case MetricDataType.uInt16 :
      case MetricDataType.uInt32 :
      case MetricDataType.uInt64 :
      map["value"] = value as int;
        break;

      case MetricDataType.float :
      case MetricDataType.double :
        map["value"] = value as double;
        break;

      case MetricDataType.boolean :
        map["value"] = value as bool;
        break;

      case MetricDataType.dateTime :
        map["value"] = (value as DateTime).toString();
        break;

      case MetricDataType.string :
      case MetricDataType.text :
      map["value"] = value as String;
        break;
      case MetricDataType.unknown:
        value = null;
        break;
    }
  return map;
 }
}

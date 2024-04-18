import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'metric_data_type.dart';

class MetricValue {
 final MetricDataType type;
 final dynamic value;
 final DateTime timestamp = DateTime.now();

 final logger = Logger();

 MetricValue({required this.type, this.value});

 static MetricValue fromJson(Map<String, dynamic> json) {
  MetricDataType type =  MetricDataType.getByName(json["type"])!;
  dynamic value;

  if(json["value"] != null) {
   switch (type) {
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
     value = json["value"] as bool;
     break;

    case MetricDataType.dateTime :
     value = DateTime.parse(json["value"] as String);
     break;

    case MetricDataType.string :
    case MetricDataType.text :
     value = json["value"] as String;
     break;
    default :
     value = null;
   }
  } else {
   value = null;
  }
  return MetricValue(type: type, value: value);
 }

 Map<String, Object> toMap() {
  return  {
   "type" : type.name,
   "value" : value,
   "timestamp" : DateFormat("yyyy-MM-ddTHH:mm:ss").format(timestamp)
  };
 }
}
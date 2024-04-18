import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import 'metric_data_type.dart';
import 'package:hydroponics_framework/utilities.dart';

class MetricValue {
 final MetricDataType type;
 final dynamic value;
 final DateTime timestamp;

 final logger = Logger();

 MetricValue({required this.type,this.value, required this.timestamp});

 static MetricValue fromJson(Map<String, dynamic> json) {
  MetricDataType type =  MetricDataType.getByName(json["type"])!;
  DateTime timestamp = json["timestamp"] != null ?
  DateTime.parse(json["timestamp"]) : DateTime.now();
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
  return MetricValue(type: type, value: value, timestamp: timestamp);
 }

 static MetricValue fromJsonData(Uint8List data) {
  final string = Utilities.convertUint8ListToString(data);
  final json = jsonDecode(string);
  MetricDataType type =  MetricDataType.getByName(json["type"])!;
  DateTime timestamp = json["timestamp"] != null ?
    DateTime.parse(json["timestamp"]) : DateTime.now();
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
  return MetricValue(type: type, value: value, timestamp: timestamp);
 }

 Map<String, Object> toMap() {
  return  {
   "type" : type.name,
   "value" : value,
   "timestamp" : DateFormat("yyyy-MM-ddTHH:mm:ss").format(timestamp)
  };
 }
}
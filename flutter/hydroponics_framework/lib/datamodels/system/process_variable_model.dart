import 'package:hydroponics_framework/datamodels/nodes/metric_data_type.dart';

class ProcessVariableModel  {
  late String variableId;
  late String name;
  late String description;
  late MetricDataType type;
  late double minValue;
  late double maxValue;
  late double defaultt;
  late double tolerance;
  late String units;
  late int decimalPlaces;

  ProcessVariableModel({
    required this.variableId,
    required this.name,
    required this.description,
    required this.type,
    required this.minValue,
    required this.maxValue,
    required this.defaultt,
    required this.tolerance,
    required this.units,
    required this.decimalPlaces
  });

  ProcessVariableModel.fromJson(Map<String, dynamic> json) {
    variableId = json["variableId"];
    name = json["name"];
    description = json["description"];
    type = MetricDataType.getByName(json["type"])!;
    minValue = json["minValue"];
    maxValue = json["maxValue"];
    defaultt = json["default"];
    tolerance = json["tolerance"];
    units = json["units"];
    decimalPlaces = json["decimalPlaces"];
  }
}

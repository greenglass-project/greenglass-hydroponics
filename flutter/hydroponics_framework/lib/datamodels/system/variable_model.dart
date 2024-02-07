import 'package:hydroponics_framework/datamodels/nodes/metric_data_type.dart';

class VariableModel {
  late String variableId;
  late String name;
  late String description;
  late MetricDataType type;

  VariableModel({
    required this.variableId,
    required this.name,
    required this.description,
    required this.type,
  });

  VariableModel.fromJson(Map<String, dynamic> json) {
    variableId = json["variableId"];
    name = json["name"];
    description = json["description"];
    type = MetricDataType.getByName(json["type"])!;
  }
}
import '../nodes/metric_data_type.dart';

class ProcessVariableTypeModel {
  late String name;
  late MetricDataType type;
  late String description;

  ProcessVariableTypeModel(this.name, this.type, this.description);

  ProcessVariableTypeModel.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    type = MetricDataType.getByName(json["type"])!;
    description = json["description"];
  }

}
import 'package:hydroponics_framework/datamodels/nodes/metric_data_type.dart';

class ScheduleTypeModel {
  late String name;
  late MetricDataType type;
  late String description;

  ScheduleTypeModel(this.name, this.type, this.description);

  ScheduleTypeModel.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    type = MetricDataType.getByName(json["type"])!;
    description = json["description"];
  }
}
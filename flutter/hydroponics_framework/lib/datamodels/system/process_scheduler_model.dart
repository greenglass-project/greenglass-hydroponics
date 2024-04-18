import 'package:hydroponics_framework/datamodels/system/process_model.dart';

class ProcessSchedulerModel {
  late String schedulerId;
  late String name;
  late String description;
  late List<ProcessModel> processes;

  ProcessSchedulerModel({
    required this.schedulerId,
    required this.name,
    required this.description,
    required this.processes,
  });

  ProcessSchedulerModel.fromJson(Map<String,dynamic> json) {
    schedulerId = json["schedulerId"];
    name = json["name"];
    description = json["description"];
    processes = List<Map<String, dynamic>>.from(json["processes"])
        .map((p) => ProcessModel.fromJson(p))
        .toList();
  }
}
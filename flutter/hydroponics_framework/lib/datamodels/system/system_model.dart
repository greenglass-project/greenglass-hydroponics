import 'package:hydroponics_framework/datamodels/system/process_scheduler_model.dart';

import 'process_model.dart';

class SystemModel {
  late String systemId;
  late String name;
  late String description;
  late List<ProcessSchedulerModel> processSchedulers;

  SystemModel({
    required this.systemId,
    required this.name,
    required this.description,
    required this.processSchedulers,
  });

  SystemModel.fromJson(Map<String,dynamic> json) {
    systemId = json["systemId"];
    name = json["name"];
    description = json["description"];
    processSchedulers = List<Map<String,dynamic>>.from(json["processSchedulers"])
        .map((s) => ProcessSchedulerModel.fromJson(s))
        .toList();

  }
}
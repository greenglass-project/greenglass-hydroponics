import 'package:hydroponics_framework/datamodels/system/fuzzy_logic_process_model.dart';
import 'package:hydroponics_framework/datamodels/system/process_variable_model.dart';
import 'package:hydroponics_framework/datamodels/system/state_controller_process_model.dart';
import 'package:hydroponics_framework/datamodels/system/variable_model.dart';

class ProcessModel {
  String process;
  String processId;
  String name;
  String description;
  List<ProcessVariableModel>? processVariables;
  List<VariableModel>? manipulatedVariables;

  ProcessModel({
      required this.process,
      required this.processId,
      required this.name,
      required this.description,
      this.processVariables,
      this.manipulatedVariables});

  static ProcessModel fromJson(Map<String,dynamic>  json) {
    return ProcessModel(
        process : json["process"],
        processId : json["processId"],
        name : json["name"],
        description : json["description"],
        processVariables : json["processVariables"] != null ?
            List<Map<String,dynamic>>.from(json["processVariables"])
              .map((pv) => ProcessVariableModel.fromJson(pv))
              .toList()
            : null,
        manipulatedVariables : json["manipulatedVariables"] != null ?
            List<Map<String,dynamic>>.from(json["manipulatedVariables"])
              .map((pv) => VariableModel.fromJson(pv))
              .toList()
            : null
    );
  }
}


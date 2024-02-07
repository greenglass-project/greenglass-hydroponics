import 'package:hydroponics_framework/datamodels/system/process_variable_model.dart';

import 'process_model.dart';
import 'variable_model.dart';

class StateControlledProcessModel extends ProcessModel {
  late String processId;
  late String name;
  late String description;
  late List<VariableModel>? manipulatedVariables;
  StateControlledProcessModel({
    required super.process,
    required super.processId,
    required super.name,
    required super.description,
    super.processVariables,
    super.manipulatedVariables
  });

  static StateControlledProcessModel fromJson(Map<String,dynamic>  json) {
    return StateControlledProcessModel(
        process : json["process"],
        processId : json["processId"],
        name : json["name"],
        description : json["description"],
        processVariables :
        List<Map<String,dynamic>>.from(json["processVariables"])
            .map((pv) => ProcessVariableModel.fromJson(pv))
            .toList(),
        manipulatedVariables :
        List<Map<String,dynamic>>.from(json["manipulatedVariables"])
            .map((pv) => VariableModel.fromJson(pv))
            .toList()
    );
  }

}
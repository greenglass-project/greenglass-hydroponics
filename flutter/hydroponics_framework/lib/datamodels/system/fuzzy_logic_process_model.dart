import 'process_model.dart';
import 'process_variable_model.dart';
import 'variable_model.dart';

class FuzzyLogicProcessModel extends ProcessModel {

  FuzzyLogicProcessModel({
  required super.process,
    required super.processId,
    required super.name,
    required super.description,
    super.processVariables,
    super.manipulatedVariables
  });

  static FuzzyLogicProcessModel fromJson(Map<String,dynamic>  json) {
    return FuzzyLogicProcessModel(
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
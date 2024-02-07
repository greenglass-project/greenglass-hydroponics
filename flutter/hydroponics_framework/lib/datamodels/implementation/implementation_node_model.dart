import 'implementation_variable_metric_model.dart';

class ImplementationNodeModel {

  late String implNodeId;
  late String type;
  late String description;
  late List<ImplementationVariableMetricModel> variables;

  ImplementationNodeModel(this.implNodeId, this.type, this.description, this.variables);

  ImplementationNodeModel.fromJson(Map<String,dynamic> json) {
    implNodeId = json["implNodeId"];
    type = json["type"];
    description = json["description"];
    variables = List<Map<String,dynamic>>.from(json["variables"])
                  .map((v) => ImplementationVariableMetricModel.fromJson(v))
                  .toList();
  }
}
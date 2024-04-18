class ImplementationVariableMetricModel {
  late String variableId;
  late String name;

  ImplementationVariableMetricModel(this.variableId, this.name);

  ImplementationVariableMetricModel.fromJson(Map<String,dynamic> json) {
    variableId = json["variableId"];
    name = json["metricName"];
  }
}
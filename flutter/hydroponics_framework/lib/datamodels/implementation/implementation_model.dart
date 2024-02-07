import 'implementation_node_model.dart';

class ImplementationModel {
  late String implementationId;
  late String name;
  late String systemId;
  late List<ImplementationNodeModel> nodes;

  ImplementationModel(
      this.implementationId,
      this.name,
      this.systemId,
      this.nodes);

  ImplementationModel.fromJson(Map<String,dynamic> json) {
    implementationId = json["implementationId"];
    name = json["name"];
    systemId = json["systemId"];
    nodes = List<Map<String,dynamic>>.from(json["nodes"])
        .map((n) => ImplementationNodeModel.fromJson(n))
        .toList();
  }
}
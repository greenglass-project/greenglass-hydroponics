import 'package:hydroponics_framework/datamodels/installation/physical_node_model.dart';
import 'package:hydroponics_framework/datamodels/json_model.dart';

class InstallationModel extends JsonModel {
  final String installationId;
  final String implementationId;
  final String name;
  final String description;
  final List<PhysicalNodeModel> physicalNodes;

  InstallationModel({
    required this.installationId,
    required this.implementationId,
    required this.name,
    required this.description,
    required this.physicalNodes
  }) : super();

  static InstallationModel fromJson(Map<String, dynamic> json) =>
      InstallationModel(
        installationId : json["installationId"],
        implementationId : json["implementationId"],
        name : json["name"],
        description : json["description"],
        physicalNodes : List<Map<String,dynamic>>.from(json["physicalNodes"])
            .map((p) => PhysicalNodeModel.fromJson(p))
            .toList()
  );


  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map["installationId"] = installationId;
    map["implementationId"] = implementationId;
    map["name"] = name;
    map["description"] = description;
    map["physicalNodes"] = physicalNodes.map((pn) => pn.toJson()).toList();
    return map;
  }
}

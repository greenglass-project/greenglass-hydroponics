class PhysicalNodeModel {
  late String nodeId;
  late String implNodeId;

  PhysicalNodeModel(this.nodeId, this.implNodeId);

  PhysicalNodeModel.fromJson(Map<String,dynamic> json) {
    nodeId = json["nodeId"];
    implNodeId = json["implNodeId"];
  }

  Map<String,dynamic> toJson() {
    return {
      "nodeId": nodeId,
      "implNodeId": implNodeId
    };
  }
}
import 'dart:convert';

class SettingsModel {

  final String nodeType;
  final String nodeId;
  final String groupId;
  final String hostId;
  final String broker;

  SettingsModel(
      this.nodeType,
      this.nodeId,
      this.groupId,
      this.hostId,
      this.broker );

  bool isEmpty() => nodeType.isEmpty && nodeId.isEmpty && groupId.isEmpty && hostId.isEmpty && broker.isEmpty;

  static fromJson(Map<String, dynamic> json) =>
      SettingsModel(
        json["nodeType"],
        json["nodeId"],
        json["groupId"],
        json["hostId"],
        json["broker"],
      );

  Map<String,dynamic> toJson() => {
    "nodeType" : nodeType,
    "nodeId" : nodeId,
    "groupId" : groupId,
    "hostId" : hostId,
    "broker" : broker
  };
}
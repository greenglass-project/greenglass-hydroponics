import '../json_model.dart';

class MasterConfigModel extends JsonModel {

  final String hostId;
  final String groupId;
  final String timeZone;
  final String influxdbKey;

  MasterConfigModel({
    required this.hostId,
    required this.groupId,
    required this.timeZone,
    required this.influxdbKey,
  });

  static MasterConfigModel fromJson(Map<String, dynamic> json) {
    return MasterConfigModel(
        hostId: json["hostId"],
        groupId: json["groupId"],
        timeZone: json["timeZone"],
        influxdbKey: json["influxdbKey"]
    );
  }
  Map<String, dynamic> toJson() =>
     {
       "hostId" : hostId,
       "groupId" : groupId,
       "timeZone" : timeZone,
       "influxdbKey" : influxdbKey
     };
}
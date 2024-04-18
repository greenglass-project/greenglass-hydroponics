import 'dart:convert';
import 'dart:typed_data';

import 'package:hydroponics_framework/datamodels/logevents/severity.dart';
import 'package:hydroponics_framework/utilities.dart';

class InstallationLogEvent {

  late DateTime timeStamp;
  late String installationId;
  late Severity severity;
  late String message;

  InstallationLogEvent(this.timeStamp,
      this.installationId,
      this.severity,
      this.message);

  InstallationLogEvent.fromJson(Map<String, dynamic> json) {
    timeStamp = DateTime.parse(json["timeStamp"]);
    installationId = json["installationId"];
    severity = Severity.getByName(json["severity"])!;
    message = json["message"];
  }

  InstallationLogEvent.fromJsonData(Uint8List data) {
    final json = jsonDecode(Utilities.convertUint8ListToString(data));
    timeStamp = DateTime.parse(json["timeStamp"]);
    installationId = json["installationId"];
    severity = Severity.getByName(json["severity"])!;
    message = json["message"];
  }
}

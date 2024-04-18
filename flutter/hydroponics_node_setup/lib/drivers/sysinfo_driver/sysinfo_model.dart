class SysinfoModel {
  final String hardwareMake;
  final String hardwareModel;
  final String os;
  final String osVersion;
  final String ipAddress;
  final String host;

  SysinfoModel(this.hardwareMake, this.hardwareModel, this.os, this.osVersion, this.ipAddress, this.host);
  static SysinfoModel fromJson(Map<String,dynamic> json) {
    return SysinfoModel(
      json["hardwareMake"],
      json["hardwareModel"],
      json["os"],
      json["osVersion"],
      json["ipAddress"],
      json["host"],
    );
  }
}
class InstallationViewModel {
  late String installationId;
  late String instanceName;
  late String implementationId;
  late String implementationName;
  late String systemId;
  late String systemName;

  InstallationViewModel(
      this.installationId,
      this.instanceName,
      this.implementationId,
      this.implementationName,
      this.systemId,
      this.systemName,
      );

  InstallationViewModel.fromJson(Map<String, dynamic> json) {
    installationId = json["installationId"];
    instanceName = json["instanceName"];
    implementationId = json["implementationId"];
    implementationName = json["implementationName"];
    systemId = json["systemId"];
    systemName = json["systemName"];
  }
}

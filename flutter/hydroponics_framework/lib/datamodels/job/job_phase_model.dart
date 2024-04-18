class JobPhaseModel {
  final String jobId;
  final String phaseId;

  JobPhaseModel({required this.jobId, required this.phaseId});

  static JobPhaseModel fromJson(Map<String, dynamic> json) {
    return JobPhaseModel(
        jobId: json["jobId"],
        phaseId: json["phaseId"]
    );
  }
}
import 'job_state.dart';
import 'mutable_job_model.dart';

class JobModel {
  late String jobId;
  late JobState state;
  late DateTime startTime;
  late DateTime? endTime;
  late String installationId;
  late String recipeId;
  late String? phaseId;
  late DateTime? phaseEnd;

  JobModel({
    required this.jobId,
    required this.state,
    required this.startTime,
    this.endTime,
    required this.installationId,
    required this.recipeId,
    this.phaseId,
    this.phaseEnd
  });

  static JobModel fromJson(Map<String,dynamic> json) {
    String jobId = json["jobId"];
    JobState state = JobState.getByName(json["state"])!;
    DateTime startTime = DateTime.parse(json["startTime"]);
    DateTime? endTime;
    if(json["endTime"] != null) {
      endTime = DateTime.parse(json["endTime"]);
    } else {
      endTime = null;
    }
    String installationId = json["installationId"];
    String recipeId = json["recipeId"];
    String? phaseId = json["phaseId"];
    DateTime? phaseEnd;
    if(json["phaseEnd"] != null) {
      phaseEnd = DateTime.parse(json["phaseEnd"]);
    } else {
      phaseEnd = null;
    }

    return JobModel(
        jobId: jobId,
        state : state,
        startTime : startTime,
        endTime : endTime,
        installationId : installationId,
        recipeId : recipeId,
        phaseId: phaseId,
        phaseEnd: phaseEnd

    );
  }

  MutableJobModel toMutableJobModel() {
    return MutableJobModel(
        jobId: jobId,
        state : state,
        startTime : startTime,
        endTime : endTime,
        installationId : installationId,
        recipeId : recipeId,
        phaseId: phaseId,
        phaseEnd: phaseEnd
    );
  }
}
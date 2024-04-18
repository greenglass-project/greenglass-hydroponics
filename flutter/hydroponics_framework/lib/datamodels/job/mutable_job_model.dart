import 'job_state.dart';

class MutableJobModel {
  String jobId;
  JobState state;
  DateTime startTime;
  DateTime? endTime;
  String installationId;
  String recipeId;
  String? phaseId;
  DateTime? phaseEnd;

  MutableJobModel({
    required this.jobId,
    required this.state,
    required this.startTime,
    this.endTime,
    required this.installationId,
    required this.recipeId,
    this.phaseId,
    this.phaseEnd
  });
}
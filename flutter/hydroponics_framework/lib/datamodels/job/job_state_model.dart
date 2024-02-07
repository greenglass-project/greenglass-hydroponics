import 'job_state.dart';

class JobStateModel {
  final String jobId;
  final JobState state;

  JobStateModel({required this.jobId, required this.state});

  static JobStateModel fromJson(Map<String,dynamic> json) {
    return JobStateModel(
        jobId: json["jobId"],
        state: JobState.getByName(json["state"])!
    );
  }
}
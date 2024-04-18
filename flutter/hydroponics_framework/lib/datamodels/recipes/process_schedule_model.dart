import 'package:equatable/equatable.dart';
import 'package:hydroponics_framework/datamodels/json_model.dart';

import 'mutable_process_schedule_model.dart';

class ProcessScheduleModel extends Equatable implements JsonModel {

  final String phaseId;
  final String schedulerId;
  final int? start;
  final int? end;
  final int? frequency;
  final int? duration;

  const ProcessScheduleModel({
    required this.phaseId,
    required this.schedulerId,
    required this.start,
    required this.end,
    required this.frequency,
    required this.duration});

  static ProcessScheduleModel fromJson(Map<String,dynamic> json) =>
      ProcessScheduleModel(
          phaseId: json["phaseId"],
          schedulerId: json["schedulerId"],
          start: json["start"],
          end: json["end"],
          frequency : json["frequency"],
          duration: json["duration"]
      );

  MutableProcessScheduleModel toMutableProcessScheduleModel() =>
      MutableProcessScheduleModel(
          phaseId : phaseId,
          schedulerId : schedulerId,
          start : start,
          end : end,
          frequency : frequency,
          duration : duration
      );

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map["phaseId"] = phaseId;
    map["schedulerId"] = schedulerId;
    if(start != null) { map["start"] = start; }
    if(end != null) { map["end"] = end; }
    if(frequency != null) { map["frequency"] = frequency; }
    if(duration != null) { map["duration"] = duration; }

    return map;
  }

  @override
  List<Object?> get props => [phaseId, schedulerId, start, end, frequency, duration];
}

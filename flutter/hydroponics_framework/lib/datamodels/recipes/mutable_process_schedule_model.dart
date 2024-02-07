import 'package:hydroponics_framework/datamodels/recipes/process_schedule_model.dart';

class MutableProcessScheduleModel {

  late String phaseId;
  late String schedulerId;
  late int? start;
  late int? end;
  late int? frequency;
  late int? duration;

  MutableProcessScheduleModel({
    required this.phaseId,
    required this.schedulerId,
    required this.start,
    required this.end,
    required this.frequency,
    required this.duration
  });

  MutableProcessScheduleModel.fromProcessScheduleModel(ProcessScheduleModel model) {
    phaseId = model.phaseId;
    schedulerId = model.schedulerId;
    start = model.start;
    end = model.end;
    frequency = model.frequency;
    duration = model.duration;
  }
  ProcessScheduleModel toProcessScheduleModel() =>
    ProcessScheduleModel(
        phaseId : phaseId,
        schedulerId : schedulerId,
        start : start,
        end : end,
        frequency : frequency,
        duration : duration
    );
}

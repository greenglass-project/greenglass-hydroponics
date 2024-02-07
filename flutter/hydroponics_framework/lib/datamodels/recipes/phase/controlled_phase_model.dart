import 'package:hydroponics_framework/datamodels/recipes/phase/phase_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/phase_type.dart';

import 'package:hydroponics_framework/datamodels/recipes/process_schedule_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/setpoint_model.dart';

class ControlledPhaseModel extends PhaseModel {
  final List<ProcessScheduleModel>? processSchedules;
  final List<SetpointModel>? setPoints;

  const ControlledPhaseModel({
    required super.phaseId,
    required super.name,
    required super.description,
    required super.duration,
    this.processSchedules,
    this.setPoints
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json["type"] = PhaseType.controlPhase.name;
    json["phaseId"] = phaseId;
    json["name"] = name;
    json["description"] = description;
    json["duration"] = duration;
    if (processSchedules != null) {
      json["processSchedules"] =
          processSchedules!.map((ps) => ps.toJson()).toList();
    }
    if (setPoints != null) {
      json["setPoints"] = setPoints!.map((sp) => sp.toJson()).toList();
    }
    return json;
  }

  static ControlledPhaseModel fromJson(Map<String, dynamic> json) {
    String phaseId = json["phaseId"];
    String name = json["name"];
    String description = json["description"];
    int duration = json["duration"];

    List<ProcessScheduleModel>? processSchedules;
    if (json["processSchedules"] != null) {
      processSchedules =
          List<Map<String, dynamic>>.from(json["processSchedules"])
              .map((p) => ProcessScheduleModel.fromJson(p)).toList();
    }
    List<SetpointModel>? setPoints;
    if (json["setPoints"] != null) {
      setPoints = List<Map<String, dynamic>>.from(json["setPoints"])
          .map((s) => SetpointModel.fromJson(s)).toList();
    }

    return ControlledPhaseModel(
        phaseId: phaseId,
        name: name,
        description: description,
        duration: duration,
        processSchedules: processSchedules,
        setPoints: setPoints
    );
  }

  SetpointModel? setPointForVariable(String variableId) =>
      setPoints?.firstWhere((sp) => sp.variableId == variableId);


  ProcessScheduleModel? scheduleForScheduler(String schedulerId) =>
      processSchedules?.firstWhere((ps) => ps.schedulerId == schedulerId);
}
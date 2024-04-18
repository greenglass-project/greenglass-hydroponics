import 'package:equatable/equatable.dart';
import 'package:hydroponics_framework/datamodels/json_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/phase_type.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/sequence_phase_model.dart';

import 'controlled_phase_model.dart';
import 'manual_phase_model.dart';


class PhaseModel extends Equatable implements JsonModel {
  final String phaseId;
  final String name;
  final String description;
  final int duration;

  const PhaseModel({
    required this.phaseId,
    required this.name,
    required this.description,
    required this.duration

  });

  static PhaseModel fromJson(Map<String,dynamic> json) {
    PhaseType type = PhaseType.getByName(json["type"]) ?? PhaseType.phase;
    switch(type) {
      case PhaseType.controlPhase:
        return ControlledPhaseModel.fromJson(json);
      case PhaseType.manualPhase:
        return ManualPhaseModel.fromJson(json);
      default:
        return SequencePhaseModel.fromJson(json);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json["phaseId"] = phaseId;
    json["name"] = name;
    json["description"] = description;
    json["duration"] = duration;
    return json;
  }

  @override
  List<Object?> get props => [phaseId, name, description, duration];
}
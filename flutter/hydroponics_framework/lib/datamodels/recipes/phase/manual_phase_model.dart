import 'package:hydroponics_framework/datamodels/recipes/phase/phase_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/phase_type.dart';

class ManualPhaseModel extends PhaseModel {

  const ManualPhaseModel({
    required super.phaseId,
    required super.name,
    required super.description,
    required super.duration
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json["type"] = PhaseType.manualPhase.name;
    json["phaseId"] = phaseId;
    json["name"] = name;
    json["description"] = description;
    json["duration"] = duration;
    return json;
  }

  static ManualPhaseModel fromJson(Map<String, dynamic> json) {
    return ManualPhaseModel(
        phaseId : json["phaseId"],
        name : json["name"],
        description: json["description"],
        duration : json["duration"]
    );
  }
}

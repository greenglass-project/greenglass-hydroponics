import 'package:hydroponics_framework/datamodels/recipes/phase/phase_model.dart';

class SequencePhaseModel extends PhaseModel {


  const SequencePhaseModel({
    required super.phaseId,
    required super.name,
    required super.description,
    required super.duration
  });

  static SequencePhaseModel fromJson(Map<String, dynamic> json) {
    return SequencePhaseModel(
        phaseId : json["json"],
        name : json["name"],
        description: json["description"],
        duration: json["duration"]
    );
  }
}

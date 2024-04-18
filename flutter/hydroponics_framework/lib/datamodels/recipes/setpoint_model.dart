import 'package:equatable/equatable.dart';
import 'package:hydroponics_framework/datamodels/json_model.dart';

import 'mutable_setpoint_model.dart';

class  SetpointModel extends Equatable implements JsonModel {
  final String phaseId ;
  final String variableId;
  final double setPoint;

  const SetpointModel({required this.phaseId, required this.variableId, required this.setPoint});

  static SetpointModel fromJson(Map<String,dynamic> json) =>
      SetpointModel(
        phaseId: json["phaseId"],
        variableId : json["variableId"],
        setPoint : json["setPoint"]
      );

  MutableSetpointModel toMutableSetpointModel() =>
      MutableSetpointModel(
          phaseId : phaseId,
          variableId : variableId,
          setPoint : setPoint
      );

  @override
  Map<String, dynamic> toJson() {
    return {
      "phaseId" : phaseId,
      "variableId" : variableId,
      "setPoint" : setPoint,
    };
  }

  @override
  List<Object?> get props => [phaseId, variableId, setPoint];
}
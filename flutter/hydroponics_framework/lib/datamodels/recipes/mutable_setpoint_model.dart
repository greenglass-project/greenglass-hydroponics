import 'package:hydroponics_framework/datamodels/recipes/setpoint_model.dart';

class  MutableSetpointModel {
  late String phaseId;
  late String variableId;
  late double setPoint;

  MutableSetpointModel({
    required this.phaseId,
    required this.variableId,
    required this.setPoint
  });

  MutableSetpointModel.fromSetpointModel(SetpointModel model) {
    phaseId = model.phaseId;
    variableId = model.variableId;
    setPoint = model.setPoint;
  }

  SetpointModel toSetpointModel() =>
      SetpointModel(
          phaseId : phaseId,
          variableId : variableId,
          setPoint : setPoint
      );
}
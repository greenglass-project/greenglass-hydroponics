import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:uuid/uuid.dart';

import 'package:hydroponics_framework/datamodels/recipes/mutable_process_schedule_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/mutable_setpoint_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/controlled_phase_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/process_schedule_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/setpoint_model.dart';
import 'package:hydroponics_framework/datamodels/system/process_model.dart';
import 'package:hydroponics_framework/datamodels/system/process_scheduler_model.dart';
import 'package:hydroponics_framework/datamodels/system/process_variable_model.dart';
import 'package:hydroponics_framework/datamodels/system/system_model.dart';

import '../phase_list_provider.dart';

class ProcessScheduleContext {
  String scheduleId;
  String scheduleName;
  String schedulerId;
  MutableProcessScheduleModel? schedule;
  ProcessScheduleContext(this.scheduleId, this.scheduleName, this.schedulerId);
}

class ProcessVariableContext {
  ProcessVariableModel variable;
  MutableSetpointModel? value;
  ProcessVariableContext(this.variable);
}

mixin ControlledPhaseMixin <T extends StatefulWidget> on State<T> {

  String? name;
  String? description;
  int? duration;
  List<ProcessScheduleModel>? processSchedules;
  List<SetpointModel>? setPoints;
  late String phaseId;
  late PhaseListProvider phases;

  final double nameWidth = 500;
  final double dialogWidth = 500;


  Map<String, ProcessScheduleContext> processSchedulers = {};
  Map<String, ProcessVariableContext> processVariables = {};

  TextStyle textStyle(BuildContext context) =>
      Theme
          .of(context)
          .textTheme
          .labelSmall!;

  TextStyle headerStyle(BuildContext context) =>
      Theme
          .of(context)
          .textTheme
          .labelMedium!;

  late ControlledPhaseModel? phaseModel;
  late SystemModel system;

  @override
  void initState() {
    super.initState();
    _createContext();
  }

  Widget header(String text, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Center(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Text(text,
                    style: Theme.of(context).textTheme.labelMedium))));
  }

  _createContext() {
    for (ProcessSchedulerModel ps in system.processSchedulers) {
      processSchedulers[ps.schedulerId] =
          ProcessScheduleContext(ps.schedulerId, ps.name, ps.schedulerId);
      for (ProcessModel pm in ps.processes) {
        if (pm.processVariables != null) {
          for (ProcessVariableModel pvm in pm.processVariables!) {
            processVariables[pvm.variableId] = ProcessVariableContext(pvm);
          }
        }
      }
    }
    if(phaseModel != null) {
      phaseId = phaseModel!.phaseId;
      if(phaseModel!.processSchedules != null) {
        for (ProcessScheduleModel ps in phaseModel!.processSchedules!) {
          processSchedulers[ps.schedulerId]?.schedule = ps.toMutableProcessScheduleModel();
        }
      }
      if(phaseModel!.setPoints != null) {
        for(SetpointModel sp in phaseModel!.setPoints!) {
          processVariables[sp.variableId]?.value = sp.toMutableSetpointModel();
        }
      }
    } else {
      phaseId =  Uuid().v4();
      for(ProcessScheduleContext psc in processSchedulers.values) {
        psc.schedule = MutableProcessScheduleModel(
            phaseId : phaseId,
            schedulerId : psc.schedulerId,
            start : 12,
            end : 13,
            frequency : null,
            duration: null
        );
      }
      for(ProcessVariableContext pvc in processVariables.values) {
        pvc.value = MutableSetpointModel(
            phaseId: phaseId,
            variableId: pvc.variable.variableId,
            setPoint: pvc.variable.defaultt
        );
      }
    }
    int x=0;
  }

}

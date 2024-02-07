import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:hydroponics_framework/datamodels/recipes/mutable_process_schedule_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/controlled_phase_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/process_schedule_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/setpoint_model.dart';
import 'package:hydroponics_framework/datamodels/system/process_model.dart';
import 'package:hydroponics_framework/datamodels/system/process_scheduler_model.dart';
import 'package:hydroponics_framework/datamodels/system/process_variable_model.dart';
import 'package:hydroponics_framework/datamodels/system/system_model.dart';

import 'package:hydroponics_panel/screens/recipe/screen_mode.dart';
import 'package:hydroponics_panel/screens/recipe/phases/phase_list_provider.dart';

import 'controlled_phase_edit_dialog.dart';
import 'controlled_phase_mixin.dart';

class ProcessScheduleText {
  final MutableProcessScheduleModel schedule;

  ProcessScheduleText(this.schedule);

  final format = NumberFormat("00");

  String toText() {
    StringBuffer sb = StringBuffer();
    bool isEvery = false;
    if (schedule.start == null && schedule.end == null) {
      isEvery = true;
    }

    if (isEvery) {
      sb.write("Every ");
      if (schedule.frequency! < 120) {
        sb.write(schedule.frequency!);
        sb.write(" mins ");
      } else {
        sb.write(schedule.frequency! ~/ 60);
        sb.write(" hours ");
      }

      sb.write(" for ");
      if (schedule.duration! < 120) {
        sb.write(schedule.duration!);
        sb.write(" mins ");
      } else {
        sb.write(schedule.duration! ~/ 60);
        sb.write(" hours ");
      }
    } else {
      sb.write("Between ");
      sb.write(format.format(schedule.start));
      sb.write(":00  and ");
      sb.write(format.format(schedule.end));
      sb.write(":00");
    }

    return sb.toString();
  }
}

class ControlledPhaseViewComponent extends StatefulWidget {
  final SystemModel system;
  final ControlledPhaseModel phaseModel;
  final PhaseListProvider phases;
  final ScreenMode mode;

  const ControlledPhaseViewComponent({
    required this.system,
    required this.phaseModel,
    required this.phases,
    this.mode = ScreenMode.view,
    super.key
  });

  @override
  State<StatefulWidget> createState() => _ControlledPhaseViewComponentState();
}

class _ControlledPhaseViewComponentState
    extends State<ControlledPhaseViewComponent> with ControlledPhaseMixin {

  late ScreenMode mode;

  @override
  void initState() {
    phases = widget.phases;
    system = widget.system;
    phaseModel = widget.phaseModel;
    mode = widget.mode;

    // The order of super.initState() is important because it initialises
    // processSchedulers and processVariables maps
    super.initState();

    if (phaseModel!.processSchedules != null) {
      for (ProcessScheduleModel ps in phaseModel!.processSchedules!) {
        processSchedulers[ps.schedulerId]?.schedule =
            ps.toMutableProcessScheduleModel();
      }
    }
    if (phaseModel!.setPoints != null) {
      for (SetpointModel sp in phaseModel!.setPoints!) {
        processVariables[sp.variableId]?.value = sp.toMutableSetpointModel();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.black,
      margin: const EdgeInsetsDirectional.only(start: 10, end: 0),
      shape:
          const RoundedRectangleBorder(side: BorderSide(color: Colors.white)),
      child: Column(children: [
        _viewHeader("Controlled phase", context),
        Row(children: [
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(50, 20, 30, 30),
                  child: Text("Name",
                      style: Theme.of(context).textTheme.labelSmall))),
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(50, 20, 30, 30),
                  child: Text("${phaseModel?.name}",
                      style: Theme.of(context).textTheme.labelSmall))),
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(50, 20, 30, 30),
                  child: Text("Duration (days)",
                      style: Theme.of(context).textTheme.labelSmall))),
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(50, 20, 30, 30),
                  child: Text("${phaseModel?.duration}",
                      style: Theme.of(context).textTheme.labelSmall))),
        ]),
        Row(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 30, 20),
              child: Text("Settings",
                  style: Theme.of(context).textTheme.labelSmall))
        ]),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                child: ListView(children: _rows()))),
      ]),
    );
  }

  Widget _scheduleRow(ProcessScheduleContext ctx) {
    List<Widget> row = [];
    row.add(Expanded(
      flex: 1,
      child: Row(children: [
        const Icon(Icons.schedule, color: Colors.white54, size: 40),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
          child: Text(ctx.scheduleName, style: textStyle(context)),
        )
      ]),
    ));
    row.add(Expanded(
        flex: 1,
        child: Text(
            ProcessScheduleText(
              ctx.schedule!,
            ).toText(),
            style: textStyle(context))));
    return Row(children: row);
  }

  List<Widget> _rows() {
    List<Widget> list = [];
    //list.add(Align(alignment: Alignment.centerLeft, child: _headerRow()));
    for (ProcessSchedulerModel ps in system.processSchedulers) {
      var psCtx = processSchedulers[ps.schedulerId];
      list.add(
          Align(alignment: Alignment.centerLeft, child: _scheduleRow(psCtx!)));
      for (ProcessModel pv in ps.processes) {
        if (pv.processVariables != null) {
          for (ProcessVariableModel pvm in pv.processVariables!) {
            var pvCtx = processVariables[pvm.variableId];
            list.add(Align(
                alignment: Alignment.centerLeft,
                child: _processVariableRow(pvCtx!)));
          }
        }
      }
    }
    return list;
  }

  Widget _processVariableRow(ProcessVariableContext pvc) {
    List<Widget> row = [];
    row.add(Expanded(
      flex: 1,
      child: Row(children: [
        const SizedBox(
          width: 20,
        ),
        const Icon(Icons.speed, color: Colors.white54, size: 40),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
          child: Text(pvc.variable.name, style: textStyle(context)),
        )
      ]),
    ));
    row.add(Expanded(
        flex: 1,
        child: Text("Setpoint ${pvc.value!.setPoint}",
            style: textStyle(context))));
    return Row(children: row);
  }

  Widget _viewHeader(String text, BuildContext context) {
    if (mode == ScreenMode.view) {
      return Row(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(50, 20, 10, 0),
            child: Text(text, style: Theme.of(context).textTheme.labelMedium)),
        const Spacer()
      ]);
    } else {
      return Row(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(50, 20, 10, 0),
            child: Text(text, style: Theme.of(context).textTheme.labelMedium)),
        const Spacer(),
        Padding(
            padding: const EdgeInsets.fromLTRB(50, 20, 10, 0),
            child: InkWell(
                child: const Icon(Icons.close_sharp,
                    color: Colors.red, size: 48),
                onTap: () => phases.removeModel(phaseModel!.phaseId)
            )
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 50, 0),
            child: InkWell(
                child: const Icon(Icons.edit_note_sharp,
                    color: Colors.white, size: 48),
                onTap: () => Get.dialog(ControlledPhaseEditDialog(system,
                            phaseModel: phaseModel))
                        .then((p) {
                      if (p != null) {
                        phases.updateModel(p);
                      }
                    })))
      ]);
    }
  }
}

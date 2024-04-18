import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/datamodels/recipes/process_schedule_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/setpoint_model.dart';
import 'package:uuid/uuid.dart';

import 'package:hydroponics_framework/datamodels/recipes/phase/controlled_phase_model.dart';
import 'package:hydroponics_framework/datamodels/system/process_model.dart';
import 'package:hydroponics_framework/datamodels/system/process_scheduler_model.dart';
import 'package:hydroponics_framework/datamodels/system/process_variable_model.dart';
import 'package:hydroponics_framework/datamodels/system/system_model.dart';

import 'package:hydroponics_panel/screens/recipe/dialogs/process_schedule_dialog.dart';
import 'package:hydroponics_panel/screens/recipe/dialogs/process_variable_dialog.dart';
import 'controlled_phase_mixin.dart';

class ControlledPhaseEditDialog extends StatefulWidget {
  final SystemModel system;
  final ControlledPhaseModel? phaseModel;

  const ControlledPhaseEditDialog(this.system, {this.phaseModel, super.key});

  @override
  State<StatefulWidget> createState() => _ControlledPhaseEditDialogState();
}

class _ControlledPhaseEditDialogState extends State<ControlledPhaseEditDialog> with ControlledPhaseMixin {

  final formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    system = widget.system;
    phaseModel = widget.phaseModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        //width: double.infinity,
        height: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: 1200,
                  height: 900,
                  child: Card(
                      elevation: 0,
                      color: Colors.black,
                      margin: const EdgeInsetsDirectional.only(
                          start: 20.0, end: 20.0),
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white)),
                      child: FormBuilder(
                          key: formKey,
                          //child:
                          //Padding(
                          //    padding:
                          //        const EdgeInsets.fromLTRB(0, 0, 0, 20),
                          child: Expanded(
                            child: Column(children: [
                              header("Controlled phase", context),
                              Row(children: [
                                Expanded(
                                    flex: 1,
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            50, 30, 30, 30),
                                        child: Text("Name",
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .labelSmall))
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            50, 30, 30, 30),
                                        child: Text("Duration (days)",
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .labelSmall))
                                )
                              ]),
                              Row(children: [
                                Expanded(
                                    flex: 1,
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            70, 0, 30, 30),
                                        child: FormBuilderTextField(
                                            autofocus: true,
                                            name: 'name',
                                            initialValue: phaseModel!=null? phaseModel!.name : null,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.white),
                                            validator:
                                            FormBuilderValidators.compose([
                                              FormBuilderValidators.required(
                                                  errorText:
                                                  "Please enter a name"),
                                              FormBuilderValidators.minLength(4,
                                                  errorText:
                                                  "name must be at least 4 chars")
                                            ]),
                                            onSaved: (v) => name = v ?? ""))),
                                Expanded(
                                    flex: 1,
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            70, 0, 30, 30),
                                        child: FormBuilderTextField(
                                          keyboardType: TextInputType.number,
                                          autofocus: true,
                                          name: 'duration',
                                          initialValue: "10",
                                          style: const TextStyle(
                                              fontSize: 20, color: Colors.white),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(RegExp(
                                                r'[1-9]')),
                                            LengthLimitingTextInputFormatter(2),
                                          ],
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(
                                                errorText: "Please enter a duration"),
                                            FormBuilderValidators.numeric(
                                                errorText: "Enter a number between 1 and 99"),
                                            FormBuilderValidators.maxLength(2,
                                                errorText: "Enter a number between 1 and 99"),
                                          ]),
                                          onSaved: (v) => duration = v != null ? int.parse(v) : 0
                                        )))
                              ]),
                              Row(children: [
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        50, 30, 30, 30),
                                    child: Text("Settings",
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .labelSmall))
                              ]),
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          70, 0, 30, 30),
                                      child: ListView(children: _rows()))),
                              Row(children: [
                                const SizedBox(width: 50),
                                InkWell(
                                    onTap: () => Get.back(result: false),
                                    child: const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Icon(Icons.clear,
                                          color: Colors.red, size: 48),
                                    )),
                                const Spacer(),
                                InkWell(
                                    onTap: () => validateAndCreate(),
                                    child: const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Icon(Icons.done,
                                          color: Colors.green, size: 48),
                                    )),
                                const SizedBox(width: 50),
                              ]),
                            ]),
                          ))))
            ]));
  }


  Widget _scheduleRow(ProcessScheduleContext ctx) {
    List<Widget> row = [];
    row.add(SizedBox(
      width: nameWidth,
      child: Row(children: [
        const SizedBox(
          width: 20,
        ),
        const Icon(Icons.schedule, color: Colors.white54, size: 40),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
          child: Text(ctx.scheduleName, style: textStyle(context)),
        )
      ]),
    ));
    row.add(SizedBox(
        width: dialogWidth, child: ProcessScheduleDialog(ctx.schedule!)));
    return Row(children: row);
  }

  List<Widget> _rows() {
    List<Widget> list = [];
    //list.add(Align(alignment: Alignment.centerLeft, child: _headerRow()));
    for (ProcessSchedulerModel ps in system.processSchedulers) {
      var psCtx = processSchedulers[ps.schedulerId];
      list.add(Align(alignment: Alignment.centerLeft, child: _scheduleRow(psCtx! as ProcessScheduleContext)));
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
    row.add(SizedBox(
      width: nameWidth,
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
    row.add(SizedBox(
        width: dialogWidth,
        child: ProcessVariableDialog(
            value: pvc.value!,
            maxValue: pvc.variable.maxValue,
            minValue: pvc.variable.minValue,
            defaultValue: pvc.variable.defaultt,
            units: pvc.variable.units,
            decimalPlaces: pvc.variable.decimalPlaces)));
    return Row(children: row);
  }

  void validateAndCreate() {
    if (formKey.currentState != null &&
        formKey.currentState!.saveAndValidate() == true) {

      List<ProcessScheduleModel> schedulers =
          processSchedulers.values.map((ps) => ps.schedule!.toProcessScheduleModel()).toList();
      List<SetpointModel> setPoints =
          processVariables.values.map((pv) => pv.value!.toSetpointModel()).toList();

      ControlledPhaseModel phase;
      if(phaseModel == null) {
        phase = ControlledPhaseModel(
            phaseId: phaseId,
            name: name!,
            description: "",
            duration: duration!,
            processSchedules: schedulers,
            setPoints: setPoints
        );
      } else {
        phase = ControlledPhaseModel(
            phaseId: phaseModel!.phaseId,
            name: name!,
            description: "",
            duration: duration!,
            processSchedules: schedulers,
            setPoints: setPoints
        );
      }
      Get.back(result: phase);
    }
  }
}


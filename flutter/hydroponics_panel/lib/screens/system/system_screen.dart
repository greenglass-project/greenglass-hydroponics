import 'package:flutter/material.dart';
import 'package:hydroponics_framework/datamodels/system/fuzzy_logic_process_model.dart';
import 'package:hydroponics_framework/datamodels/system/process_model.dart';
import 'package:hydroponics_framework/datamodels/system/process_scheduler_model.dart';
import 'package:hydroponics_framework/datamodels/system/state_controller_process_model.dart';
import 'package:logger/logger.dart';

import 'package:industrial_theme/components/industrial_screen.dart';
import 'package:hydroponics_framework/datamodels/system/system_model.dart';

class SystemScreen extends StatefulWidget {
  final SystemModel system;

  const SystemScreen(this.system, {super.key});

  @override
  State<StatefulWidget> createState() => _SystemScreenState();
}

class _SystemScreenState extends State<SystemScreen> {
  final logger = Logger();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(
        name: "${widget.system.name} - system",
        enableBack: true,
        body: Column(children: [
          Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(50, 50, 50, 50),
                child: ListView(children: _createList(context)),
              ))
        ]));
  }

  List<Widget> _createList(BuildContext context) {
    List<Widget> list = [];
    for(ProcessSchedulerModel psm in widget.system.processSchedulers) {
      list.add(Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
            child: _processScheduler(context, psm))
      );
    }
    return list;
  }

  Widget _processScheduler(BuildContext context, ProcessSchedulerModel psm) {
    List<Widget> list = [];
    list.add( Row( children : [
      Text(psm.name, style: Theme.of(context).textTheme.labelMedium),
    ]));
    list.add( Row( children : [
      Text(psm.description, style: Theme.of(context).textTheme.bodySmall),
    ]));
    for(ProcessModel pm in psm.processes) {
      _process(context, pm, list);
    }
    return Card(
        elevation: 0,
        color: Colors.transparent,
        margin: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
        shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.blue)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 30.0),
          child: Column(children: list)
        )
    );
  }


  void _process(BuildContext context, ProcessModel model, List<Widget> list) {
    list.add( Row( children : [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child : Text("Controller - ${model.name}", style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.redAccent)),
      )
    ]));
    if(model.processVariables != null) {
    model.processVariables!.sort((a,b) => a.name.compareTo(b.name));
    for(var pv in model.processVariables!) {
      list.add(
          Row(children: [
            Expanded(
                flex: 5,
                child: Text("Process Variable", style: Theme
                    .of(context)
                    .textTheme
                    .bodySmall)
            ),
            Expanded(
                flex: 3,
                child: Text(pv.name, style: Theme
                    .of(context)
                    .textTheme
                    .bodySmall)
            ),
            Expanded(
                flex: 11,
                child: Text(pv.description, style: Theme
                    .of(context)
                    .textTheme
                    .bodySmall)
            ),

          ]));
      }
    }
    if(model.manipulatedVariables != null) {
      model.manipulatedVariables!.sort((a, b) => a.name.compareTo(b.name));
      for (var mv in model.manipulatedVariables!) {
        list.add(
            Row(children: [
              Expanded(
                  flex: 5,
                  child: Text("Manipulated Variable", style: Theme
                      .of(context)
                      .textTheme
                      .bodySmall)
              ),
              Expanded(
                  flex: 3,
                  child: Text(mv.name, style: Theme
                      .of(context)
                      .textTheme
                      .bodySmall)
              ),
              Expanded(
                  flex: 11,
                  child: Text(mv.description, style: Theme
                      .of(context)
                      .textTheme
                      .bodySmall)
              ),

            ]));
      }
    }
  }
}

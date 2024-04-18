import 'package:flutter/material.dart';
import 'package:hydroponics_framework/datamodels/implementation/implementation_model.dart';
import 'package:hydroponics_framework/datamodels/implementation/implementation_node_model.dart';
import 'package:hydroponics_framework/datamodels/system/process_model.dart';
import 'package:hydroponics_framework/datamodels/system/process_scheduler_model.dart';
import 'package:hydroponics_framework/mixins/system/system_mixin.dart';
import 'package:industrial_theme/components/industrial_screen.dart';

import '../installation/job/job_provider.dart';

class NodeMetric {
  String type;
  String description;
  String metric;

  NodeMetric(this.type, this.description, this.metric);
}

class ImplementationScreen extends StatefulWidget {
  final ImplementationModel implementation;

  const ImplementationScreen(this.implementation, {super.key});


  @override
  State<StatefulWidget> createState() => _ImplementationScreenState();
}

class _ImplementationScreenState extends State<ImplementationScreen> with SystemMixin {

  Map<String,NodeMetric> variableLookup = {};


  @override
  void initState() {
    systemId = widget.implementation.systemId;
    for(var node in widget.implementation.nodes) {
      for(var v in node.variables) {
        variableLookup[v.variableId] = NodeMetric(node.type, node.description, v.name);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(
        name: widget.implementation.name,
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
    if(system != null) {
      list.add(Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
          child: _nodes(context, widget.implementation.nodes)
      ));
      for (ProcessSchedulerModel psm in system!.processSchedulers) {
        list.add(Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
            child: _processScheduler(context, psm))
        );
      }
    }
    return list;
  }

  Widget _nodes(BuildContext context, List<ImplementationNodeModel> nodes) {
    List<Widget> list = [];
    list.add( Row( children : [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        child: Text("Nodes", style: Theme.of(context).textTheme.labelMedium),
      )
    ]));
    for(var n in nodes) {
      list.add(
          Row( children :[
            Expanded(
                flex: 1,
                child: Text(n.description, style: Theme.of(context).textTheme.bodySmall)
            ),
            Expanded(
                flex: 1,
                child: Text(n.type, style: Theme.of(context).textTheme.bodySmall)
            ),
          ]));
    }

    return Card(
        elevation: 0,
        color: Colors.transparent,
        margin: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
        shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.orangeAccent)),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 30.0),
            child: Column(children: list)
        )
    );
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

      if (pm.processVariables != null) {
        pm.processVariables!.sort((a, b) => a.name.compareTo(b.name));
        for (var pv in pm.processVariables!) {
          var nodeMetric = variableLookup[pv.variableId]!;
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
                    flex: 7,
                    child: Text(nodeMetric.description, style: Theme
                        .of(context)
                        .textTheme
                        .bodySmall)
                ),
                Expanded(
                    flex: 7,
                    child: Text(nodeMetric.metric, style: Theme
                        .of(context)
                        .textTheme
                        .bodySmall)
                ),
              ]));
        }
      }
      if (pm.manipulatedVariables != null) {
        pm.manipulatedVariables!.sort((a, b) => a.name.compareTo(b.name));
        for (var mv in pm.manipulatedVariables!) {
          var nodeMetric = variableLookup[mv.variableId]!;
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
                    flex: 4,
                    child: Text(nodeMetric.description, style: Theme
                        .of(context)
                        .textTheme
                        .bodySmall)
                ),
                Expanded(
                    flex: 7,
                    child: Text(nodeMetric.metric, style: Theme
                        .of(context)
                        .textTheme
                        .bodySmall)
                ),

              ]));
        }
      }
    }

    return Card(
        elevation: 0,
        color: Colors.transparent,
        margin: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
        shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.orangeAccent)),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 30.0),
            child: Column(children: list)
        )
    );
  }
}
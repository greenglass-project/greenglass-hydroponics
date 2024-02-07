import 'package:flutter/material.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/controlled_phase_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/setpoint_model.dart';
import 'package:hydroponics_framework/datamodels/system/process_model.dart';
import 'package:hydroponics_framework/state/state_theme.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/components/binary_component.dart';
import 'package:hydroponics_framework/components/variable_gauge.dart';
import 'package:hydroponics_framework/mixins/system/process_state_mixin.dart';

class ProcessCard extends StatefulWidget {
  final String installationId;
  final ProcessModel processModel;
  final ControlledPhaseModel phaseModel;
  final Stream<bool> controlStream;

  const ProcessCard({
    required this.installationId,
    required this.processModel,
    required this.phaseModel,
    required this.controlStream,
    super.key
  });

  @override
  State<StatefulWidget> createState() =>_ProcessCardState();
}

class _ProcessCardState extends State<ProcessCard> with ProcessStateMixin {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  @override
  void initState() {
    //widget.controlStream.listen((state) => setState(() => this.state = state));
    installationId = widget.installationId;
    processId = widget.processModel.processId;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Card(
            elevation: 0,
            color:  Colors.white10, //Colors.transparent,
            margin: const EdgeInsetsDirectional.only(
                start: 5.0, end: 5.0),
            //shape: const RoundedRectangleBorder(
            //    side: BorderSide(color: Colors.white60)),
            child: _processVariableRow(widget.processModel));
  }

  Widget _processVariableRow(ProcessModel pm) {
    List<Widget> list = [];
    if(pm.processVariables != null) {
      for (final (index, pvm) in pm.processVariables!.indexed) {
        SetpointModel? sm = widget.phaseModel.setPointForVariable(pvm.variableId);
        if(sm != null) {
          if (index == 0) {
            list.add(const SizedBox(width: 10));
          }
          list.add(Expanded(flex: 1,
              child: SizedBox(height: 250,
                  child: VariableGauge(
                      installationId: widget.installationId,
                      processVariable: pvm,
                      setpoint: sm,
                      state: state,
                      key: Key(state.toString())
                  )
              )
          )
          );
          list.add(const SizedBox(width: 10));
        }
      }
    }
    return Column(children : [
      Row(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            child: Text(
                pm.name,
                textAlign: TextAlign.left,
                style: StateTheme.styleForState(Theme.of(context).textTheme.titleSmall!, state)
            )
        ),
        const Spacer(),
        Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            child: BinaryComponent(state)
        )
      ]),
      Row(children : [
        Expanded( flex: 75, child :Row(children: list,)),
      ])]);

  }

}
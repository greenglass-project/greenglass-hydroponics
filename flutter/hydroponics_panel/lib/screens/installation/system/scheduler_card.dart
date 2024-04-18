import 'package:flutter/material.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/controlled_phase_model.dart';
import 'package:hydroponics_framework/datamodels/system/process_model.dart';
import 'package:hydroponics_framework/datamodels/system/process_scheduler_model.dart';
import 'package:hydroponics_framework/state/state_theme.dart';
import 'package:hydroponics_panel/screens/installation/system/process_card.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

class SchedulerCard extends StatefulWidget {
  final String installationId;
  final ProcessSchedulerModel schedulerModel;
  final ControlledPhaseModel phaseModel;

  const SchedulerCard({
    required this.installationId,
    required this.schedulerModel,
    required this.phaseModel,
    super.key
  });

  @override
  State<StatefulWidget> createState() => _SchedulerCardState();
}
class _SchedulerCardState extends State<SchedulerCard> {
  var logger = Logger();
  bool installationState = false;
  bool? scheduleState;
  BehaviorSubject<bool> scheduleStateStream = BehaviorSubject<bool>();

  @override
  void initState() {
    /*widget.installationStateStream.listen((state) => setState(() {
      logger.d("SCHEDULER INSTALLATION STATE $state");
      installationState = state;
      scheduleState = installationState ? true : null;
      scheduleStateStream.add(scheduleState);
    }));*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        color: Colors.transparent,
        margin: const EdgeInsetsDirectional.only(start: 30.0, end: 10.0, top: 10.0),
        shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.white60)),
        child: Column(children:_cardBody(widget.schedulerModel)
    ));
  }

  List<Widget> _cardBody(ProcessSchedulerModel psm) {
    List<Widget> list = [];
    list.add(Row(children: [
      const SizedBox(
        width: 20,
      ),
      StateTheme.colourForState(Icons.schedule, 40, installationState),
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Text(
            psm.name,
            style: StateTheme.styleForState(
                Theme.of(context).textTheme.titleSmall!,
                true
            )
        ),
      ),
      const Spacer()
    ]));
    //psm.processes.sort((a, b) => a.name.compareTo(b.name));
    for (ProcessModel pm in psm.processes) {
        list.add(ProcessCard(
            installationId : widget.installationId,
            processModel : pm,
            phaseModel : widget.phaseModel,
            controlStream: scheduleStateStream.stream,
        ));
    }
    return list;
  }
}
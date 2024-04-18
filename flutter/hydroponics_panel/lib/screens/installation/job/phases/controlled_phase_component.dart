import 'package:flutter/material.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/controlled_phase_model.dart';
import 'package:rxdart/rxdart.dart';

import 'package:hydroponics_framework/caches/system_models_cache.dart';
import 'package:hydroponics_framework/datamodels/installation/installation_view_model.dart';
import 'package:hydroponics_framework/datamodels/system/system_model.dart';
import 'package:hydroponics_framework/mixins/installation/installation_states_mixin.dart';
import 'package:hydroponics_panel/screens/installation/system/scheduler_card.dart';

class ControlledPhaseComponent extends StatefulWidget {
  final InstallationViewModel installation;
  final ControlledPhaseModel phase;
  const ControlledPhaseComponent({required this.installation, required this.phase, super.key});

  @override
  State<StatefulWidget> createState() => _ControlledPhaseComponentState();

}

class _ControlledPhaseComponentState extends State<ControlledPhaseComponent> { // {
  //get processVariables => null;

  SystemModelsCache smc = SystemModelsCache.cache;
  SystemModel? system;
  //BehaviorSubject<bool> instStateStream = BehaviorSubject<bool>();

  @override
  void initState() {
    smc.systemModel(widget.installation.systemId).then((s) => setState(() => system = s));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(system == null) {
      return Container();
    } else {
      return Column(
          children: system!.processSchedulers.map(
                  (ps) => SchedulerCard(
                      installationId: widget.installation.installationId,
                      schedulerModel: ps,
                  phaseModel: widget.phase,
                  )).toList());
    }
  }
}
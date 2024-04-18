import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hydroponics_framework/datamodels/installation/installation_view_model.dart';
import 'package:hydroponics_framework/datamodels/job/job_context_model.dart';
import 'package:hydroponics_framework/datamodels/job/job_state.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/controlled_phase_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/manual_phase_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/phase_model.dart';
import 'package:hydroponics_panel/screens/installation/job/phases/no_job_component.dart';
import 'package:hydroponics_panel/screens/installation/job/phases/start_job_component.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

import 'controlled_phase_component.dart';
import 'manual_phase_component.dart';

class PhaseComponent extends StatefulWidget {
  final InstallationViewModel installation;
  final ReplayStream<JobContextModel?> jobContextStream;

  const PhaseComponent({
    required this.installation,
    required this.jobContextStream,
    super.key
  });

  @override
  State<StatefulWidget> createState() => _PhaseComponentState();
}

class _PhaseComponentState extends State<PhaseComponent> {

  JobContextModel? jobContextModel;
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    widget.jobContextStream.listen((jcm) {
      logger.d("Received job");
      setState(() => jobContextModel = jcm);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(jobContextModel != null) {
      if (jobContextModel!.job.state != JobState.inactive) {
        String currentPhase = jobContextModel!.job.phaseId!;
        PhaseModel? phase = jobContextModel!.recipe.phases.firstWhereOrNull((
            p) => p.phaseId == currentPhase);
        if (phase != null) {
          if (phase is ManualPhaseModel) {
            return ManualPhaseComponent(installation: widget.installation,  phase: phase);
          } else if (phase is ControlledPhaseModel) {
            return ControlledPhaseComponent(installation: widget.installation, phase: phase);
          }
        }
      } else {
        return StartJobComponent(
            installation: widget.installation, jobContext: jobContextModel!);
      }
    }
    return NoJobComponent(installation: widget.installation);
  }
}
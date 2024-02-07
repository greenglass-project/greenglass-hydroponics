import 'package:flutter/material.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/controlled_phase_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/manual_phase_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/phase_model.dart';
import 'package:hydroponics_framework/datamodels/system/system_model.dart';
import 'package:hydroponics_panel/screens/recipe/phases/controlled/controlled_phase_view_component.dart';
import 'package:hydroponics_panel/screens/recipe/phases/manual/manual_phase_view_component.dart';
import 'package:hydroponics_panel/screens/recipe/phases/phase_list_provider.dart';
import 'package:hydroponics_panel/screens/recipe/screen_mode.dart';

class PhaseDetailComponent extends StatefulWidget {
  final SystemModel system;
  final Stream<PhaseModel?> modelStream;
  final PhaseListProvider phases;
  final ScreenMode mode;

  const PhaseDetailComponent({
    required this.system,
    required this.modelStream,
    required this.phases,
    this.mode = ScreenMode.view,
    super.key
  });

  @override
  State<StatefulWidget> createState() => _PhaseDetailComponentState();
}

class _PhaseDetailComponentState extends State<PhaseDetailComponent> {
  PhaseModel? phaseModel;

  @override
  void initState() {
    super.initState();
    widget.modelStream.listen((pm) { if(mounted) {
      setState(() => phaseModel = pm);
    }});
  }

  @override
  Widget build(BuildContext context) {
    if (phaseModel is ManualPhaseModel) {
      return ManualPhaseViewComponent(
          phaseModel : phaseModel as ManualPhaseModel,
          phases: widget.phases,
          mode: widget.mode,
          key: Key(DateTime.now().toString())
      );
    } else if(phaseModel is ControlledPhaseModel) {
      return ControlledPhaseViewComponent(
          system: widget.system,
          phaseModel : phaseModel as ControlledPhaseModel,
          phases: widget.phases,
          mode: widget.mode,
          key : Key(DateTime.now().toString())

      );
    } else {
      return Container();
    }
  }
}
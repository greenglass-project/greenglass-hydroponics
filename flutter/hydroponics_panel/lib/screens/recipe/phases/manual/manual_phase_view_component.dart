import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hydroponics_framework/datamodels/recipes/phase/manual_phase_model.dart';
import 'package:hydroponics_panel/screens/recipe/screen_mode.dart';
import 'package:hydroponics_panel/screens/recipe/phases/phase_list_provider.dart';

import 'manual_phase_edit_dialog.dart';


class ManualPhaseViewComponent extends StatefulWidget {
  final ManualPhaseModel phaseModel;
  final PhaseListProvider phases;
  final ScreenMode mode;

  const ManualPhaseViewComponent({
    required this.phaseModel,
    required this.phases,
    this.mode = ScreenMode.view,
    super.key});

  @override
  State<StatefulWidget> createState() => _ManualPhaseViewComponentState();
}

class _ManualPhaseViewComponentState extends State<ManualPhaseViewComponent> {
  late ManualPhaseModel phaseModel;
  late PhaseListProvider phases;
  late ScreenMode mode;

  @override
  void initState() {
    super.initState();
    phaseModel = widget.phaseModel;
    phases = widget.phases;
    mode = widget.mode;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        color: Colors.black,
        margin: const EdgeInsetsDirectional.only(start: 10.0, end: 0),
        shape:
            const RoundedRectangleBorder(side: BorderSide(color: Colors.white)),
        child: Column(children: [
          _viewHeader("Manual phase", context),
          Row(children: [
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
                    child: Text("Name",
                        style: Theme.of(context).textTheme.labelSmall))),
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
                    child: Text(phaseModel.name,
                        style: Theme.of(context).textTheme.labelSmall))),
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
                    child: Text("Max Duration",
                        style: Theme.of(context).textTheme.labelSmall))),
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
                    child: Text("${phaseModel.duration}",
                        style: Theme.of(context).textTheme.labelSmall)))
          ])
        ]));
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
                onTap: () => phases.removeModel(phaseModel.phaseId)
                )
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 50, 0),
            child: InkWell(
              child: const Icon(Icons.edit_note_sharp,
                  color: Colors.white, size: 48),
              onTap: () => Get.dialog(ManualPhaseEditDialog(phaseModel: phaseModel)).then((p) {
                if(p != null) {
                  phases.updateModel(p);
                }
              }))
        )
      ]);
    }
  }
}

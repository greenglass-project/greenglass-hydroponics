import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:hydroponics_framework/datamodels/system/system_model.dart';
import 'controlled/controlled_phase_edit_dialog.dart';
import 'manual/manual_phase_edit_dialog.dart';

enum Phase { choose, manual, controlled, sequence }

class PhaseTypeDialog extends StatefulWidget {
  final SystemModel system;
  const PhaseTypeDialog(this.system, {super.key});

  @override
  State<StatefulWidget> createState() => _PhaseTypeDialogState();
}

class _PhaseTypeDialogState extends State<PhaseTypeDialog> {
  Phase selectedPhase = Phase.choose;
  final formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    switch(selectedPhase) {
      case Phase.choose:
        return Container(
          //width: double.infinity,
            height: double.infinity,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 400,
                      height: 400,
                      child: Card(
                          elevation: 0,
                          color: Colors.black,
                          margin: const EdgeInsetsDirectional.only(
                              start: 20.0, end: 20.0),
                          shape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.white)),
                          child: Center(
                              child: Column(children: [
                                _header("Phase Type", context),
                                _entry("Manual", context,
                                        () => setState(() => selectedPhase = Phase.manual)),
                                _entry("Controlled", context,
                                        () => setState(() => selectedPhase = Phase.controlled)),
                                _entry("Sequence", context, () {}),
                                const Spacer(),
                              ]))))
                ]));
      case Phase.manual :
        return const ManualPhaseEditDialog();
      case Phase.controlled :
        return ControlledPhaseEditDialog(widget.system, phaseModel: null);
      default :
        return Container();
    }
  }

  Widget _header(String text, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Center(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Text(text,
                    style: Theme
                        .of(context)
                        .textTheme
                        .labelMedium))));
  }

  Widget _entry(String text, BuildContext context, Function onTap) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.greenAccent,
                  width: 1.0,
                  style: BorderStyle.solid),
            ),
            child: InkWell(
                onTap: () => onTap(),
                child: Center(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                        child: Text(text,
                            style:
                            Theme
                                .of(context)
                                .textTheme
                                .labelMedium))))));
  }
}


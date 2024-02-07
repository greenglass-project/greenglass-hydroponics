import 'package:flutter/material.dart';
import 'package:hydroponics_framework/datamodels/installation/installation_view_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/manual_phase_model.dart';
import 'package:hydroponics_framework/mixins/error/error_dialog_mixin.dart';
import 'package:hydroponics_framework/mixins/installation/next_phase_mixin.dart';


class ManualPhaseComponent extends StatefulWidget {
  final InstallationViewModel installation;
  final ManualPhaseModel phase;

  ManualPhaseComponent(
      {required this.installation, required this.phase, super.key});

  @override
  State<StatefulWidget> createState() => _ManualPhaseComponentState();

}

class _ManualPhaseComponentState extends State<ManualPhaseComponent> with NextPhaseMixin, ErrorDialogMixin {
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        color: Colors.transparent,
        margin:
        const EdgeInsetsDirectional.only(start: 0.0, end: 0, top: 10.0),
        shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.white60)),
        child: Center(
            child: Column(children: [
              Row(
                  children :[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Text("Phase ${widget.phase.name}",
                            style: Theme.of(context).textTheme.labelMedium
                        )
                    ),
                    const Spacer(),
                  ]),
              const Spacer(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [

                    //const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 70),
                          child: Text(widget.phase.description.trim(), style: Theme.of(context).textTheme.labelSmall)
                    ),
                    //const Spacer(),
              ]),
              Row(children: [
                const Spacer(),

                /*Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white,
                          width: 1.0,
                          style: BorderStyle.solid),
                    ),
                    child: InkWell(
                        onTap: () => ms.requestNoParameters("abort.installations.${installation.installationId}.job",
                                (r) => null,
                                (p0, p1) => null),
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child:
                            Row(children: [
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Text("Cancel",
                                      style: Theme.of(context).textTheme.labelSmall)
                              ),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Icon(Icons.close_sharp,
                                      color: Colors.red,
                                      size: 48
                                  )),
                            ]))
                    )),
                const SizedBox(width: 20),*/
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white,
                          width: 1.0,
                          style: BorderStyle.solid),
                    ),
                    child: InkWell(
                        onTap: () => nextPhase(
                            widget.installation.installationId,
                            (job) {},
                            (c,m) => displayError(context, c,m)
                          ),
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child:
                            Row(children: [
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Text("Continue",
                                      style: Theme.of(context).textTheme.labelSmall)
                              ),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Icon(Icons.chevron_right_sharp,
                                      color: Colors.green,
                                      size: 48
                                  )),
                            ]))
                    )),
                const Spacer()
              ]),
              const Spacer()
            ])));
  }
}

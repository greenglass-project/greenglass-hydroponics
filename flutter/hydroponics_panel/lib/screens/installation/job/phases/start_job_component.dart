import 'package:flutter/material.dart';

import 'package:hydroponics_framework/datamodels/installation/installation_view_model.dart';
import 'package:hydroponics_framework/datamodels/job/job_context_model.dart';
import 'package:hydroponics_framework/mixins/error/error_dialog_mixin.dart';
import 'package:hydroponics_framework/mixins/installation/start_job_mixin.dart';

class StartJobComponent extends StatefulWidget {
  final InstallationViewModel installation;
  final JobContextModel jobContext;

  StartJobComponent(
      {required this.installation, required this.jobContext, super.key});

  @override
  State<StatefulWidget> createState() => _StartJobComponentState();
}

class _StartJobComponentState extends State<StartJobComponent> with StartJobMixin, ErrorDialogMixin  {

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        color: Colors.transparent,
        margin:
            const EdgeInsetsDirectional.only(start: 0.0, end: 25.0, top: 10.0),
        shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.white60)),
        child: Center(
            child: Column(children: [
          Row(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Text("Start job - ${widget.jobContext.recipe.description}",
                    style: Theme.of(context).textTheme.labelMedium)),
            const Spacer(),
          ]),
          const Spacer(),
          Row(children: [
            const Spacer(),
            Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                      style: BorderStyle.solid),
                ),
                child: InkWell(
                    onTap: () {},
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Row(children: [
                          Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Text("Cancel",
                                  style:
                                      Theme.of(context).textTheme.labelSmall)),
                          const Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Icon(Icons.close_sharp,
                                  color: Colors.red, size: 48)),
                        ])))),
            const SizedBox(width: 20),
            Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                      style: BorderStyle.solid),
                ),
                child: InkWell(
                    onTap: () => startJob(widget.installation.installationId,
                            (job) {},
                            (c,m) => displayError(context, c,m)),
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Row(children: [
                          Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Text("Start",
                                  style:
                                      Theme.of(context).textTheme.labelSmall)),
                          const Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Icon(Icons.chevron_right_sharp,
                                  color: Colors.green, size: 48)),
                        ])))),
            const Spacer()
          ]),
          const Spacer()
        ])));
  }
}

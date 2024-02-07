import 'package:flutter/material.dart';

import 'package:hydroponics_framework/components/stream_image.dart';
import 'package:hydroponics_framework/datamodels/installation/installation_view_model.dart';
import 'package:hydroponics_framework/datamodels/job/job_context_model.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

class JobRecipeCard extends StatefulWidget {
  final InstallationViewModel installation;
  final ReplayStream<JobContextModel?> jobContextStream;

  const JobRecipeCard(
      {required this.installation, required this.jobContextStream, super.key});

  @override
  State<StatefulWidget> createState() => _JobRecipeCardState();
}

class _JobRecipeCardState extends State<JobRecipeCard> {
  JobContextModel? jobContextModel;
  var logger = Logger();

  @override
  void initState() {
    widget.jobContextStream.listen((jcm) {
      logger.d("Received job");
      setState(() => setState(() => jobContextModel = jcm));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        color: Colors.transparent,
        margin:
            const EdgeInsetsDirectional.only(start: 0.0, end: 25.0, top: 10.0),
        shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.white60)),
        child: jobContextModel == null
            ? Container()
            : Column(children: _column(context)));
  }

  List<Widget> _column(BuildContext context) {
    List<Widget> list = [];
    list.add(Row(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 0, 20),
        child: Text("Plant", style: Theme.of(context).textTheme.titleSmall),
      ),
      const Spacer()
    ]));
    list.add(Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 9),
        child: _plantDetails(context)));
    list.add(Row(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
        child: Text("Phases", style: Theme.of(context).textTheme.titleSmall),
      ),
      const Spacer()
    ]));
    list.add(Expanded(child: ListView(children: _phaseTiles(context))));
    return list;
  }

  Widget _plantDetails(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.white54, width: 1.0, style: BorderStyle.solid),
        ),
        child: Row(children: [
          Expanded(
              flex: 1,
              child: StreamImage(
                topic: "findone.plants.${jobContextModel!.plant.plantId}.image",
                opacity: 0.7,
              )),
          Expanded(
              flex: 3,
              child: Center(
                  child: Text(jobContextModel!.plant.name,
                      style: Theme.of(context).textTheme.titleSmall)))
        ]));
  }

  List<Widget> _phaseTiles(BuildContext context) {
    List<Widget> list = [];
    String? currentPhase = jobContextModel!.job.phaseId;
    for (var p in jobContextModel!.recipe.phases) {
      if (p.phaseId == currentPhase) {
        list.add(Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
            child: Container(
                color: Colors.green,
                /*decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.green,
                      width: 3.0,
                      style: BorderStyle.solid),
                ), */
                child: ListTile(
                    title: Text(p.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: Colors.black))))));
      } else {
        list.add(Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.white54,
                      width: 1.0,
                      style: BorderStyle.solid),
                ),
                child: ListTile(
                    title: Text(p.name,
                        style: Theme.of(context).textTheme.titleSmall)))));
      }
    }

    return list;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/datamodels/job/job_state.dart';
import 'package:hydroponics_framework/datamodels/installation/installation_view_model.dart';
import 'package:hydroponics_framework/mixins/installation/job_state_mixin.dart';

import '../menudialog/recipe_dialog.dart';

class JobMenuBar extends StatefulWidget {
  final InstallationViewModel installation;
  final JobState? jobState;
  const JobMenuBar(this.installation, this.jobState, {super.key});

  @override
  State<StatefulWidget> createState() => _JobMenuBarState();
}

class _JobMenuBarState extends State<JobMenuBar> with JobStateMixin {

  bool startState = false;
  bool stopState = false;
  bool pauseState = false;
  bool cancelState = false;
  bool recipeState = false;

  @override
  void initState() {
    _barState(widget.jobState);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Spacer(),
      _button(Icons.play_arrow_sharp, Colors.green, 48, startState,
              () => changeState(widget.installation.installationId, JobState.active, () {}, (c,m){} )),
      const Spacer(),
      _button(Icons.pause_sharp, Colors.orange, 48, pauseState,
              () => changeState(widget.installation.installationId, JobState.paused, () {}, (c,m){} )),
      const Spacer(),
      _button(Icons.stop_sharp, Colors.red, 48, stopState, (){}),
      const Spacer(),
      _button(Icons.clear_sharp, Colors.red, 48, cancelState, (){}),
      const Spacer(),
      _button(Icons.feed_sharp, Colors.green, 48, recipeState,
              () => Get.dialog(RecipeDialog(widget.installation.installationId, widget.installation.systemId))
      ),
      const Spacer()
    ],);
  }

  void _barState(JobState? jobState) {
    if(widget.jobState == null) {
      startState = false;
      stopState = false;
      pauseState = false;
      cancelState = false;
      recipeState = true;
    } else {
      switch (jobState) {
        case JobState.inactive :
          {
            startState = true;
            stopState = false;
            pauseState = false;
            cancelState = true;
            recipeState = false;
            break;
          }
        case JobState.active :
          {
            startState = false;
            stopState = true;
            pauseState = true;
            cancelState = false;
            recipeState = false;
            break;
          }
        case JobState.paused :
          {
            startState = true;
            stopState = true;
            pauseState = false;
            cancelState = false;
            recipeState = false;
            break;
          }
        default :
          {
            startState = false;
            stopState = false;
            pauseState = false;
            cancelState = false;
            recipeState = false;
            break;
          }
      }
    }
  }

  Widget _button(IconData icon, Color colour, double size, bool state, Function() onTap) {
    return Padding(padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: SizedBox(width: 80, height: 80,
            child: state ?
            Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                      style: BorderStyle.solid),
                ),
                child: InkWell(
                    onTap: () => onTap(),
                    child: Icon(icon, size: size, color: colour)
                )
            ) :
            Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.white38,
                      width: 1.0,
                      style: BorderStyle.solid),
                ),
                child: Icon(icon, size: size, color: Colors.white38,)

            )
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hydroponics_framework/datamodels/recipes/mutable_process_schedule_model.dart';
import 'package:hydroponics_panel/screens/recipe/dialogs/period/period_dialog.dart';
import 'package:hydroponics_panel/screens/recipe/dialogs/dialog_mixin.dart';
import 'package:hydroponics_panel/screens/recipe/dialogs/duration/duration_dialog.dart';
import 'package:hydroponics_panel/screens/recipe/dialogs/time/time_of_day_dialog.dart';


class ProcessScheduleDialog extends StatefulWidget {
  final MutableProcessScheduleModel schedule;
  const ProcessScheduleDialog(this.schedule, {super.key});

  @override
  State<StatefulWidget> createState() => _ProcessScheduleDialogState();
}

class _ProcessScheduleDialogState extends State<ProcessScheduleDialog> with DialogMixin {

  bool isEvery = false;

  @override
  void initState() {

    if (widget.schedule.start == null && widget.schedule.end == null) {
      isEvery = true;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const SizedBox(width: 20,),
      Expanded(
          child:Padding( padding : const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: isEvery == true
                  ? _everySelection(context)
                  : _betweenSelection(context) //_everySelection()
              ))
    ]);
  }

  Widget _everySelection(BuildContext context) {
    return Row(children: [
      //const Icon(Icons.schedule,color: Colors.white54, size: 40,),
      //displayOnlyField(context, "On"),
      clickableTextField(
          context, "Every", () => setState(() => isEvery = false)),
      displayOnlyField(context, ""),
      changeableIntervalField(
          context,
          widget.schedule.frequency!,
          () => Get.dialog(PeriodDialog(widget.schedule.duration!, (24 - widget.schedule.start!) * 60))
              .then((r) {
                if(r != null) {
                  setState(() => widget.schedule.frequency = r);
                }
          })),
      displayOnlyField(context, "for"),
      changeableIntervalField(
          context,
          widget.schedule.duration!,
          () => Get.dialog(DurationDialog(0, widget.schedule.frequency!)).then((r) {
            if(r != null) {
              setState(() => widget.schedule.duration = r);
            }
          }))
    ]);
  }

  Widget _betweenSelection(BuildContext context) {
    return Row(children: [
      //const Icon(Icons.schedule,color: Colors.white, size: 40,),
      //displayOnlyField(context, "On"),
      clickableTextField(
          context, "Between", () => setState(() => isEvery = true)),
      displayOnlyField(context, ""),
      changeableTimeField(
          context,
          widget.schedule.start!,
          () => Get.dialog(TimeOfDayDialog(0, widget.schedule.end! - 1)).then((r) {
                if(r != null) {
                  setState(() => widget.schedule.start = r);
                }
              })
      ),
      displayOnlyField(context, "and"),
      changeableTimeField(
          context,
          widget.schedule.end!,
          () => Get.dialog(TimeOfDayDialog(widget.schedule.start! + 1, 24)).then((r) {
            if(r != null) {
              setState(() => widget.schedule.end = r);
            }
          })),
    ]);
  }
}

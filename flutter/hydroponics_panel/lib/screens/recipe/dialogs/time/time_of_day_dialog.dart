import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class TimeOfDayDialog extends StatefulWidget {
  final int min;
  final int max;

  const TimeOfDayDialog(this.min, this.max, {super.key});

  @override
  State<TimeOfDayDialog> createState() => _TimeOfDayDialogState();
}

class _TimeOfDayDialogState extends State<TimeOfDayDialog> {
  List<int> optionsList = [];
  var logger = Logger();
  final format = NumberFormat("00");

  @override
  void initState() {
    for (int i = widget.min; i <= widget.max; i++) {
      optionsList.add(i);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //width: double.infinity,
      height: double.infinity,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 700,
                height: 700,
                child: Card(
                    elevation: 0,
                    color: Colors.black,
                    margin: const EdgeInsetsDirectional.only(
                        start: 20.0, end: 20.0),
                    //shape: const RoundedRectangleBorder(
                    //    side: BorderSide(color: Colors.white)
                    //),
                    child: //Expanded( child:
                        GridView.count(
                            primary: false,
                            padding: const EdgeInsets.all(20),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            crossAxisCount: 5,
                            childAspectRatio: 1 / 1,
                            children: optionsList
                                .map((o) => Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.orangeAccent,
                                          width: 1.0,
                                          style: BorderStyle.solid),
                                    ),
                                    child: InkWell(
                                        onTap: () => Get.back(result: o),
                                        child: Center(
                                          child: Text("${format.format(o)}:00",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall),
                                        ))))
                                .toList())))
          ]),
    );
  }
}

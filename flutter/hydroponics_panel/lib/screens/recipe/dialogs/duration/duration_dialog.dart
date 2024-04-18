import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class DurationDialog extends StatefulWidget {
  final int min;
  final int max;
  const DurationDialog(this.min, this.max, {super.key});

  @override
  State<DurationDialog> createState() => _DurationDialogState();
}

class _DurationDialogState extends State<DurationDialog> {

  var optionsList = [15, 30, 45, 1*60, 2*60, 3*60, 4*60, 5*60, 6*60, 7*60];
  late List<int> options;
  var logger = Logger();

  @override
  void initState() {
    options = optionsList.where((o) => o > widget.min && o < widget.max).toList();
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
          children: [SizedBox(
          width: 500,
          height: 500,
          child: Card(
                elevation: 0,
                color: Colors.black,
                margin:
                const EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
                //shape: const RoundedRectangleBorder(
                //    side: BorderSide(color: Colors.white)
                //),
                child: //Expanded( child:
                    GridView.count(
                        primary: false,
                        padding: const EdgeInsets.all(20),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 3,
                        childAspectRatio: 1 / 1,
                        children: options.map((o) => Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                            color: Colors.orangeAccent,
                              width: 1.0,
                              style: BorderStyle.solid),
                            ),
                          child: InkWell(
                            onTap: () => Get.back(result: o),
                            child: Center(child:Text(_valueToText(o),
                              style: Theme.of(context).textTheme.labelSmall),
                          )))).toList()

            )))
          ]),
    );
  }

  String _valueToText(int value) {
    if(value <120) {
      return "$value mins";
    } else {
      return "${value~/60} hours";
    }
  }
}

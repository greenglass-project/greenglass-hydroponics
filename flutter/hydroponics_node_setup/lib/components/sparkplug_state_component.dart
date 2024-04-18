import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../webservice/data_values.dart';
import '../webservice/web_service.dart';

class SparkplugStateComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SparkplugStateComponent();
}

class _SparkplugStateComponent extends State<SparkplugStateComponent> {

  WebService ws = Get.find();
  int state = 0;

 @override
  void initState() {
   _stateStream();
    super.initState();
  }

  void _stateStream() async {
    ws.subscribe("/sparkplug/state").listen((v) {
      if (mounted)
        setState(() =>
        state = IntValue
            .fromJson(jsonDecode(v))
            .value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50,
        width: 200,
        child: Center(
          child: _stateText(context)
        )
    );
  }

  Widget _stateText(BuildContext context) {
   switch(state) {
     case 0 :
       return _styledText(context,"Offline" , Colors.red);
     case 1 :
       return _styledText(context,"Connecting to broker" , Colors.yellow);
     case 2 :
       return _styledText(context,"Waiting for host" , Colors.orange);
     case 3 :
       return _styledText(context,"Online" , Colors.green);
     default :
       return _styledText(context,"Unknown" , Colors.purple);
   }
  }

  Widget _styledText(BuildContext context, String text, Color colour) =>
    Text(text, style : Theme.of(context).textTheme.headlineMedium!.copyWith(color: colour));

}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../datamodels/settings_model.dart';
import '../webservice/web_service.dart';

class SettingsComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsComponentState();
}

class _SettingsComponentState extends State<SettingsComponent> {

  WebService ws = Get.find();
  SettingsModel? settings;
  bool initialised = false;

  @override
  void initState() {
    _getSettings();
    super.initState();
  }

  void _getSettings() {
    ws.get("/sparkplug/settings").then((resp) {
      if (resp != 0) {
        setState(() {
          settings = SettingsModel.fromJson(jsonDecode(resp!));
          initialised = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(!initialised)
      return Container();
    else
      return Card( color: Colors.transparent,
          child:
          //SizedBox(width: 100,
          //child:
          Row( children : [
          Padding( padding : EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Text(settings!.nodeType,
              style: Theme.of(context).textTheme.headlineLarge
            )
          ),

          Column(children : [
            _entry(context, "Node-ID", settings!.nodeId),
            _entry(context, "Broker", settings!.broker)
          ]),
          Column(children : [
            _entry(context, "Group-ID", settings!.groupId),
            _entry(context, "Host-ID", settings!.hostId)
          ])
    ]));
  }

  Widget _entry(BuildContext context, String label, String value) =>
     Row( children : [
       _labelCell(context, label),
       _valueCell(context, value)
     ]);

  Widget _labelCell(BuildContext context, String text) =>
    Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 0, 5),
        child: Text(text, style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w400))

    );

  Widget _valueCell(BuildContext context,  String text) =>
    Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 0, 5),
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w100))

    );

}
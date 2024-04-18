import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:hydroponics_node_setup/webservice/web_service.dart';

import '../components/active_button_component.dart';
import '../datamodels/settings_model.dart';

class NodeScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _NodeScreenState();
}

class _NodeScreenState extends State<NodeScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  SettingsModel? settings;
  List<String> nodeTypes = [];
  bool initialised = false;

  WebService ws = Get.find();

  @override
  void initState() {
    super.initState();
    _getSettings();
  }

  void _getSettings() async {
    ws.get("/settings").then((resp) {
      if (resp != 0) {
        setState(() {
          initialised = true;
          settings = SettingsModel.fromJson(jsonDecode(resp!));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!initialised)
      return Container();
    else
      return Column(children: [
        Row(children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Text(
              "Node Settings",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Spacer(),
        ]),
        Expanded(
            child: Row(children: [
              //Expanded(flex: 1, child: Container()),
              Expanded(
                  flex: 1,
                  child: Column(children: [
                    const SizedBox(height: 50),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(3.0)
                          ),
                          border: Border.all(color: Colors.white54),
                        ),
                        child: Column(children: [
                          _listRow(context, "Node-type", settings!.nodeType),
                          _listRow(context, "Node-ID",settings!.nodeId),
                          _listRow(context, "Group-ID", settings!.groupId),
                          _listRow(context, "Host-ID", settings!.hostId),
                          _listRow(context, "Broker",settings!.broker),
                        ])),
                    const SizedBox(height: 20),
                    Row(children: [
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        child: ActiveButtonComponent(
                          label: "Edit",
                          onClick: (d) {}
                        )
                      )]),
                    Spacer(),
                  ])),
              Expanded(flex: 1, child: Container()),

            ])
      )]);
  }

  Widget _listRow(BuildContext context, String name, String value) =>
      Row(children: [
        Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Text(name, style: Theme.of(context).textTheme.titleMedium)),
        Spacer(),
        Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Text(value, style: Theme.of(context).textTheme.labelLarge)),
      ]);
}


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:hydroponics_node_setup/webservice/web_service.dart';
import 'package:hydroponics_node_setup/datamodels/settings_model.dart';

class SettingsScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
      return Container(child: Column(children: [
        Row(children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Text(
              "Settings",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Spacer(),
        ]),
            Row(children: [
            //Expanded(flex: 1, child: Container()),
            Expanded(
                flex: 2,
                child: FormBuilder(
                    key: formKey,
                    child: Column(children: [
                      const SizedBox(height: 50),
                      FormBuilderDropdown<String>(
                        initialValue: settings!.nodeType,
                        name: 'nodetype',
                        decoration: const InputDecoration(
                            labelText: 'Node-Type',
                            border: OutlineInputBorder()),
                        onSaved: (v) => {}, //settings!.nodeType = v!,
                        items: nodeTypes
                            .map(
                              (nt) => DropdownMenuItem(
                                  alignment: AlignmentDirectional.centerStart,
                                  value: nt,
                                  child: Text(nt)),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 25),
                      FormBuilderTextField(
                        initialValue: settings!.nodeId,
                        name: 'nodeid',
                        decoration: const InputDecoration(
                            labelText: 'Node-ID', border: OutlineInputBorder()),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                        onSaved: (v) => {} //settings!.nodeId = v!,
                      ),
                      const SizedBox(height: 25),
                      FormBuilderTextField(
                        initialValue: settings!.groupId,
                        name: 'groupid',
                        decoration: const InputDecoration(
                            labelText: 'Group-ID',
                            border: OutlineInputBorder()),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                        onSaved: (v) => {}, //settings!.groupId = v!,
                      ),
                      const SizedBox(height: 25),
                      FormBuilderTextField(
                        initialValue: settings!.hostId,
                        name: 'hostid',
                        decoration: const InputDecoration(
                            labelText: 'Host-ID', border: OutlineInputBorder()),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                        onSaved: (v) => {}, //settings!.hostId = v!,
                      ),
                      const SizedBox(height: 25),
                      FormBuilderTextField(
                        initialValue: settings!.broker,
                        name: 'broker',
                        decoration: const InputDecoration(
                            labelText: 'Broker', border: OutlineInputBorder()),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                        onSaved: (v) => {} //settings!.broker = v!,
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Spacer(),
                          OutlinedButton(
                            onPressed: () {},
                            child: const Text('Save'),
                          )
                        ],
                      )
                    ]))),
            Expanded(flex: 3, child: Container()),
          ])
        ])
      );
  }
}

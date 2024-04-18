import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:hydroponics_node_setup/components/active_button_component.dart';
import 'package:hydroponics_node_setup/webservice/web_service.dart';

import '../models/settings.dart';

class SettingsDialog extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {

  final formKey = GlobalKey<FormBuilderState>();
  WebService ws = Get.find();

  bool initialised = false;
  Settings? settings;
  int? tickInterval;
  int? window;

  double width = 400;
  double height = 350;

  @override
  void initState() {
    super.initState();
    _getSettings();
  }

  void _getSettings() async {
    ws.get("/driver/ept-sensors/settings").then((resp) {
      if (resp != null) {
        setState(() {
          settings = Settings.fromJson(jsonDecode(resp));
          initialised = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(!initialised) {
      return SizedBox(
          width: width,
          height: height,
        child: Container()
      );
    } else {
      return SizedBox(
          width: width,
          height: height,
          child: Padding(
          padding: EdgeInsets.fromLTRB(50, 20, 50, 0),
          child:
          Column(children: [
        Row(children : [
          Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child : Text("Settings", style : Theme.of(context).textTheme.headlineSmall)
          ),
          Spacer()
        ]),
        SizedBox(height:20),
        //Expanded(flex: 1, child: Container()),
        Expanded(
          //flex: 3,
            child: FormBuilder(
                key: formKey,
                child: Column(children: [
                  const SizedBox(height: 10),
                  FormBuilderTextField(
                    initialValue: settings!.tickInterval.toString(),
                    name: 'tickinterval',
                    decoration: const InputDecoration(
                        labelText: 'Tick Interval (seconds)',
                        border: OutlineInputBorder()),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.integer()
                    ]),
                    onSaved: (v) => tickInterval = int.parse(v!),
                  ),
                  const SizedBox(height: 10),
                  FormBuilderTextField(
                      initialValue: settings!.window.toString(),
                      name: 'window',
                      decoration: const InputDecoration(
                          labelText: 'Window size)',
                          border: OutlineInputBorder()),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.integer()
                      ]),
                      onSaved: (v) => window = int.parse(v!)
                  ),
                  Spacer(),
                  //const SizedBox(height: 25),
                  Row(
                    children: [
                      ActiveButtonComponent(
                          label: 'Cancel',
                          onClick: (b)  => Navigator.of(context).pop()
                      ),
                      Spacer(),
                      ActiveButtonComponent(
                          label: 'Save',
                          onClick: (d) {
                            if (formKey.currentState != null && formKey.currentState!
                                .saveAndValidate() == true) {
                              d.disable();
                              Settings settings = Settings(tickInterval!, window!);
                              ws.put("/driver/ept-sensors/settings", settings.toJson())
                                  .then((r) => Navigator.of(context).pop(settings));
                            }
                          }
                      )
                    ],
                  ),
                  SizedBox(height: 30,)
                ])))])));
    }
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import 'package:hydroponics_node_setup/components/active_button_component.dart';
import 'package:hydroponics_node_setup/datamodels/settings_model.dart';
import 'package:hydroponics_node_setup/screens/settings_screen.dart';
import 'package:hydroponics_node_setup/webservice/web_service.dart';

import 'grid_main_screen.dart';

class WebServiceScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WebServiceScreenState();
}

class _WebServiceScreenState extends State<WebServiceScreen> {
  final formKey = GlobalKey<FormBuilderState>();

  String? hostname;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black54,
            child: FormBuilder(
                key: formKey,
                child: Column(children: [
                  Spacer(),
                  Image(image: AssetImage('images/logo.png')),
                  SizedBox(height: 100),
                  SizedBox(
                      width: 250,
                      child: FormBuilderTextField(
                        initialValue: "node-water-control.local",
                        decoration: InputDecoration(
                            labelText: 'Hostname',
                            border: OutlineInputBorder(),
                            hintText: 'Enter hostname',
                            hintStyle: TextStyle(fontStyle: FontStyle.italic)),
                        name: 'hostname',
                        onSaved: (v) => hostname = v!,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      )),
                  SizedBox(height: 20),
                  ActiveButtonComponent(
                    onClick: ((d) async {
                      if (formKey.currentState != null &&
                          formKey.currentState!.saveAndValidate() == true) {
                        d.disable();
                        WebService ws = WebService(
                            hostName: hostname!, port: 8181, isSecure: false
                        );
                        Get.put(ws);
                        Get.to(() => GridMainScreen());
                    }}),
                    label: "Connect",
                  ),
                  Spacer()
                ]))));
  }
}

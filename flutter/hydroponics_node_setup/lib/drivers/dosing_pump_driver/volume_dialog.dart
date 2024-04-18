import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:hydroponics_node_setup/components/active_button_component.dart';
import 'package:hydroponics_node_setup/webservice/web_service.dart';

import '../../webservice/data_values.dart';

class VolumeDialog extends StatefulWidget {
  final String driverName;
  VolumeDialog(this.driverName);

  @override
  State<StatefulWidget> createState() => _VolumeDialogState();
}

class _VolumeDialogState extends State<VolumeDialog> {
  final formKey = GlobalKey<FormBuilderState>();
  WebService ws = Get.find();

  double calibration = 0.0;
  bool initialised = false;

  double width = 400;
  double height = 350;

  @override
  void initState() {
    _getVolume();
    super.initState();
  }

  void _getVolume() async {
    ws.get("/driver/${widget.driverName}/calibrate").then((resp) {
      if (resp != null) {
        setState(() {
          calibration = DoubleValue.fromJson(jsonDecode(resp)).value;
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
                      child : Text("Calibration", style : Theme.of(context).textTheme.headlineSmall)
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
                            initialValue: calibration.toString(),
                            name: 'volume',
                            decoration: const InputDecoration(
                                labelText: '',
                                border: OutlineInputBorder()),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.integer()
                            ]),
                            onSaved: (v) => calibration = double.parse(v!),
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
                                      ws.put("/driver/${widget.driverName}/calibrate", DoubleValue(calibration).toJson())
                                          .then((r) => Navigator.of(context).pop(calibration));
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
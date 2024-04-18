import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/datamodels/config/master_config_model.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/mixins/error/error_dialog_mixin.dart';

class MasterConfigDialog extends StatefulWidget {
  const MasterConfigDialog({super.key});

  @override
  State<StatefulWidget> createState() => _MasterConfigDialogState();
}

class _MasterConfigDialogState extends State<MasterConfigDialog> with ErrorDialogMixin{
  final formKey = GlobalKey<FormBuilderState>();
  final ms = MicroserviceService.ms;
  final logger = Logger();

  String hostId = "";
  String groupId = "";
  String timeZone = "";
  String influxdbKey = "";

  @override
  void initState() {
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
                  width: 900,
                  height: 900,
                  child: Card(
                      elevation: 0,
                      color: Colors.black,
                      margin: const EdgeInsetsDirectional.only(
                          start: 20.0, end: 20.0),
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(50, 50, 50, 50),
                        child: FormBuilder(
                            key: formKey,
                            child: _form()
                        )
                  ))
              )
            ]));
  }

  Widget _form() {
    return Column(children: [
      Row(children: [
        //Expanded(flex: 2, child: Container()),
        Expanded(
            flex: 3,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                child: Text("Host-ID",
                    style: Theme.of(context).textTheme.labelMedium))),
        //Expanded(flex: 1, child: Container()),
        Expanded(
          flex: 4,
          child: FormBuilderTextField(
              autofocus: true,
              name: 'hostId',
              initialValue: hostId,
              style: const TextStyle(fontSize: 20, color: Colors.white),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                    errorText: "Please enter a host-id"),
                FormBuilderValidators.minLength(4,
                    errorText: "host-id must be at least 4 chars")
              ]),
              //onChanged: (v) => url = v,
              onSaved: (v) => hostId = v!),
        ),
        //Expanded(flex: 4, child: Container()),
      ]),
      Row(children: [
        //Expanded(flex: 2, child: Container()),
        Expanded(
            flex: 3,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                child: Text("Group-ID",
                    style: Theme.of(context).textTheme.labelMedium))),
        //Expanded(flex: 1, child: Container()),
        Expanded(
          flex: 4,
          child: FormBuilderTextField(
              autofocus: true,
              name: 'groupid',
              initialValue: groupId,
              style: const TextStyle(fontSize: 20, color: Colors.white),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                    errorText: "Please enter a group-id"),
                FormBuilderValidators.minLength(4,
                    errorText: "group-id must be at least 4 chars")
              ]),
              //onChanged: (v) => url = v,
              onSaved: (v) => groupId = v!),
        ),
      ]),
      Row(children: [
        Expanded(
            flex: 3,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                child: Text("Time-Zone",
                    style: Theme.of(context).textTheme.labelMedium))),
        Expanded(
          flex: 4,
          child: FormBuilderTextField(
              autofocus: true,
              name: 'timezone',
              initialValue: timeZone,
              style: const TextStyle(fontSize: 20, color: Colors.white),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                    errorText: "Please enter a timezone"),
                FormBuilderValidators.minLength(4,
                    errorText: "timezone must be at least 4 chars")
              ]),
              onSaved: (v) => timeZone = v!),
        ),
      ]),
      Row(children: [
        Expanded(
            flex: 3,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                child: Text("Influx-DB key ",
                    style: Theme.of(context).textTheme.labelMedium))),
        //Expanded(flex: 1, child: Container()),
        Expanded(
          flex: 4,
          child: FormBuilderTextField(
              autofocus: true,
              name: 'influxdbkey',
              initialValue: influxdbKey,
              style: const TextStyle(fontSize: 20, color: Colors.white),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                    errorText: "Please enter the Influx DB yes"),
                FormBuilderValidators.minLength(32,
                    errorText: "key must be at least 32 chars")
              ]),
              onSaved: (v) => influxdbKey = v!),
        ),
      ]),
      Row(children: [
        const Spacer(),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.green)),
          child: InkWell(
              onTap: () => _validateAndCreate(),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Icon(Icons.done, color: Colors.green, size: 48),
              )),
        )
      ])
    ]);
  }

  _validateAndCreate() {
    if (formKey.currentState != null &&
        formKey.currentState!.saveAndValidate() == true) {
      logger.d("SAVE");
      MasterConfigModel mc = MasterConfigModel(
          hostId: hostId,
          groupId: groupId,
          timeZone: timeZone,
          influxdbKey: influxdbKey
      );
      const topic = "add.masterconfig";
      ms.request(topic,mc, 
              (_) {
                logger.d(" Received SUCCESS" );
                Get.back(result: true);
              },
              (c,m) {
                logger.d(" Received ERROR");
                displayError(context, c, m);
              }
      );
    }
  }
}

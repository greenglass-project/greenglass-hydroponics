import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/datamodels/nodes/node_metric_name_value.dart';
import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:logger/logger.dart';

mixin ModifyMetricValueMixin<T extends StatefulWidget> on State<T> {

  late GlobalKey<FormBuilderState> formKey;
  late String installationId;
  late String nodeId;

  final ms = MicroserviceService.ms;
  var logger = Logger();

  dynamic newValue;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width: 400,
              height: 350,
              child: Card(
                  elevation: 0,
                  color: Colors.black,
                  margin:
                  const EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
                  shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white)),
                  child: Column(children: [
                    Expanded(child:
                    FormBuilder(
                        key: formKey,
                        child: modifyForm())),
                    Row(children: [
                      InkWell(
                          onTap: () => Get.back(result: false),
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Icon(Icons.clear,
                                color: Colors.red, size: 48),
                          )),
                      const Spacer(),
                      InkWell(
                          onTap: () => validateAndSend(),
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Icon(Icons.done,
                                color: Colors.green, size: 48),
                          )),
                    ]),
                  ]
                  )
              ))
        ]);
  }

  Widget modifyForm();
  NodeMetricNameValue metric();

  void validateAndSend() {
    if (formKey.currentState != null &&
        formKey.currentState!.saveAndValidate() == true) {
      NodeMetricNameValue value = metric();
      ms.request("set.installations.$installationId.node.$nodeId}.metric", value,
              (r) => Get.back(result: true), (c, m) {});
    }
  }
}
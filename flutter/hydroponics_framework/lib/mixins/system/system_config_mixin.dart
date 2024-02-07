import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/microservices/string_value.dart';

mixin SystemConfigMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  List<StringValue> systems = [];

  @override
  void initState() {
    const topic = "findall.systemdefinitions";
    logger.d("Sending request to $topic");
    ms.requestListNoParameters(topic, (r) =>
      setState(() => systems = r.map((s) => StringValue.fromJson(s)).toList()),
            (c,m) {}
    );
    super.initState();
  }

  void addSystem(String fileName, Function onResult) {
    const topic = "add.systemdefinitions";
    logger.d("Sending request to $topic");
    ms.request(topic, StringValue(fileName), (r) {
      logger.d("Received response");
      onResult();
    },(c,m) {
      onResult();
    });
  }
}

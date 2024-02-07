import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/microservices/string_value.dart';

mixin NodeDefinitionsMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  List<StringValue> nodeTypes = [];

  @override
  void initState() {
    const topic = "findall.nodedefinitions";
    logger.d("Sending request to $topic");
    ms.requestListNoParameters(topic, (r) =>
      setState(() => nodeTypes = r.map((s) => StringValue.fromJson(s)).toList()),
            (c,m) {}
    );
    super.initState();
  }

  void addNodeDefinition(String fileName, Function onResult) {
    const topic = "add.nodedefinitions";
    logger.d("Sending request to $topic");
    ms.request(topic, StringValue(fileName), (r) {
      logger.d("Received response");
      onResult();
    },(c,m) {
      onResult();
    });
  }
}

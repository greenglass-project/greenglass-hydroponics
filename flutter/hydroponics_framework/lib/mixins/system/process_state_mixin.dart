import 'package:flutter/material.dart';

import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/datamodels/nodes/metric_value.dart';

mixin ProcessStateMixin<T extends StatefulWidget> on State<T> {

  final ms = MicroserviceService.ms;
  var logger = Logger();

  late String installationId;
  late String processId;
  bool state = false;

  @override
  void initState() {
    final rTopic = "findone.installations.$installationId.processes.$processId.state";
    final eTopic = "event.installations.$installationId.processes.$processId.state";

    logger.d("Listening to $eTopic");
    ms.listen(eTopic, (e) => setState(() => state = MetricValue.fromJson(e).value as bool));

    logger.d("Sending request to $rTopic");
    ms.requestNoParameters(rTopic,
            (r) => setState(() => state = MetricValue.fromJson(r).value as bool),
            (c,m) {}
    );
    super.initState();
  }
}
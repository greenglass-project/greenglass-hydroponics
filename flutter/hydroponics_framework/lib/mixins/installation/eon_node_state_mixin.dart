import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/datamodels/nodes/metric_value.dart';
import 'package:rxdart/rxdart.dart';

mixin EonNodeStateMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  late String nodeId;
  late String installationId;
  late BehaviorSubject<MetricValue> nodeStateSubjct;

  @override
  void initState() {

    final stateReqTopic  = "findone.installations.$installationId.nodes.$nodeId.state";
    final stateEventTopic  = "event.installations.$installationId.nodes.$nodeId.state";
    ms.requestNoParameters(stateReqTopic, (r) {
      final value = MetricValue.fromJson(r);
      nodeStateSubjct.add(value);
    }, (c,m) {});
    ms.listen(stateEventTopic, (r) {
      final value = MetricValue.fromJson(r);
      nodeStateSubjct.add((value));
    });

    super.initState();
  }
}
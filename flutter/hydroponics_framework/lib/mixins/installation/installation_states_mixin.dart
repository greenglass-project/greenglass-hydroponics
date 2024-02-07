import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/datamodels/nodes/metric_value.dart';

mixin InstallationStatesMixin<T extends StatefulWidget> on State<T> {

  final ms = MicroserviceService.ms;
  var logger = Logger();

  void installationState(String installationId, Function(MetricValue) onValue ) {
    final requestTopic = "findone.installations.$installationId.state";
    final eventTopic = "event.installations.$installationId.state";

    logger.d("Sending request to $requestTopic");
    ms.requestNoParameters(requestTopic, (r) => onValue(MetricValue.fromJson(r)), (c,m){});

    logger.d("Listening to $eventTopic");
    ms.listen(eventTopic, (r) {
      logger.d("Received INSTALLATION STATE");
      onValue(MetricValue.fromJson(r));
    });
  }

  void processState(String installationId, String processId, Function(MetricValue) onValue ) {
    final requestTopic = "findone.installations.$installationId.processes.$processId.state";
    final eventTopic = "event.installations.$installationId.processes.$processId.state";

    logger.d("Sending request to $requestTopic");
    ms.requestNoParameters(requestTopic, (r) => onValue(MetricValue.fromJson(r)), (c,m){});

    logger.d("Listening to $eventTopic");
    ms.listen(eventTopic, (r) {
      logger.d("Received PROCESS STATE");
      onValue(MetricValue.fromJson(r));
    });
  }

  void processVariableValue(String installationId, String processId, String variableId, Function(MetricValue) onValue ) {
    final requestTopic = "findone.installations.$installationId.processes.$processId.variables.$variableId.state";
    final eventTopic = "event.installations.$installationId.processes.$processId.variables.$variableId.stat";

    logger.d("Sending request to $requestTopic");
    ms.requestNoParameters(requestTopic, (r) => onValue(MetricValue.fromJson(r)), (c,m){});

    logger.d("Listening to $eventTopic");
    ms.listen(eventTopic, (r) {
      logger.d("Received VARIABLE VALUE");
      onValue(MetricValue.fromJson(r));
    });
  }
}
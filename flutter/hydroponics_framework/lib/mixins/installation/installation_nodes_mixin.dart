import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/datamodels/nodes/physical_eon_node.dart';

mixin InstallationNodesMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  late String installationId;
  List<PhysicalEonNode> nodes = [];

  @override
  void initState() {
    initialise();
    super.initState();
  }

  void initialise() {
    final topic = "findone.installations.$installationId.nodes";
    logger.d("Sending request to $topic");
    ms.requestListNoParameters(topic, (r) {
      logger.d("Received NODE LIST");
      setState(() => nodes = r.map((pn) => PhysicalEonNode.fromJson(pn)).toList());
    }, (c,m) {});
  }
}

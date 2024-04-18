import 'package:flutter/material.dart';
import 'package:hydroponics_framework/datamodels/installation/installation_node_model.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';

mixin InstallationNodesMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  late String installationId;
  List<InstallationNodeModel> nodes = [];

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
      setState(() {
        for(var inm in r) {
          nodes.add(InstallationNodeModel.fromJson(inm));
        }
      });
    }, (c, m) {
      logger.d("Parsing error $c $m ");
    });
  }
}

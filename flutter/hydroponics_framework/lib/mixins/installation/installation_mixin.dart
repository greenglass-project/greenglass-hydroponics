import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/datamodels/installation/installation_model.dart';

import '../../datamodels/nodes/physical_eon_node.dart';

mixin InstallationMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  late PhysicalEonNode eonNode;
  late String installationId;
  InstallationModel? installation;

  @override
  void initState() {
    initialise();
    super.initState();
  }

  void initialise() {
    final topic = "findone.installations.$installationId";
    logger.d("Sending request to $topic");
    ms.requestNoParameters(topic, (r) {
      logger.d("Received INSTALLATION");
      setState(() => installation = InstallationModel.fromJson(r));
    }, (c,m) {});
  }
}

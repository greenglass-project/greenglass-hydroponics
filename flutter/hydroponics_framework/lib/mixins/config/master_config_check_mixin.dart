import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';

mixin MasterConfigCheckMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  bool? exists;

  @override
  void initState() {
    const topic = "findone.masterconfig";
    logger.d("Sending request to $topic");
    ms.requestNoParameters(topic,
            (r) => setState(() => exists = true),
            (c,m) => setState(() => exists = false),
    );
    super.initState();
  }
}
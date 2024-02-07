import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/datamodels/system/system_model.dart';

mixin SystemsListMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  Map<String,SystemModel> systems = {};

  @override
  void initState() {
    initialise();
    super.initState();
  }

  void initialise() {
    const topic = "findall.systems";
    logger.d("Sending request to $topic");
    ms.requestListNoParameters(topic, (r) =>
        setState(() {
          for(var j in r) {
            final sm = SystemModel.fromJson(j);
            systems[sm.systemId] = sm;
          }
        }), (c,m) {});
    ms.listen("event.systems.*", (r) =>
        setState(() {
            final sm = SystemModel.fromJson(r);
            systems[sm.systemId] = sm;
        }),
    );
  }
}

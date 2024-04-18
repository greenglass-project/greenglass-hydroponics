import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/datamodels/implementation/implementation_model.dart';

mixin ImplementationsListMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  Map<String,ImplementationModel> implementations = {};

  @override
  void initState() {
    initialise();
    super.initState();
  }

  void initialise() {
    const topic = "findall.implementations";
    logger.d("Sending request to $topic");
    ms.requestListNoParameters(topic, (r) =>
        setState(() {
          for (var j in r) {
            final im = ImplementationModel.fromJson(j);
            implementations[im.implementationId] = im;
          }
        }), (c,m) {});
    ms.listen("event.implementations.*", (r) =>
        setState(() {
          final sm = ImplementationModel.fromJson(r);
          implementations[sm.systemId] = sm;
        }),
    );
  }
}

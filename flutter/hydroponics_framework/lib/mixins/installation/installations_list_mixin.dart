import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/datamodels/installation/installation_view_model.dart';

mixin InstallationsListMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  Map<String,InstallationViewModel> installations = {};

  @override
  void initState() {
    initialise();
    super.initState();
  }

  void initialise() {
    const topic = "findall.installations";
    logger.d("Sending request to $topic");
    ms.requestListNoParameters(topic, (r) =>
        setState(() {
          for(var j in r) {
            final ivm = InstallationViewModel.fromJson(j);
            installations[ivm.installationId] = ivm;
        }
    }), (c,m) {});
    ms.listen("event.installations.*", (r) =>
      setState(() {
        final sm = InstallationViewModel.fromJson(r);
        installations[sm.installationId] = sm;
      }),
    );
  }
}

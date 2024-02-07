import 'package:flutter/material.dart';
import 'package:hydroponics_framework/datamodels/job/job_model.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/microservices/errors.dart';

mixin JobMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  late String installationId;
  JobModel? job;

  @override
  void initState() {
    initialise();
    super.initState();
  }

  void initialise() {
    final topic = "findone.installations.$installationId.job";
    logger.d("Sending request to $topic");
    ms.requestNoParameters(topic, (r) {
        setState(() {
          job = JobModel.fromJson(r);
          onSuccess();
        });
      }, (c,m) {
        if(c == Errors.objectNotAvailable) {}
          setState(() => job = null);
      });
    ms.listen("event.installations.$installationId.job", (r) =>
        setState(() {
          job = JobModel.fromJson(r);
          onSuccess();
        }),
    );
  }
  void onSuccess() {}

}

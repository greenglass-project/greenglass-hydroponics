import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/datamodels/job/job_context_model.dart';

mixin StartJobMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  void startJob(String instanceId, Function(JobContextModel) onSuccess, Function(String,String) onError ) {
    final topic = "startjob.installations.$instanceId.job";
    logger.d("Sending request to $topic");
    ms.requestNoParameters(topic,
            (r) => onSuccess(JobContextModel.fromJson(r)),
            (c,m) => onError(c,m));
  }
}

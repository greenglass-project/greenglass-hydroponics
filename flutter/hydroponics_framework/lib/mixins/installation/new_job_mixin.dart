import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/datamodels/job/start_job_model.dart';
import 'package:hydroponics_framework/datamodels/job/job_context_model.dart';

mixin NewJobMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  void newJob(String instanceId, String recipeId, Function(JobContextModel) onSuccess, Function(String,String) onError ) {
    final topic = "newjob.installations.$instanceId.recipes.$recipeId";
    logger.d("Sending request to $topic");
    ms.request(topic, StartJobModel(instanceId,recipeId),
            (r) => onSuccess(JobContextModel.fromJson(r!)),
            (c,m) => onError(c,m));
  }
}

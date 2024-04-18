import 'dart:async';

import 'package:hydroponics_framework/datamodels/job/job_context_model.dart';
import 'package:hydroponics_framework/datamodels/job/job_state.dart';
import 'package:hydroponics_framework/datamodels/job/job_state_model.dart';
import 'package:hydroponics_framework/datamodels/job/job_phase_model.dart';
import 'package:hydroponics_framework/microservices/errors.dart';
import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

class JobProvider {
  final String installationId;

  JobContextModel? contextModel;

  ReplaySubject<JobContextModel?> jobContextStream = ReplaySubject(maxSize: 1);
  final ms = MicroserviceService.ms;
  final logger = Logger();

  JobProvider(this.installationId) {
    // Find the job - if any
    ms.requestNoParameters("findone.installations.$installationId.job", (m) {
      JobContextModel ctxModel = JobContextModel.fromJson(m);
      logger.d("Received job");
      _handleContext(ctxModel);
      }, (code, msg) {
        if(code == Errors.objectNotAvailable) {
          // If no job found listen to the installation to
          // detect when a job is created
          ms.listen("event.installations.$installationId.job", (m) {
            JobContextModel ctxModel = JobContextModel.fromJson(m);
            logger.d("Received job");
            _handleContext(ctxModel);
          });
        } else {
          logger.e("Error $code $msg");
        }
      });
  }

  void _handleContext(JobContextModel ctxModel) {

    contextModel = ctxModel;
    ms.listen("event.jobs.${contextModel!.job.jobId}.phase", (m) {
      JobPhaseModel pm = JobPhaseModel.fromJson(m);
      contextModel!.job.phaseId = pm.phaseId;
      jobContextStream.add(contextModel);
    });
    ms.listen("event.jobs.${contextModel!.job.jobId}.state", (m) {
      JobStateModel sm = JobStateModel.fromJson(m);
      if(sm.state == JobState.aborted || sm.state == JobState.complete) {
        contextModel = null;
        jobContextStream.add(null);
        ms.listen("event.installations.$installationId.job", (m) {
          JobContextModel ctxModel = JobContextModel.fromJson(m);
          logger.d("Received job");
          _handleContext(ctxModel);
        });
      } else {
        contextModel!.job.state = sm.state;
        jobContextStream.add(contextModel);
      }
    });
    logger.d("Publishing job");
    jobContextStream.add(ctxModel);
  }
}
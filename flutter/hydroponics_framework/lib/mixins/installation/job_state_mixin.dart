import 'package:logger/logger.dart';
import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/datamodels/job/job_state.dart';

mixin JobStateMixin {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  void changeState(String installationid, JobState state, Function onSuccess, Function(String,String) onError) {
    final topic = "set.installations.$installationid.job.state.${state.name}";
    logger.d("Sending request to $topic");
    ms.requestNoParameters(topic, (r) => onSuccess(), (c,m) => onError(c,m));
  }
}
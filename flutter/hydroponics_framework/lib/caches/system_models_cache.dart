import 'dart:async';

import 'package:get/get.dart';

import 'package:hydroponics_framework/datamodels/system/system_model.dart';
import 'package:hydroponics_framework/microservices/microservice_service.dart';

class SystemModelsCache {
  final ms = MicroserviceService.ms;
  static SystemModelsCache get cache => Get.find();

  Map<String,SystemModel> cacheMap = {};

  Future<SystemModel> systemModel(String systemId) async {
    final completer = Completer<SystemModel>();
    final model = cacheMap[systemId];
    if (model == null) {
      final topic = "findone.systems.$systemId";
      ms.requestNoParameters(topic, (r) {
        cacheMap[systemId] = SystemModel.fromJson(r);
        completer.complete(cacheMap[systemId]);
      }, (c,m) {});
      return completer.future;;
    } else {
      return model;
    }
  }
}
import 'dart:async';
import 'package:get/get.dart';

import 'package:hydroponics_framework/datamodels/recipes/plant_definition.dart';
import 'package:hydroponics_framework/microservices/microservice_service.dart';

class PlantModelCache {
  final ms = MicroserviceService.ms;
  static PlantModelCache get cache => Get.find();

  Map<String,PlantDefinition> cacheMap = {};

  Future<PlantDefinition> plantModel(String plantId) async {
    final completer = Completer<PlantDefinition>();
    final model = cacheMap[plantId];
    if (model == null) {
      final topic = "findone.plants.$plantId";
      ms.requestNoParameters(topic, (r) {
        cacheMap[plantId] = PlantDefinition.fromJson(r);
        completer.complete(cacheMap[plantId]);
      }, (c,m) {});
      return completer.future;;
    } else {
      return model;
    }
  }
}
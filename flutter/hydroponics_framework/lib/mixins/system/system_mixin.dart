import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/datamodels/system/system_model.dart';

import 'package:hydroponics_framework/caches/system_models_cache.dart';

mixin SystemMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  final cache = SystemModelsCache.cache;
  var logger = Logger();

  late String systemId;

  SystemModel? system;

  @override
  void initState() {

    //setState(() async => await cache.systemModel(systemId));

    final topic = "findone.systems.$systemId";
    logger.d("Sending request to $topic");
    ms.requestNoParameters(topic, (r) =>
        setState(() => system = SystemModel.fromJson(r)),
            (c,m) {});
    super.initState();

  }

}

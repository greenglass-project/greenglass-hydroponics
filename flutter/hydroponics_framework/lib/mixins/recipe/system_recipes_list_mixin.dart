import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/datamodels/recipes/system_recipes_view_model.dart';

mixin SystemRecipesListMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  late String plantId;
  late String systemId;
  List<SystemRecipesViewModel> recipes = [];

  @override
  void initState() {
    initialise();
    super.initState();
  }

  void initialise() {
    final topic = "findall.systems.$systemId.recipes";
    logger.d("Sending request to $topic");
    ms.requestListNoParameters(topic, (r) {
      logger.d("Received ");

      if (mounted) {
        setState(() =>
        recipes = r.map((s) => SystemRecipesViewModel.fromJson(s)).toList());
      }
    }, (c,m) {});
  }
}

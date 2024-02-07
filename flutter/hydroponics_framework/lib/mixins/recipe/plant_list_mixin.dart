import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/datamodels/recipes/plant_definition.dart';
import 'package:hydroponics_framework/microservices/microservice_service.dart';



mixin PlantsListMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  Map<String,PlantDefinition> plants = {};

  @override
  void initState() {
    initialise();
    super.initState();
  }

  void initialise() {
    const topic = "findall.plants";
    logger.d("Sending request to $topic");
    ms.requestListNoParameters(topic, (r) =>
        setState(() {
          for(var j in r) {
            final pd = PlantDefinition.fromJson(j);
            plants[pd.plantId] = pd;
          }}), (c,m) {});
    ms.listen("event.plants", (r) =>
        setState(() {
          final pd = PlantDefinition.fromJson(r);
          plants[pd.plantId] = pd;
        }),
    );
  }
}

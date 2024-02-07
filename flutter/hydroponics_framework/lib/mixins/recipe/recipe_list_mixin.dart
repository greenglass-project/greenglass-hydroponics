import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/datamodels/recipes/recipe_view_model.dart';

import '../../datamodels/recipes/recipe_model.dart';


mixin RecipeListMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  late String plantId;
  late String systemId;
  Map<String,RecipeViewModel> recipes = {};

  @override
  void initState() {
    initialise();
    super.initState();
  }

  void initialise() {
    final topic = "findall.plants.$plantId.systems.$systemId.recipes";

    logger.d("Sending request to $topic");
    ms.requestListNoParameters(topic, (r) =>
        setState(() {
          for(var j in r) {
            final rvm = RecipeViewModel.fromJson(j);
             recipes[rvm.recipeId] = rvm;
          }
        }), (c,m) {});

    ms.listen("event.plants.$plantId.systems.$systemId.recipes", (r) =>
        setState(() {
          final rvm = RecipeViewModel.fromJson(r);
          recipes[rvm.systemId] = rvm;
        }),
    );
  }
}

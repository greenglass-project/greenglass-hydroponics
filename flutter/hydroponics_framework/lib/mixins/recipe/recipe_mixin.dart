import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/datamodels/recipes/recipe_model.dart';


mixin RecipeMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  late String? recipeId;
  RecipeModel? recipe;

  @override
  void initState() {
    if(recipeId != null) {
      final topic = "findone.recipes.$recipeId";
      logger.d("Sending request to $topic");
      ms.requestNoParameters(topic,
              (r) => setState(() {
                recipe = RecipeModel.fromJson(r);
                onSuccess();
              }),
              (c,m) => {});
    }
    super.initState();
  }

  void onSuccess() {}

}

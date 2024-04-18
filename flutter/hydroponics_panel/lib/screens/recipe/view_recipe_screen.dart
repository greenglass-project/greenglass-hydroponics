import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/mixins/error/error_dialog_mixin.dart';
import 'package:hydroponics_panel/screens/recipe/edit_recipe_dialog.dart';
import 'package:hydroponics_panel/screens/recipe/phases/view_phases_component.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import 'package:industrial_theme/components/industrial_screen.dart';
import 'package:hydroponics_framework/datamodels/recipes/recipe_model.dart';
import 'package:hydroponics_framework/datamodels/system/system_model.dart';
import 'package:hydroponics_framework/microservices/microservice_service.dart';

import 'package:hydroponics_panel/screens/recipe/phases/phase_detail_component.dart';
import 'package:hydroponics_panel/screens/recipe/phases/phase_list_provider.dart';

class ViewRecipeScreen extends StatefulWidget {
  final SystemModel system;
  final String plantId;
  final String? recipeId;

  const ViewRecipeScreen({
    required this.system,
    required this.plantId,
    this.recipeId,
    super.key
  });

  @override
  State<StatefulWidget> createState() => _ViewRecipeScreenState();
}

class _ViewRecipeScreenState extends State<ViewRecipeScreen> with ErrorDialogMixin {
  late SystemModel system;
  late String plantId;
  String? description;
  //late String screenName;
  RecipeModel? recipe;

  final ms = MicroserviceService.ms;
  var logger = Logger();
  final formKey = GlobalKey<FormBuilderState>();

  PhaseListProvider phases = PhaseListProvider();
  @override
  void initState() {

    plantId = widget.plantId;
    system = widget.system;
    if(widget.recipeId != null) {
      ms.requestNoParameters(
          "findone.recipes.${widget.recipeId}", (m) =>
          setState(() {
            recipe = RecipeModel.fromJson(m);
            phases.load(recipe!.phases);
          }),
        (p0, p1) => null);
      ms.listen("event.recipes.${widget.recipeId}", (m) =>
          setState(() {
            recipe = RecipeModel.fromJson(m);
            phases.load(recipe!.phases);
          }));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(recipe == null) {
      return Container();
    } else {
      return IndustrialScreen(
          name: "Recipe",
          enableBack: true,
          topAction: ActionScreenDetails(
              icon: Icons.edit_note_sharp,
              onClick: () {
                ms.requestNoParameters("inuse.recipes.${recipe!.recipeId}",
                        (r) => Get.dialog(EditRecipeDialog(
                            system: system, plantId: plantId, recipe: recipe!)
                        ),
                        (error, msg) => displayError(context,error,msg));
              },
              iconColor: Colors.white),
          body: Padding(
              padding: const EdgeInsets.fromLTRB(50, 10, 50, 0),
              child: Column(
                  children: [
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.fromLTRB(0, 30, 30, 30),
                              child:
                              Text(recipe?.description ?? description!,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .labelMedium)
                          )
                        ]),
                    Expanded(
                        child:
                        Row(children: [
                          Expanded(flex: 1,
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.greenAccent,
                                        width: 1.0,
                                        style: BorderStyle.solid),
                                  ),
                                  child: ViewPhasesComponent(
                                    system: system,
                                    phases: phases,
                                  )
                              )
                          ),
                          Expanded(flex: 3,
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.greenAccent,
                                        width: 1.0,
                                        style: BorderStyle.solid),
                                  ),
                                  child: PhaseDetailComponent(
                                    system: system,
                                    modelStream: phases.modelStream(),
                                    phases: phases,
                                  ))
                          )
                        ])

                    )
                  ])));
    }
  }


  void validateAndSave() {
    if (formKey.currentState != null &&
        formKey.currentState!.saveAndValidate() == true) {
      if (phases.size() > 0) {
        RecipeModel newRecipe;
        if(recipe == null) {
          newRecipe = RecipeModel(
            recipeId: Uuid().v4(),
            systemId: widget.system.systemId,
            plantId : widget.plantId,
            description: description!,
            phases: phases.phases
          );
          ms.request("add.recipe",newRecipe, (result) => Get.back(),
          (p0, p1) => null);
        } else {
          newRecipe = RecipeModel(
              recipeId: recipe!.recipeId,
              systemId: recipe!.systemId,
              plantId : recipe!.plantId,
              description: description!,
              phases: phases.phases
          );
        }
        logger.d("Recipe id ${recipe!.recipeId}");
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/mixins/error/error_dialog_mixin.dart';
import 'package:hydroponics_panel/screens/recipe/phases/edit_phases_component.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import 'package:hydroponics_framework/datamodels/recipes/recipe_model.dart';
import 'package:hydroponics_framework/datamodels/system/system_model.dart';
import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_panel/screens/recipe/phases/phase_detail_component.dart';
import 'package:hydroponics_panel/screens/recipe/screen_mode.dart';
import 'package:hydroponics_panel/screens/recipe/phases/phase_list_provider.dart';

class EditRecipeDialog extends StatefulWidget {
  final SystemModel system;
  final String plantId;
  final RecipeModel? recipe;

  const EditRecipeDialog(
      {required this.system, required this.plantId, this.recipe, super.key});

  @override
  State<StatefulWidget> createState() => _EditRecipeDialogState();
}

class _EditRecipeDialogState extends State<EditRecipeDialog> with ErrorDialogMixin {
  late SystemModel system;
  late String plantId;
  late String screenName;

  RecipeModel? recipe;
  String? description;
  late ScreenMode mode;

  final ms = MicroserviceService.ms;
  var logger = Logger();
  final formKey = GlobalKey<FormBuilderState>();

  PhaseListProvider phases = PhaseListProvider();
  bool canDrag = false;

  @override
  void initState() {

    system = widget.system;
    recipe = widget.recipe;
    if (recipe != null) {
      phases.load(recipe!.phases);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        //width: double.infinity,
        height: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: 1400,
                  height: 900,
                  child: Card(
                      elevation: 0,
                      color: Colors.black,
                      margin: const EdgeInsetsDirectional.only(
                          start: 20.0, end: 20.0, top: 0, bottom: 50),
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white)),
                      child: FormBuilder(
                          key: formKey,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(50, 10, 50, 0),
                              child: Column(children: [
                                Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 10, 30, 30),
                                          child: Text(
                                              "Description ", //widget.recipe.description,
                                              style: Theme
                                                      .of(context)
                                                      .textTheme
                                                      .labelMedium),
                                            ),
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                                    30, 10, 30, 30),
                                                child: SizedBox(width: 500,
                                                child:
                                                FormBuilderTextField(
                                                    autofocus: true,
                                                    name: 'description',
                                                    initialValue: recipe?.description,
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white
                                                    ),
                                                    validator: FormBuilderValidators.compose([
                                                      FormBuilderValidators.required(
                                                          errorText: "Please enter a description"),
                                                      FormBuilderValidators.minLength(4,
                                                          errorText: "description must be at least 4 chars")
                                                    ]),
                                                    onSaved: (v) => description = v
                                            ),
                                      )),
                                      const Spacer(),
                                    ]),
                                Expanded(
                                    child: Row(children: [
                                  Expanded(
                                      flex: 1,
                                      child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.greenAccent,
                                                width: 1.0,
                                                style: BorderStyle.solid),
                                          ),
                                          child: EditPhasesComponent(
                                              system: system,
                                              phases : phases,
                                          ))),
                                  Expanded(
                                      flex: 3,
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
                                              mode: ScreenMode.edit
                                          )))
                                ])),
                                Row(children: [
                                  InkWell(
                                      onTap: () => Get.back(result: false),
                                      child: const Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Icon(Icons.clear,
                                            color: Colors.red, size: 48),
                                      )),
                                  const Spacer(),
                                  InkWell(
                                      onTap: () => validateAndSave(),
                                      child: const Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Icon(Icons.done,
                                            color: Colors.green, size: 48),
                                      )),
                                ]),
                              ])))))
            ]));
  }

  void validateAndSave() {
    if (formKey.currentState != null &&
        formKey.currentState!.saveAndValidate() == true) {
      if (phases.size() > 0) {
        RecipeModel newRecipe;
        if (recipe == null) {
          newRecipe = RecipeModel(
              recipeId: Uuid().v4(),
              systemId: widget.system.systemId,
              plantId: widget.plantId,
              description: description!,
              phases: phases.phases);
          ms.request("add.recipe", newRecipe,
                  (result) => Get.back(),
                  (code, msg) => displayError(context, code, msg)
          );
        } else {
          newRecipe = RecipeModel(
              recipeId: recipe!.recipeId,
              systemId: recipe!.systemId,
              plantId: recipe!.plantId,
              description: description!,
              phases: phases.phases);
          ms.request("update.recipes.${recipe!.recipeId}", newRecipe,
                  (result) => Get.back(),
                  (code, msg) => displayError(context, code, msg)
          );
        }
        logger.d("Recipe id ${recipe!.recipeId}");
      }
    }
  }
}

import 'package:hydroponics_framework/datamodels/recipes/plant_definition.dart';
import 'package:hydroponics_framework/datamodels/recipes/recipe_model.dart';
import 'job_model.dart';
import 'mutable_job_model.dart';

class JobContextModel {
  final MutableJobModel job;
  final RecipeModel recipe;
  final PlantDefinition plant;

  JobContextModel({required this.job, required this.recipe, required this.plant});

  static JobContextModel fromJson(Map<String, dynamic> json) {
    return JobContextModel(
      job: JobModel.fromJson(json["job"]).toMutableJobModel(),//??
      recipe: RecipeModel.fromJson(json["recipe"]),
      plant: PlantDefinition.fromJson(json["plant"])
    );
  }
}

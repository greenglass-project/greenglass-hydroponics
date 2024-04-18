import 'package:hydroponics_framework/datamodels/json_model.dart';
import 'package:hydroponics_framework/datamodels/recipes/phase/phase_model.dart';

class RecipeModel implements JsonModel{
  late String recipeId;

  late String systemId;
  late String plantId;
  late String description;
  late List<PhaseModel> phases;

  RecipeModel({
    required this.recipeId,
    required this.systemId,
    required this.plantId,
    required this.description,
    required this.phases
  });

  RecipeModel.fromJson(Map<String, dynamic> json) {
    recipeId = json["recipeId"];
    systemId = json["systemId"];
    plantId = json["plantId"];
    description = json["description"];

    phases = List<Map<String,dynamic>>.from(json["phases"]).map(
            (p) => PhaseModel.fromJson(p)
    ).toList();
  }

  bool equals(RecipeModel other) {
    return
        recipeId == other.recipeId &&
          systemId == other.recipeId &&
          plantId == other.plantId &&
            description == other.description &&
        phases.length == other.phases.length;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map["recipeId"] = recipeId;
    map["systemId"] = systemId;
    map["plantId"] = plantId;
    map["description"] = description;
    map["phases"] = phases.map((p) => p.toJson()).toList();
    return map;
  }
}
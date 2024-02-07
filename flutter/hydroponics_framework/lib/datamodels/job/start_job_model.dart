import 'package:hydroponics_framework/datamodels/json_model.dart';

class StartJobModel extends JsonModel{
  late String installationId;
  late String recipeId;

  StartJobModel(this.installationId, this.recipeId);

  StartJobModel.fromJson(Map<String, dynamic> json) {
    installationId = json["installationId"];
    recipeId = json["recipeId"];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "installationId" : installationId,
      "recipeId" : recipeId
    };
  }
}
import 'package:hydroponics_framework/datamodels/json_model.dart';

class PlantDefinition implements JsonModel {
  late String plantId;
  late String name;
  late String description;
  late String image;

  PlantDefinition(this.plantId, this.name, this.description, this.image);

  PlantDefinition.fromJson(Map<String, dynamic> json) {
    plantId = json["plantId"];
    name = json["name"];
    description = json["description"];
    image = json["image"];
  }

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}
import 'package:hydroponics_framework/datamodels/systemtype/process_variable_type_model.dart';
import 'package:hydroponics_framework/datamodels/systemtype/schedule_type_model.dart';

class SystemTypeModel {
  late String id;
  late String name;
  late String description;
  late String image;

  late String categoryId;
  late List<ProcessVariableTypeModel> processvariables;

  SystemTypeModel(this.id,
      this.name,
      this.description,
      this.image,
      this.categoryId,
      this.processvariables,
      );

  SystemTypeModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    description = json["description"];
    image = json["image"];
    categoryId = json["categoryId"];
    processvariables = List<Map<String, dynamic>>.from(json["processvariables"]).map(
            (p) => ProcessVariableTypeModel.fromJson(p)).toList();
  }
}
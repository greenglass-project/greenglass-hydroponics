class RecipeViewModel {
  late String recipeId;
  late String description;
  late String plantId;
  late String plantName;
  late String plantImage;
  late String systemId;
  late String systemName;

  RecipeViewModel(
      this.recipeId,
      this.description,
      this.plantId,
      this.plantName,
      this.plantImage,
      this.systemId,
      this.systemName );

  RecipeViewModel.fromJson(Map<String,dynamic> json) {
    recipeId = json["recipeId"];
    description = json["description"];
    plantId = json["plantId"];
    plantName = json["plantName"];
    plantImage = json["plantImage"];
    systemId = json["systemId"];
    systemName = json["systemName"];
  }
}
class SystemRecipesViewModel {
  late String plantId;
  late String name;
  late String image;
  late List<String> recipes;

  SystemRecipesViewModel({required this.plantId, required this.name, required this.image, required this.recipes});

  static SystemRecipesViewModel fromJson(Map<String, dynamic> json) =>
      SystemRecipesViewModel(
        plantId : json["plantId"],
        name : json["name"],
        image :json["image"],
        recipes : List<String>.from(json["recipes"])
      );
}
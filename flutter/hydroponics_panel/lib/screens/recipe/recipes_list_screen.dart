import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydroponics_panel/screens/recipe/screen_mode.dart';
import 'package:hydroponics_panel/screens/recipe/view_recipe_screen.dart';
import 'package:logger/logger.dart';

import 'package:industrial_theme/components/grid_card_menu.dart';
import 'package:industrial_theme/components/menucards/add_menu_card.dart';
import 'package:industrial_theme/components/menucards/text_menu_card.dart';
import 'package:industrial_theme/components/industrial_screen.dart';

import 'package:hydroponics_framework/datamodels/system/system_model.dart';
import 'package:hydroponics_framework/mixins/recipe/recipe_list_mixin.dart';
import 'description_dialog.dart';
import 'edit_recipe_dialog.dart';

class RecipesListScreen extends StatefulWidget {
  final String plantId;
  final String plantName;
  final SystemModel system;
  final logger = Logger();

  RecipesListScreen(this.plantId, this.plantName, this.system, {super.key});

  @override
  State<StatefulWidget> createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends State<RecipesListScreen> with RecipeListMixin {

  @override
  void initState() {
    plantId = widget.plantId;
    systemId = widget.system.systemId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(
        name: "${widget.system.name.capitalizeFirst} ${widget.plantName.toLowerCase()} recipes",
        enableBack: true,
        //topActionScreen: ActionScreenDetails(
        //    icon: Icons.add,
        //    onClick: () => Get.to(AddViewRecipeScreen(widget.plantId, widget.plantName, widget.system))?.then((_) =>
        //      setState(() => initialise())
        //    )
        //), //toNamed(SystemCategoriesMenu.route)),
        body: GridCardMenu(menuCards: _menuCards())
    );
  }

  List<Widget> _menuCards() {
    List<Widget> list = [];
    for (var recipe in recipes.values) {
      list.add(TextMenuCard(
          label: recipe.description,
          //description: "",
          onTap: () => Get.to(() =>  ViewRecipeScreen(
              system : widget.system,
              plantId : widget.plantId,
              recipeId: recipe.recipeId,
          )),
          borderColour: Colors.green
      ));
   }
    list.add(AddMenuCard(
        label : "Add recipe",
        onTap: () =>
            Get.dialog(EditRecipeDialog(
                system: widget.system,
                plantId: widget.plantId,
            )
        ),
        borderColour: Colors.white54
    ));
    return list;
  }
}

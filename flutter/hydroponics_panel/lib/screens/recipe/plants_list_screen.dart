import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:industrial_theme/components/industrial_screen.dart';
import 'package:industrial_theme/components/grid_card_menu.dart';

import 'package:hydroponics_framework/datamodels/recipes/plant_definition.dart';
import 'package:hydroponics_framework/mixins/recipe/plant_list_mixin.dart';
import 'package:hydroponics_framework/components/stream_image_menu_card.dart';

import 'package:hydroponics_panel/screens/recipe/recipes_list_screen.dart';
import 'package:hydroponics_panel/screens/recipe/plants_config_screen.dart';
import 'package:hydroponics_framework/datamodels/system/system_model.dart';
import 'package:industrial_theme/components/menucards/add_menu_card.dart';

class PlantsListScreen extends StatefulWidget {
  final SystemModel system;
  PlantsListScreen(this.system, {super.key});

  @override
  State<StatefulWidget> createState() => _PlantsListScreenState();
}

class _PlantsListScreenState extends State<PlantsListScreen> with PlantsListMixin {

  //@override
  //void initState() {
  //  super.initState();
  //}

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(
        name: "Plant Types",
        enableBack: true,
        //topActionScreen: ActionScreenDetails(
        //    icon: Icons.add,
        //    onClick: () => Get.to(() => PlantsConfigScreen())?.then(
        //            (_) => setState(() => initialise() ))
        //        ),
        body: GridCardMenu(menuCards: _menuCards())
    );
  }

  List<Widget> _menuCards() {
    List<Widget> list = [];
    for (PlantDefinition plant in plants.values) {
      list.add(StreamImageMenuCard(
        label: plant.name,
        imageTopic: "findone.plants.${plant.plantId}.image",
        borderColour: Colors.green,
        onTap: () => Get.to(RecipesListScreen(plant.plantId, plant.name, widget.system)),
      ));
    }
    list.add(AddMenuCard(
        label : "Add plant",
        onTap: () =>  Get.to(() => PlantsConfigScreen()),
        borderColour: Colors.white54
    ));
    return list;
  }
}

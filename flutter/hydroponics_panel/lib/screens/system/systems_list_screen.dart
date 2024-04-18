import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:industrial_theme/components/menucards/add_menu_card.dart';
import 'package:logger/logger.dart';

import 'package:industrial_theme/components/grid_card_menu.dart';
import 'package:industrial_theme/components/menucards/text_menu_card.dart';

import 'package:hydroponics_panel/screens/system/system_menu_screen.dart';

import 'package:industrial_theme/components/industrial_screen.dart';
import 'package:hydroponics_framework/datamodels/system/system_model.dart';
import 'package:hydroponics_framework/mixins/system/systems_list_mixin.dart';
import 'package:hydroponics_panel/screens/system/system_config_screen.dart';

class SystemsListScreen extends StatefulWidget {
  final logger = Logger();

  SystemsListScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SystemsListScreenState();
}

class _SystemsListScreenState extends State<SystemsListScreen> with SystemsListMixin {

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(
        name: "System Types",
        enableBack: true,
        //topActionScreen: ActionScreenDetails(
        //    icon: Icons.add,
        //    onClick: () => Get.to(() => SystemConfigScreen())), //Get.toNamed(SystemCategoriesMenu.route)),
        bottomLeftAction: ActionScreenDetails(
            icon: Icons.settings, onClick: () {}), //=> Get.toNamed(SetupMenu.route)),
        body: GridCardMenu(menuCards: _menuCards())
    );
  }

  List<Widget> _menuCards() {
    List<Widget> list = [];
    for (SystemModel system in systems.values) {
      list.add(TextMenuCard(
          label: system.name,
          description: system.description,
          onTap: () => Get.to(() => SystemMenuScreen(system)),
          borderColour: Colors.green
      ));
    }
    /*list.add(AddMenuCard(
        label : "Add system type",
        onTap: () =>  Get.to(() => SystemConfigScreen()),
        borderColour: Colors.white54
    ));*/
    return list;
  }
}

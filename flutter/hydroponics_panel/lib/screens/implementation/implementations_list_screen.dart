import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/datamodels/implementation/implementation_model.dart';
import 'package:hydroponics_framework/mixins/implementation/implementations_list_mixin.dart';
import 'package:hydroponics_panel/screens/implementation/implementation_config_screen.dart';
import 'package:industrial_theme/components/grid_card_menu.dart';
import 'package:industrial_theme/components/industrial_screen.dart';
import 'package:industrial_theme/components/menucards/add_menu_card.dart';
import 'package:industrial_theme/components/menucards/text_menu_card.dart';
import 'package:logger/logger.dart';

import 'implementation_screen.dart';

class ImplementationsListScreen extends StatefulWidget {
  final logger = Logger();

  final String systemId;
  ImplementationsListScreen(this.systemId, {super.key});

  @override
  State<StatefulWidget> createState() => _ImplementationsListScreenState();
}

class _ImplementationsListScreenState extends State<ImplementationsListScreen> with ImplementationsListMixin {

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(
        name: "System Implementations",
        enableBack: true,
        //topActionScreen: ActionScreenDetails(
        //    icon: Icons.add,
        //onClick: () => Get.to(() => ImplemenationConfigScreen())),
       // bottomLeftActionScreen: ActionScreenDetails(
       //     icon: Icons.settings, onClick: () {}),
        body: GridCardMenu(menuCards: _menuCards())
    );
  }

  List<Widget> _menuCards() {
    List<Widget> list = [];
    for (ImplementationModel implementation in implementations.values) {
      list.add(TextMenuCard(
          label: implementation.name,
          onTap: () => Get.to(() => ImplementationScreen(implementation)), //Get.to(() {}),
          borderColour: Colors.orange
      ));
    }
    /*list.add(AddMenuCard(
        label : "Add implementation",
        onTap: () => Get.dialog(ImplemenationConfigScreen()),
        borderColour: Colors.white54
    ));*/
    return list;
  }
}

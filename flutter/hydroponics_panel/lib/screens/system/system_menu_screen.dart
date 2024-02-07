import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/datamodels/system/system_model.dart';
import 'package:hydroponics_panel/screens/recipe/plants_list_screen.dart';
import 'package:hydroponics_panel/screens/system/system_screen.dart';
import 'package:logger/logger.dart';

import 'package:industrial_theme/components/industrial_screen.dart';
import 'package:industrial_theme/components/single_row_card_menu.dart';
import 'package:industrial_theme/components/menucards/image_menu_card.dart';
import 'package:hydroponics_panel/screens/implementation/implementations_list_screen.dart';

class SystemMenuScreen extends StatefulWidget {
  final SystemModel system;
  const SystemMenuScreen(this.system,{super.key});

  @override
  State<StatefulWidget> createState() => _SystemMenuScreenState();
}

class _SystemMenuScreenState extends State<SystemMenuScreen> {
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(
      name: widget.system.name,
      body: SingleRowCardMenu(
        menuCards: [
          ImageMenuCard(
            label: "Control",
            image: Image.asset(
              "assets/design.png",
              package: 'hydroponics_framework',
              fit: BoxFit.fitWidth,
            ),
            borderColour: Colors.blue,
            onTap: () => Get.to(SystemScreen(widget.system)),
          ),
          ImageMenuCard(
            label: "Implementations",
            image: Image.asset(
              "assets/implementation.png",
              package: 'hydroponics_framework',
              fit: BoxFit.fitWidth,
            ),
            borderColour: Colors.orangeAccent,
            onTap: () => Get.to(ImplementationsListScreen(widget.system.systemId)),
          ),
          ImageMenuCard(
            label: "Recipes",
            image: Image.asset(
              "assets/recipe.png",
              package: 'hydroponics_framework',
              fit: BoxFit.fitWidth,
            ),
            borderColour: Colors.green,
            onTap: () => Get.to(PlantsListScreen(widget.system)),
          )
        ],
      ),
      enableBack: true,
    );
  }
}

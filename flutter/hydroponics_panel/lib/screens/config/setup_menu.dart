import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:industrial_theme/components/industrial_screen.dart';
import 'package:industrial_theme/components/single_row_card_menu.dart';
import 'package:industrial_theme/components/menucards/image_menu_card.dart';

import 'package:hydroponics_panel/screens/system/systems_list_screen.dart';
import 'package:hydroponics_panel/screens/nodes/nodetypes_list_screen.dart';

class SetupMenu extends StatefulWidget {
  const SetupMenu({super.key});

  @override
  State<StatefulWidget> createState() => _SetupMenuState();
}

class _SetupMenuState extends State<SetupMenu> {
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(
      name: "Setup",
      body: SingleRowCardMenu(
        menuCards: [
          ImageMenuCard(
            label: "Devices",
            image: Image.asset(
              "assets/devices.png",
              package: 'hydroponics_framework',
              fit: BoxFit.fitWidth,
            ),
            borderColour: Colors.blueAccent,
            onTap: () => Get.to(NodeTypesListScreen())
          ),
          ImageMenuCard(
            label: "Systems",
            image: Image.asset(
              "assets/system.png",
              package: 'hydroponics_framework',
              fit: BoxFit.fitWidth,
            ),
            borderColour: Colors.greenAccent,
            onTap: () => Get.to(SystemsListScreen()),
          ),
        ],
      ),
      enableBack: true,
    );
  }
}

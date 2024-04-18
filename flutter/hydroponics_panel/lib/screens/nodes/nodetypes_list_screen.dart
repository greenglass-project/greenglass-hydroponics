import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/datamodels/nodes/node_type.dart';
import 'package:logger/logger.dart';

import 'package:industrial_theme/components/industrial_screen.dart';
import 'package:industrial_theme/components/grid_card_menu.dart';
import 'package:industrial_theme/components/menucards/add_menu_card.dart';
import 'package:industrial_theme/components/menucards/text_menu_card.dart';

import 'package:hydroponics_framework/mixins/node/nodetypes_list_mixin.dart';

import 'package:hydroponics_panel/screens/nodes/nodetype_screen.dart';
import 'package:hydroponics_panel/screens/nodes/nodetypes_config_screen.dart';

class NodeTypesListScreen extends StatefulWidget {
  final logger = Logger();

  NodeTypesListScreen({super.key});

  @override
  State<StatefulWidget> createState() => _NodeTypesListScreenState();
}

class _NodeTypesListScreenState extends State<NodeTypesListScreen> with NodeTypesListMixin {

  @override
  Widget build(BuildContext context) {
    logger.d("${nodes.length} nodes defined");
    return IndustrialScreen(
        name: "Node Types",
        enableBack: true,
        body: GridCardMenu(menuCards: _menuCards()),
        key: UniqueKey(),
    );
  }

  List<Widget> _menuCards() {
    List<Widget> list = [];
    for (NodeType node in nodes) {
      logger.d("Found node");
      list.add(TextMenuCard(
          label: node.type.replaceAll("_", " "),
          description: node.name,
          onTap: () => Get.to(() => NodeTypeScreen(nodeType: node)), //Get.to(() {}),
          borderColour: Colors.blue
      ));
    }
    /*list.add(AddMenuCard(
        label : "Add node-type",
        onTap: () =>  Get.to(() => NodeTypesConfigScreen()),
        borderColour: Colors.white54
    ));*/
    return list;
  }
}

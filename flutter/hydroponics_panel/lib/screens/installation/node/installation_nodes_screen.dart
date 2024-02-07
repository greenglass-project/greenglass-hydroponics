import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/datamodels/nodes/physical_eon_node.dart';
import 'package:industrial_theme/components/grid_card_menu.dart';
import 'package:industrial_theme/components/industrial_screen.dart';
import 'package:hydroponics_framework/datamodels/installation/installation_view_model.dart';
import 'package:hydroponics_framework/mixins/installation/installation_nodes_mixin.dart';
import 'package:industrial_theme/components/menucards/text_menu_card.dart';

import 'eon_node_screen.dart';

class InstallationNodesScreen extends StatefulWidget {
  final InstallationViewModel installation;

  const InstallationNodesScreen(this.installation, {super.key});

  @override
  State<StatefulWidget> createState() => _InstallationNodesScreenState();
}

class _InstallationNodesScreenState extends State<InstallationNodesScreen> with InstallationNodesMixin {
  get processVariables => null;

  @override
  void initState() {
    installationId = widget.installation.installationId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(
        name: "${widget.installation.instanceName} - EoN Nodes",
        enableBack: true,
        body: GridCardMenu(menuCards: _nodeCards())
    );
  }
  List<Widget> _nodeCards() {
    List<Widget> list = [];
    for (PhysicalEonNode node in nodes) {
      list.add(TextMenuCard(
          label: node.name,
          description: node.description,
          onTap: () => Get.to( () => EonNodeScreen(widget.installation.instanceName, widget.installation.installationId, node)),//Get.to(() {}),
          borderColour: Colors.blue
      ));
    }
    return list;
  }

}

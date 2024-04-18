import 'package:flutter/material.dart';
import 'package:hydroponics_framework/datamodels/installation/installation_node_model.dart';
import 'package:industrial_theme/components/grid_card_menu.dart';
import 'package:industrial_theme/components/industrial_screen.dart';
import 'package:hydroponics_framework/datamodels/installation/installation_view_model.dart';
import 'package:hydroponics_framework/mixins/installation/installation_nodes_mixin.dart';
import 'node_menu_card.dart';

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
        body: Column(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
          children : [
            Expanded( child:
            GridView.count(
                primary: false,
                padding: const EdgeInsets.all(50),
                crossAxisSpacing: 0,
                mainAxisSpacing: 40,
                crossAxisCount: 4,
                childAspectRatio: 1 / 0.85,
                children: _nodeCards()
            ))
          ]
    ));
  }
  List<Widget> _nodeCards() {
    List<Widget> list = [];
    for (InstallationNodeModel node in nodes) {
      list.add(NodeMenuCard(
          installationId: widget.installation.installationId,
          installationName: widget.installation.instanceName,
          node: node));
    }
    return list;
  }

}

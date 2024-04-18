import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:industrial_theme/components/grid_card_menu.dart';
import 'package:industrial_theme/components/industrial_screen.dart';
import 'package:industrial_theme/components/menucards/text_menu_card.dart';
import 'package:industrial_theme/components/menucards/add_menu_card.dart';

import 'package:hydroponics_framework/mixins/installation/installations_list_mixin.dart';
import 'package:hydroponics_framework/datamodels/installation/installation_view_model.dart';
import 'package:hydroponics_panel/screens/config/setup_menu.dart';

import 'add_installation_dialog.dart';
import 'installation_screen.dart';

class InstallationsListScreen extends StatefulWidget {
  final logger = Logger();

  InstallationsListScreen({super.key});

  @override
  State<StatefulWidget> createState() => _InstallationsListScreenState();
}

class _InstallationsListScreenState extends State<InstallationsListScreen> with InstallationsListMixin{

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(
        name: "Installations",
        //enableBack: true,
        //topActionScreen: ActionScreenDetails(
        //    icon: Icons.add,
        //    onClick: () => Get.dialog(const AddInstallationDialog()),
        //),
        bottomLeftAction: ActionScreenDetails(
            icon: Icons.settings, onClick: () => Get.to(const SetupMenu())),
        body: GridCardMenu(menuCards: _menuCards())
    );
  }

  List<Widget> _menuCards() {
    List<Widget> list = [];
    for (InstallationViewModel installation in installations.values) {
      list.add(TextMenuCard(
        label: installation.instanceName,
        description: installation.implementationName,
        onTap: () => Get.to(() => InstallationScreen(installation)), //Get.to(() {}),
        borderColour: Colors.yellow
      ));
    }
    list.add(AddMenuCard(
        label : "Add installation",
        onTap: () => Get.dialog(const AddInstallationDialog()),
        borderColour: Colors.white54
    ));
    return list;
  }
}

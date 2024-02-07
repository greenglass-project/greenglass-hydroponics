import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydroponics_panel/screens/installation/node/installation_nodes_screen.dart';
import 'package:hydroponics_panel/screens/installation/job/phases/phase_component.dart';
import 'package:industrial_theme/components/industrial_screen.dart';
import 'package:hydroponics_framework/datamodels/installation/installation_view_model.dart';

import 'job/job_provider.dart';
import 'job/job_recipe_card.dart';

class InstallationScreen extends StatefulWidget {
  final InstallationViewModel installation;

  const InstallationScreen(this.installation, {super.key});

  @override
  State<StatefulWidget> createState() => _InstallationScreenState();
}

class _InstallationScreenState extends State<InstallationScreen> {
  get processVariables => null;

  late JobProvider jobProvider;
  late String installationId;
  //final streamController = StreamController<bool>.broadcast();

  bool? state;

  @override
  void initState() {
    installationId = widget.installation.installationId;
    jobProvider = JobProvider(installationId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(
        name: widget.installation.instanceName,
        enableBack: true,
        topAction: ActionScreenDetails(
            icon: Icons.account_tree_sharp,
            onClick: () => Get.to(() => InstallationNodesScreen(widget.installation))),

        body: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Column(children: [
              Expanded(
                  //flex: 7,
                  child: Row(children: [
                    Expanded(
                        flex: 2,
                        child: PhaseComponent(
                          installation: widget.installation,
                            jobContextStream: jobProvider.jobContextStream.stream),
                    ),
                    Expanded(
                        flex: 1,
                        child: JobRecipeCard(
                            installation: widget.installation,
                            jobContextStream: jobProvider.jobContextStream.stream),
                    )
                  ])
              )
            ])
        )
    );
  }
}


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/datamodels/installation/installation_view_model.dart';

import '../../menudialog/recipe_dialog.dart';

class NoJobComponent extends StatelessWidget {
  final InstallationViewModel installation;
  const NoJobComponent({required this.installation, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        color: Colors.transparent,
        margin:
            const EdgeInsetsDirectional.only(start: 0.0, end: 25.0, top: 10.0),
        shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.white60)),
        child: Center(
            child: Column(children: [
              Row(
                  children :[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Text("No job",
                            style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.red)
                        )
                    ),
                    const Spacer(),
                  ]),
              const Spacer(),
              Row(children: [
                const Spacer(),
                Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                      style: BorderStyle.solid),
                ),
                child: InkWell(
                    onTap: () => Get.dialog(RecipeDialog(installation.installationId, installation.systemId)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child:
                        Row(children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: Text("Recipe",
                              style: Theme.of(context).textTheme.labelSmall)
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: Icon(Icons.feed_sharp,
                                color: Colors.green,
                                size: 48
                          )),
                    ]))
                )),
            const Spacer()
          ]),
              const Spacer()
        ])));
  }
}

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';

import 'package:industrial_theme/components/industrial_screen.dart';
import 'package:hydroponics_framework/mixins/recipe/plants_config_mixin.dart';
import 'package:hydroponics_framework/microservices/string_value.dart';

class PlantsConfigScreen extends StatefulWidget {
  final logger = Logger();

  PlantsConfigScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PlantsConfigScreenState();
}

class _PlantsConfigScreenState extends State<PlantsConfigScreen> with PlantsConfigMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(
        name: "Plant-type Configuration",
        enableBack: true,
        body: Column(children: [
          Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(100, 100, 100, 100),
                child: ListView(children: _createList(context)),
              ))
        ]));
  }

  List<Widget> _createList(BuildContext context) {
    List<Widget> list = [];
    for (StringValue plant in plantConfig) {
      list.add(Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 10.0),
          child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.orangeAccent,
                    width: 1.0,
                    style: BorderStyle.solid),
              ),
              child: InkWell(
                  onTap: () => addPlant(plant.value, () {
                    logger.d("Received response");
                    Get.back(result: true);
                  }),
                  child: ListTile(
                      title: Text(plant.value,
                          style: Theme.of(context).textTheme.labelMedium),
                      minVerticalPadding: 15.0
                  )
              ))));
    }
    return list;
  }


}

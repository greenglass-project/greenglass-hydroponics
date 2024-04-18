import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';

import 'package:industrial_theme/components/industrial_screen.dart';
import 'package:hydroponics_framework/mixins/system/system_config_mixin.dart';
import 'package:hydroponics_framework/microservices/string_value.dart';

class SystemConfigScreen extends StatefulWidget {
  final logger = Logger();

  SystemConfigScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SystemConfigScreenState();
}

class _SystemConfigScreenState extends State<SystemConfigScreen> with SystemConfigMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(
        name: "System Configurations",
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
    for (StringValue system in systems) {
      list.add(Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 10.0),
          child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.greenAccent,
                    width: 1.0,
                    style: BorderStyle.solid),
              ),
              child: InkWell(
                  onTap: () => addSystem(system.value, () {
                    logger.d("Received response");
                    Get.back();
                  }),
                    child: ListTile(
                    title: Text(system.value,
                          style: Theme.of(context).textTheme.labelMedium),
                      minVerticalPadding: 15.0
                  )
              ))));
    }
    return list;
  }


}

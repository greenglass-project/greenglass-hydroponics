import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';

import 'package:industrial_theme/components/industrial_screen.dart';
import 'package:hydroponics_framework/mixins/node/nodedefinitions_mixin.dart';
import 'package:hydroponics_framework/microservices/string_value.dart';

class NodeTypesConfigScreen extends StatefulWidget {
  final logger = Logger();

  NodeTypesConfigScreen({super.key});

  @override
  State<StatefulWidget> createState() => _NodeTypesConfigScreenState();
}

class _NodeTypesConfigScreenState extends State<NodeTypesConfigScreen> with NodeDefinitionsMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(
        name: "Device-types",
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
    for (StringValue nodeType in nodeTypes) {
      list.add(Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 10.0),
          child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.lightBlue,
                    width: 1.0,
                    style: BorderStyle.solid),
              ),
              child: InkWell(
                  onTap: () => addNodeDefinition(nodeType.value, () {
                    logger.d("Received response");
                    Get.back();
                  }),
                    child: ListTile(
                    title: Text(nodeType.value,
                          style: Theme.of(context).textTheme.labelMedium),
                      minVerticalPadding: 15.0
                  )
              ))));
    }
    return list;
  }


}

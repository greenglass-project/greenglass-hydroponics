import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:industrial_theme/components/industrial_screen.dart';

class SystemSelection extends StatefulWidget {
  const SystemSelection({super.key});

  @override
  State<StatefulWidget> createState() => _SystemSelectionState();
}

class _SystemSelectionState extends State<SystemSelection> {
  String? url;

  // client = Get.find();
  final ms = MicroserviceService.ms;
  var logger = Logger();

  List<String> serverList = ["elnor.local", "host-development.local"];

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(
        name: "Choose system",
      body:Column(children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(200, 100, 200, 100),
            child: ListView(children: _createList(context)),
          ))
    ]));
  }

  List<Widget> _createList(BuildContext context) {
    List<Widget> list = [];
    for (String entry in serverList) {
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
                  onTap: () => _validateAndConnect(entry),
                  child: _tile(entry, context))
          )));
    }
    return list;
  }

  ListTile _tile(String server, BuildContext context) {
      return ListTile(
          title: Text(server,
              style: Theme.of(context).textTheme.labelMedium),
          minVerticalPadding: 15.0
      );
  }

  void _validateAndConnect(String server) => ms.connect(server);
}

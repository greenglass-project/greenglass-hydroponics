import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/datamodels/nodes/node_type.dart';

mixin NodeTypesListMixin<T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  List<NodeType> nodes = [];

  @override
  void initState() {
    initialise();
    super.initState();
  }

  void initialise() {
    const topic = "findall.nodetypes";
    logger.d("Sending request to $topic");
    ms.requestListNoParameters(topic, (r) {
      logger.d("Received response");
      if(mounted) {
        logger.d("Parsing response $r");
        List<NodeType> n = r.map((s) => NodeType.fromJson(s)).toList();
        logger.d("${n.length} nodes found");
        setState(() => nodes = n);
      }
    },(c,m) {
      logger.d("Parsing error $c $m ");
    });
    ms.listen("event.nodetypes.*", (r) {
      if(mounted) {
        setState(() {
          logger.d("Received event");
          final n = NodeType.fromJson(r);
          nodes.add(n);
        });
      }});
  }
}

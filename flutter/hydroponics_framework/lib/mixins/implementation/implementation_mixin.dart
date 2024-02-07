import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/datamodels/system/system_model.dart';
import 'package:hydroponics_framework/datamodels/implementation/implementation_model.dart';

class NodeMetric {
  String type;
  String description;
  String metric;

  NodeMetric(this.type, this.description, this.metric);
}

mixin  ImplementationMixin <T extends StatefulWidget> on State<T> {
  final ms = MicroserviceService.ms;
  var logger = Logger();

  late String implId;

  SystemModel? system;
  ImplementationModel? implementation;
  Map<String,NodeMetric> variableLookup = {};

  @override
  void initState() {
    final implTopic = "findone.implementations.$implId";
    logger.d("Sending request to $implTopic");
    ms.requestNoParameters(implTopic, (r) {
      implementation = ImplementationModel.fromJson(r);
      for(var node in implementation!.nodes) {
        for(var v in node.variables) {
          variableLookup[v.variableId] = NodeMetric(node.type, node.description, v.name);
        }
      }
      var systemTopic = "findone.systems.${implementation!.systemId}";
      logger.d("Sending request to $systemTopic");
      ms.requestNoParameters(implTopic, (r) =>
          setState(() => system = SystemModel.fromJson(r)),
        (c,m) {});
    },(c,m) {});
    super.initState();
  }
}


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hydroponics_framework/datamodels/installation/installation_node_model.dart';
import 'package:hydroponics_framework/mixins/installation/installation_nodes_mixin.dart';
import 'package:industrial_theme/components/industrial_screen.dart';
import 'package:hydroponics_framework/datamodels/nodes/metric.dart';
import 'package:hydroponics_framework/datamodels/nodes/metric_value.dart';
import 'package:hydroponics_framework/mixins/installation/eon_node_mixin.dart';
import 'package:rxdart/rxdart.dart';

import 'editable_metric_value_component.dart';
import 'node_state_indicator.dart';

class NodeControlScreen extends StatefulWidget {
  final String installationName;
  final String installationId;
  final InstallationNodeModel nodeModel;

  const NodeControlScreen({
    required this.installationName,
    required this.installationId,
    required this.nodeModel,
    super.key
  });

  @override
  State<StatefulWidget> createState() => _NodeControlScreenState();
}

class _NodeControlScreenState extends State<NodeControlScreen> with EonNodeMixin {

  @override
  void initState() {
    nodeId = widget.nodeModel.nodeId;
    installationId = widget.installationId;
    nodeStateSubjct = BehaviorSubject();
    metricValueSubjects = {};
    for(Metric m in widget.nodeModel.metrics) {
      BehaviorSubject<MetricValue> controller = BehaviorSubject();
      metricValueSubjects[m.metricName] = controller;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(
        name: "${widget.installationName} - ${widget.nodeModel.nodeName} Node",
        enableBack: true,
        body: Padding(
            padding: const EdgeInsets.fromLTRB(50, 20, 50, 0),
            child: Container(
                color: Colors.transparent,
                child: Column(children: _buildColumn()))));
  }

  List<Widget> _buildColumn() {
    List<Widget> list = [];

    list.add(Row(children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
          child: Text("Type: ${widget.nodeModel.nodeType}",
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: Colors.white60))),
      const Spacer()
    ]));

    list.add(Row(children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
          child: Text("NodeID: ${widget.nodeModel.nodeId}",
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: Colors.white60))),
      const Spacer()
    ]));
    list.add(Row(children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 20, 20),
          child:
              Text("Metrics", style: Theme.of(context).textTheme.titleLarge)),
              const Spacer(),
              NodeStateIndicator(nodeStateSubjct)
    ]));
    list.add(Expanded(child: ListView(children: _buildMetrics())));
    return list;
  }

  List<Widget> _buildMetrics() {
    List<Widget> list = [];

    widget.nodeModel.metrics.sort((a,b) => b.metricName.compareTo(a.metricName));
    for (Metric m in widget.nodeModel.metrics.reversed) {
      list.add(Card(
          elevation: 0,
          color: Colors.transparent,
          margin: const EdgeInsetsDirectional.only(
              start: 0.0, end: 0.0, bottom: 20.0),
          shape: const RoundedRectangleBorder(
              side: BorderSide(color: Colors.white30)),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(children: [
                Expanded(
                    flex: 2,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                        child: Text(m.description,
                            style: Theme.of(context).textTheme.titleSmall))),
                Expanded(
                    flex: 2,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                        child: Text(m.metricName,
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.orange)))),
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                        child: Text(m.type.name,
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.white54)))),
                Expanded(
                     flex: 2,
                     child: Padding(
                         padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                         child: Align(
                             alignment: Alignment.centerRight,
                             child: EditableMetricValueComponent(installationId, nodeId, m, metricValueSubjects[m.metricName]!)
                         )
                     ),
                  )
              ]))));
    }
    return list;
  }


  /*Widget _modify(Metric metric, NodeMetricNameValue value) {
    if(metric.direction == MetricDirection.write && value.value.type != MetricDataType.unknown) {
      return InkWell(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
            child: Center(child: Text("Change", style: Theme.of(context).textTheme.labelSmall))),
          onTap: () => Get.dialog(ModifyMetricValueComponent(value))
      );
    } else {
      return Container();
    }
  }*/
}

import 'package:flutter/material.dart';
import 'package:hydroponics_framework/components/stream_image.dart';
import 'package:hydroponics_framework/datamodels/nodes/node_type.dart';
import 'package:hydroponics_framework/datamodels/nodes/metric.dart';

import 'package:logger/logger.dart';
import 'package:industrial_theme/components/industrial_screen.dart';


class NodeTypeScreen extends StatefulWidget {
  final NodeType nodeType;

  const NodeTypeScreen({required this.nodeType, super.key});

  @override
  State<StatefulWidget> createState() => _NodeTypeScreenState();
}

class _NodeTypeScreenState extends State<NodeTypeScreen> {
  final logger = Logger();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IndustrialScreen(
        name: "${widget.nodeType.name} (${widget.nodeType.type}) ",
        enableBack: true,
        body: Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 20),
            child:Row(children: [
              Expanded(flex : 2, child: Column( children: _description(),)),
              Expanded(flex : 3, child:
                Column(children : [
                  Row( children : [
                    Padding( padding : const EdgeInsets.fromLTRB(20, 0, 5, 10),
                      child: Text("Metrics", textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.titleMedium)
                    ),
                    ]),
                  Expanded(child: ListView(children: _metrics()))
                ])

              )
    ])));
  }

  List<Widget> _description() {
    List<Widget> list = [];
      list.add(Row( children : [
        Padding( padding : const EdgeInsets.fromLTRB(20, 0, 5, 10),
            child: Text("Description", textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.titleMedium)
        ),
      ]));
      list.add(Flexible( child: FractionallySizedBox(
      widthFactor: 0.9,
      heightFactor: 0.7,
      alignment: FractionalOffset.center,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.lightBlue,
            width: 0.5,
          ),
        ),
        child: Center(
          child: StreamImage(
              topic: "findone.nodetypes.${widget.nodeType.type}.image",
              opacity: 1
          ),
        )
      ))));
      list.add(Row( children : [
      Expanded(child: Padding(
        padding : const EdgeInsets.fromLTRB(30, 30, 20, 20),
        child : Text(widget.nodeType.description,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines : 4
        )))]));
      return list;
  }

  List<Widget> _metrics() {
    List<Widget> list = [];
    for(Metric metric in widget.nodeType.metrics) {
      list.add(Padding(
          padding : const EdgeInsets.fromLTRB(20,0,20,10),
          child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.lightBlue,
                    width: 0.5,
                    style: BorderStyle.solid),
              ),
              child: ListTile(
                title: Padding( padding : const EdgeInsets.fromLTRB(0, 0, 0, 6),
                    child : Text(metric.metricName,
                        style: Theme.of(context).textTheme.titleSmall)),
                subtitle: Text(metric.description,
                    style: Theme.of(context).textTheme.bodySmall),
                trailing: Text(metric.type.name,
                    style: Theme.of(context).textTheme.titleSmall)
              )
          )));
    }
    return list;
  }
}

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/components/stream_image.dart';
import 'package:hydroponics_framework/datamodels/installation/installation_node_model.dart';
import 'package:hydroponics_framework/mixins/installation/eon_node_state_mixin.dart';
import 'package:rxdart/rxdart.dart';

import 'node_control_screen.dart';

class NodeMenuCard extends StatefulWidget {
  final String installationName;
  final String installationId;
  final InstallationNodeModel node;

  const NodeMenuCard({
    required this.installationName,
    required this.installationId,
    required this.node,
    super.key
  });

  @override
  State<StatefulWidget> createState() => _NodeMenuCardState();
}

class _NodeMenuCardState extends State<NodeMenuCard> with EonNodeStateMixin {
  Color borderColour = Colors.red;

  @override
  void initState() {
    nodeId = widget.node.nodeId;
    installationId = widget.installationId;
    nodeStateSubjct = BehaviorSubject();
    nodeStateSubjct.listen((value) {
      logger.d("Received STATE ${value.value}");
      //if(value.value is bool) {
        setState(() {
          if(value.value as bool == true) {
            borderColour = Colors.green;
          } else {
            borderColour = Colors.red;
          }
        });

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        color: Colors.transparent,
        margin: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
        shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColour, width: 4)),
        child: InkWell(
            onTap: () => Get.to(() => NodeControlScreen(
                installationId : widget.installationId,
                installationName : widget.installationName,
                nodeModel : widget.node )
            ),
            child: _body(context)));
  }

  Widget _body(BuildContext context) {
    return Column(children: [
      Expanded(
        flex: 1,
          //height: 50,
          child: Center(
              child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: AutoSizeText(
                    widget.node.implName,
                    maxLines: 4,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium,
                  )))),
      Expanded(
        flex : 5,
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: StreamImage(
                      topic: "findone.nodetypes.${widget.node.nodeType}.image",
                      opacity: 1))))
    ]);
  }
}


import 'package:flutter/material.dart';
import 'package:hydroponics_framework/datamodels/nodes/metric_value.dart';
import 'package:rxdart/rxdart.dart';

class NodeStateIndicator extends StatefulWidget {
  final BehaviorSubject<MetricValue> stateStream;
  const NodeStateIndicator(this.stateStream, {super.key});

  @override
  State<StatefulWidget> createState() => _NodeStateIndicatorState();
}

class _NodeStateIndicatorState extends State<NodeStateIndicator> {

  bool state = false;

  @override
  void initState() {
    widget.stateStream.listen((mv) {
      if(mounted) {
        setState(() => state = mv.value as bool);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: state ? Colors.green : Colors.redAccent,
        child: Center(
          child: Padding( padding : const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child:
              Text(state ? "Online" : "Offline",
                style : Theme.of(context).textTheme.labelSmall)
          )
        )
    );
  }
}

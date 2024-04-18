import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../webservice/data_values.dart';
import '../webservice/web_service.dart';

class StreamedValueComponent extends StatefulWidget {
  final String path;
  final Color colour;
  final double fontSize;

  StreamedValueComponent({
    required this.path,
    this.colour = Colors.white,
    this.fontSize = 48.0
  });

  @override
  State<StatefulWidget> createState() => _StreamedValueComponentState();
}

class _StreamedValueComponentState extends State<StreamedValueComponent> {

  double value = 0.0;
  WebService ws = Get.find();

  @override
  void initState() {
    _getValueStream();
    super.initState();
  }

  void _getValueStream() async {
    ws.subscribe(widget.path).listen((v) {
      if (mounted)
        setState(() =>
        value = DoubleValue
            .fromJson(jsonDecode(v))
            .value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
    padding: EdgeInsets.symmetric(vertical : 0, horizontal: 30),
      child : AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
          },
        child: Text(value.toString(),
            key: ValueKey<double>(value),

            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontSize: widget.fontSize, color: widget.colour)
    ),
    ));
  }
}
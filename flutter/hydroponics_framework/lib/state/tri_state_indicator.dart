import 'package:flutter/material.dart';
import 'package:hydroponics_framework/state/state_theme.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/datamodels/nodes/metric_value.dart';

class CirclePainter extends CustomPainter {
  final Color color;
  CirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint();
    paint1.color = color;
    paint1.style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(10,10), 10, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class TriStateIndicator extends StatelessWidget {
  late final bool? value;
  final logger = Logger();

  TriStateIndicator(this.value, {super.key});
  TriStateIndicator.fromMetric(MetricValue? metric, {super.key}) {
    value = metric?.value as bool?;
  }

  @override
  Widget build(BuildContext context) {
    Color colour = StateTheme.triStateDisabled;;
    if (value != null && value == true) {
      colour = StateTheme.triStateOff;
    } else if (value != null && value == false) {
      colour = StateTheme.triStateOn;
    }
    return SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(
          painter: CirclePainter(colour),
        )
    );
  }
}

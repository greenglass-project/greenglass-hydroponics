import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

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

class StateComponent extends StatelessWidget {
  late final bool? value;
  final logger = Logger();

  StateComponent(this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    Color colour = Colors.orangeAccent;
    if (value != null && value == true) {
      colour = Colors.green;
    } else if (value != null && value == false) {
      colour = Colors.red;
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

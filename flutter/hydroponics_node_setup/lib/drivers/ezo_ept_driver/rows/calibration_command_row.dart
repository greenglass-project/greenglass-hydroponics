import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hydroponics_node_setup/components/active_button_component.dart';
import 'package:hydroponics_node_setup/components/disable_controller.dart';

class CalibrationCommandRow extends StatelessWidget {
  final String text;
  final String label;
  final Function(DisableController) onClick;

  CalibrationCommandRow({
    required this.text,
    required this.label,
    required this.onClick
  });

  @override
  Widget build(BuildContext context) {
     return Row(children: [
       Padding(
         padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
         child: Text(text, style: Theme
             .of(context)
             .textTheme
             .titleMedium),
       ),
       Spacer(),
       Padding(
           padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
           child: ActiveButtonComponent(
             label: label,
             onClick: onClick
           )
       ),
     ]);
   }
}
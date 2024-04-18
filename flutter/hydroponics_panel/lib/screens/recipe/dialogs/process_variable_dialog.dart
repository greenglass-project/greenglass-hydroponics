import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/datamodels/recipes/mutable_setpoint_model.dart';
import 'package:hydroponics_panel/screens/recipe/dialogs/dialog_mixin.dart';
import 'package:hydroponics_panel/screens/recipe/dialogs/keyboard/numeric_input.dart';

class ProcessVariableDialog extends StatefulWidget {
  final MutableSetpointModel value;
  final double maxValue;
  final double minValue;
  final double defaultValue;
  final String units;
  final int decimalPlaces;

  const ProcessVariableDialog({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.defaultValue,
    required this.units,
    required this.decimalPlaces,
    super.key
  });

  @override
  State<StatefulWidget> createState() => _ProcessVariableDialogState();
}

class _ProcessVariableDialogState extends State<ProcessVariableDialog> with DialogMixin{

 // late double value;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: Padding( padding : const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: _input(context) //_everySelection()
          ))
    ]);
  }

  Widget _input(BuildContext context) {
    return Row(children: [
      const SizedBox(width: 20,),
      //const Icon(Icons.speed,color: Colors.white54, size: 40,),
      displayOnlyField(context, "Setpoint"),
      changeableDoubleField(context, widget.value.setPoint,
              () => Get.dialog(NumericInput(
                  value: widget.value.setPoint,
                  minValue: widget.minValue,
                  maxValue: widget.maxValue,
                  units: widget.units,
                  decimalPlaces: widget.decimalPlaces)).then((r) {
                    if(r != null) {
                      setState(() => widget.value.setPoint = r);
                    }
                  })
      ),
      displayOnlyField(context, widget.units),

    ]);
  }
}

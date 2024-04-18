import 'package:flutter/material.dart';
import 'package:hydroponics_node_setup/components/active_button_component.dart';
import 'package:hydroponics_node_setup/components/disable_controller.dart';

class CalibrationInputRow extends StatefulWidget {
  final String text;
  final String label;
  final Function(DisableController, double) onClick;

  CalibrationInputRow(
      {required this.text, required this.label, required this.onClick});

  @override
  State<StatefulWidget> createState() => _CalibrationInputRowState();
}

class _CalibrationInputRowState extends State<CalibrationInputRow> {
  MaterialStatesController buttonStatesController = MaterialStatesController();
  MaterialStatesController inputStatesController = MaterialStatesController();
  final formFieldKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Row(children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child:
            Text(widget.text, style: Theme.of(context).textTheme.titleMedium),
      ),
      Spacer(),
      SizedBox(
          width: 189,
          child: TextFormField(
            key: formFieldKey,
            statesController: inputStatesController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter a value';
              else if (double.tryParse(value) == null)
                return 'Please enter a valid number';
              return null;
            },
          )),
      Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: ActiveButtonComponent(
            label: widget.label,
            onClick: (s) {
              if (formFieldKey.currentState != null &&
                  formFieldKey.currentState!.validate())
                widget.onClick(
                    s, double.parse(formFieldKey.currentState!.value));
            },
          )),
    ]));
  }
}

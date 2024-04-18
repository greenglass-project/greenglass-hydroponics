import 'package:flutter/material.dart';
import 'package:hydroponics_node_setup/components/disable_controller.dart';

import '../components/active_button_component.dart';
import '../components/state_component.dart';

mixin DriverComponentMixin {

  Row headerRow(BuildContext context, String text) {
    return Row(children: [
      Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Text(text, style: Theme
              .of(context)
              .textTheme
              .titleLarge,
        ),
      ),
      )
    ]);
  }

  Row textRow(BuildContext context, String label, String value) {
    return Row(children: [
      Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
          child: Text(label, style: Theme
              .of(context)
              .textTheme
              .titleMedium)
      ),
      Spacer(),
      Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
          child: Text(value, style: Theme
              .of(context)
              .textTheme
              .bodyMedium)

      ),
    ]);
  }

  Row stateRow(BuildContext context, String label, bool state) {
    return Row(children: [
      Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
          child: Text(label, style: Theme
              .of(context)
              .textTheme
              .titleMedium)
      ),
      Spacer(),
      Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
          child: StateComponent(state, key: Key(state.toString()))
      ),
    ]);
  }

  Row commandRow(BuildContext context, String text, String label, Function(DisableController) onClick) {
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

  Widget calibrationDialog(BuildContext context, {required Widget child}) {
    return Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: child);
  }
}
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'disable_controller.dart';

class ActiveButtonComponent extends StatefulWidget {
  final String label;
  final Function(DisableController) onClick;

  ActiveButtonComponent({
    required this.label,
    required this.onClick
  });

  @override
  State<StatefulWidget> createState() => _ActiveButtonComponentState();
}

class _ActiveButtonComponentState extends State<ActiveButtonComponent> {
  MaterialStatesController statesController = MaterialStatesController();
  late DisableController disableController;

  final logger = Logger();

  @override
  void initState() {
    disableController = DisableController(
        doEnable: () => setState(() {
          logger.d("ENABLE BUTTON");
          statesController.update(MaterialState.disabled, false);
        }),
        doDisable: () => setState(() {
          logger.d("DISABLE BUTTON");
          statesController.update(MaterialState.disabled, true);
        }),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      statesController: statesController,
      onPressed: () => widget.onClick(disableController),
      child: Text(widget.label),
    );
  }
}

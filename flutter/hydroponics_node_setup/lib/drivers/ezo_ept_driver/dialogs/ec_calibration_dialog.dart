import 'package:flutter/material.dart';
import 'package:hydroponics_node_setup/drivers/ezo_ept_driver/dialogs/calibration_mixin.dart';
import 'package:hydroponics_node_setup/drivers/ezo_ept_driver/rows/calibration_command_row.dart';
import 'package:hydroponics_node_setup/drivers/ezo_ept_driver//rows/calibration_input_row.dart';

class EcCalibrationDialog extends StatefulWidget {
  final String driverName;
  EcCalibrationDialog(this.driverName);

  @override
  State<StatefulWidget> createState() => _EcCalibrationDialogState();
}

class _EcCalibrationDialogState extends State<EcCalibrationDialog> with CalibrationMixin {

  @override
  void initState() {
    driverName = widget.driverName;
    sensorName = "EC";
    valueColor = Colors.green;
    completedState = 2;
    super.initState();
  }
  List<Widget> calibrationRows(BuildContext context) {
    return [
      CalibrationCommandRow(
        text: "Dry",
        label: "Calibrate",
        onClick: (s) => calibration(
            CalibrationRequest(command: CalibrationCommand.DRY),
            disableController: s),
      ),
      CalibrationInputRow(
        text: "Low",
        label: "Calibrate",
        onClick: (s, v) => calibration(
            CalibrationRequest(command: CalibrationCommand.LOW, value: v),
            disableController: s),
      ),
      CalibrationInputRow(
        text: "High",
        label: "Calibrate",
        onClick: (s, v) => calibration(
            CalibrationRequest(command: CalibrationCommand.HIGH, value: v),
            disableController: s),
      )
    ];
  }
}
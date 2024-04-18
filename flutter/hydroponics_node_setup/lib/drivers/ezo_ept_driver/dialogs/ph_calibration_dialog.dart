import 'package:flutter/material.dart';
import 'package:hydroponics_node_setup/drivers/ezo_ept_driver/dialogs/calibration_mixin.dart';

import '../rows/calibration_input_row.dart';

class PhCalibrationDialog extends StatefulWidget {
  final String driverName;
  PhCalibrationDialog(this.driverName);

  @override
  State<StatefulWidget> createState() => _PhCalibrationDialogState();
}

class _PhCalibrationDialogState extends State<PhCalibrationDialog> with CalibrationMixin {

  @override
  void initState() {
    driverName = widget.driverName;
    sensorName = "pH";
    valueColor = Colors.red;
    completedState = 2;
    super.initState();
  }

  @override
  List<Widget> calibrationRows(BuildContext context) {
      return [
        CalibrationInputRow(
          text: "Low",
          label: "Calibrate",
          onClick: (s, v) => calibration(
              CalibrationRequest(command: CalibrationCommand.LOW, value: v),
              disableController: s),
        ),
        CalibrationInputRow(
          text: "Mid",
          label: "Calibrate",
          onClick: (s, v) => calibration(
              CalibrationRequest(command: CalibrationCommand.MID, value: v),
              disableController: s),
        ),
        CalibrationInputRow(
            text: "High",
            label: "Calibrate",
            onClick: (s, v) => calibration(
                CalibrationRequest(command: CalibrationCommand.HIGH, value: v),
                disableController: s))
      ];
    }
  }


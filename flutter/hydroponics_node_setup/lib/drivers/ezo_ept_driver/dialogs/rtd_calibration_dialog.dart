import 'package:flutter/material.dart';

import '../rows/calibration_input_row.dart';
import 'calibration_mixin.dart';

class RtdCalibrationDialog extends StatefulWidget {
  final String driverName;
  RtdCalibrationDialog(this.driverName);

  @override
  State<StatefulWidget> createState() => _RtdCalibrationDialogState();
}

class _RtdCalibrationDialogState extends State<RtdCalibrationDialog> with CalibrationMixin {

  @override
  void initState() {
    driverName = widget.driverName;
    sensorName = "RTD";
    valueColor = Colors.white;
    completedState = 1;
    super.initState();
  }


  List<Widget> calibrationRows(BuildContext context) {
    return [
      CalibrationInputRow(
        text: "Temp",
        label: "Calibrate",
        onClick: (d, v) =>
            calibration(
                CalibrationRequest(command: CalibrationCommand.TEMP, value: v),
                disableController: d
            ),
      ),
    ];
  }

}
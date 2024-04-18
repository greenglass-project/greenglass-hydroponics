import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydroponics_node_setup/components/disable_controller.dart';
import 'package:hydroponics_node_setup/drivers/ezo_ept_driver/rows/calibration_command_row.dart';
import 'package:hydroponics_node_setup/drivers/ezo_ept_driver/rows/calibration_status_row.dart';
import 'package:hydroponics_node_setup/drivers/ezo_ept_driver/rows/command_row.dart';
import 'package:hydroponics_node_setup/drivers/ezo_ept_driver/rows/text_row.dart';
import 'package:hydroponics_node_setup/webservice/data_values.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_node_setup/components/streamed_value_component.dart';
import 'package:hydroponics_node_setup/webservice/web_service.dart';

class CalibrationCommand {
  static String CLEAR = "clear";
  static String STATE = "state";
  static String DRY = "dry";
  static String LOW = "low";
  static String MID = "mid";
  static String HIGH = "high";
  static String TEMP = "temp";
}

class CalibrationRequest {
  final String command;
  final double? value;

  CalibrationRequest({required this.command, this.value = 0.0});

  Map<String, dynamic> toJson() => {"command": command, "value": value};
}

mixin CalibrationMixin<T extends StatefulWidget> on State<T> {
  late String driverName;
  late String sensorName;
  late Color valueColor;
  late int completedState;

  double width = 500;
  double height = 800;

  WebService ws = Get.find();
  final logger = Logger();

  StreamController<int> calibrationState = StreamController<int>.broadcast();

  @override
  void initState() {
    calibration(CalibrationRequest(command: CalibrationCommand.STATE));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: height,
        child: Column(children: [
          Expanded(
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3.0)),
                        border: Border.all(color: Colors.white54),
                      ),
                      child: Column(children: [
                        SizedBox(
                          height: 20,
                        ),
                        Row(children: [
                          Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 20),
                                child: Text(sensorName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge),
                              )),
                          Expanded(
                              flex: 2,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: StreamedValueComponent(
                                    path:
                                        "/driver/${driverName}/${sensorName.toLowerCase()}/value",
                                    colour: valueColor,
                                    fontSize: 56,
                                  ))),
                        ]),
                        SizedBox(
                          height: 30,
                        ),

                        TextRow("Calibration"),
                        CalibrationStatusRow(
                            stateStream: calibrationState.stream,
                            completedState: completedState),
                        ...calibrationRows(context),
                        Spacer(),
                        CalibrationCommandRow(
                            text: "Clear calibration",
                            label: "Clear",
                            onClick: (d) => calibration(
                                CalibrationRequest(
                                    command: CalibrationCommand.CLEAR),
                                disableController: d)),
                        CommandRow(
                            text: "Factory reset",
                            label: "Reset",
                            onClick: (d) {}),
                        //(d) => _factoryReset(d))
                        SizedBox(
                          height: 20,
                        ),
                        CommandRow(
                            text: "",
                            label: "Done",
                            onClick: (d) => Navigator.of(context).pop()),
                        //(d) => _factoryReset(d))
                      ]))))
        ]));
  }

  void _factoryReset(DisableController disableController) {
    disableController.disable();
    String path = "/driver/$driverName/${sensorName.toLowerCase()}/reset";
    ws.post(path, {}).then((resp) {
      disableController.enable();
      if (resp != null) {
        calibrationState.add(IntValue.fromJson(jsonDecode(resp)).value);
      }
    });
  }

  void calibration(CalibrationRequest request,
      {DisableController? disableController = null}) async {
    disableController?.disable();
    String path = "/driver/$driverName/${sensorName.toLowerCase()}/calibrate";
    ws.post(path, request.toJson()).then((resp) {
      disableController?.enable();
      if (resp != null) {
        calibrationState.add(IntValue.fromJson(jsonDecode(resp)).value);
      }
    });
  }

  Widget animated(Widget child) {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: child);
  }

  List<Widget> calibrationRows(BuildContext context);
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydroponics_node_setup/components/disable_controller.dart';

import 'package:hydroponics_node_setup/components/active_button_component.dart';
import 'package:hydroponics_node_setup/components/streamed_value_component.dart';
import 'package:hydroponics_node_setup/drivers/driver_component_mixin.dart';
import 'package:hydroponics_node_setup/drivers/ezo_ept_driver/dialogs/settings_dialog.dart';

import '../../webservice/web_service.dart';
import 'dialogs/ec_calibration_dialog.dart';
import 'dialogs/ph_calibration_dialog.dart';
import 'dialogs/rtd_calibration_dialog.dart';
import 'models/settings.dart';

class EzoEptDriverComponent extends StatefulWidget {
  final String name;

  EzoEptDriverComponent(this.name);

  @override
  State<StatefulWidget> createState() => _EzoEptDriverComponentState();
}

class _EzoEptDriverComponentState extends State<EzoEptDriverComponent>
    with DriverComponentMixin {


  WebService ws = Get.find();
  bool initialised = false;
  Settings? settings;
  int? tickInterval;
  int? window;

  @override
  void initState() {
    super.initState();
    _getSettings();
  }

  void _getSettings() async {
    ws.get("/driver/ept-sensors/settings").then((resp) {
      if (resp != null) {
        setState(() {
          settings = Settings.fromJson(jsonDecode(resp));
          initialised = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(!initialised)
      return
          Container();
      else
    return Column(children: [
      headerRow(context, widget.name),
      _sensorRow(
          context,
          "pH",
          Colors.red,
          (d) => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return calibrationDialog(
                    context,
                    child: PhCalibrationDialog(widget.name),
                  );
                },
              )),
      _sensorRow(
          context,
          "EC",
          Colors.green,
          (d) => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return calibrationDialog(
                    context,
                    child: EcCalibrationDialog(widget.name),
                  );
                },
              )),
      _sensorRow(
          context,
          "RTD",
          Colors.white,
          (d) => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return calibrationDialog(
                    context,
                    child: RtdCalibrationDialog(widget.name),
                  );
                },
              )),
      Spacer(),
      commandRow(context, "Settings", "Edit", (b) => showDialog(
          context: context,
          builder: (BuildContext context) {
            return calibrationDialog(
                context,
                child: SettingsDialog(),
              );
          },
      ).then((value) {
        if(value != null)
          setState(()=> settings = value);
      })),
      textRow(context, "Tick interval", settings!.tickInterval.toString()),
      SizedBox(height: 8),
      textRow(context, "Window size", settings!.window.toString()),
      SizedBox(height: 50)
    ]);
  }

  Row _sensorRow(BuildContext context, String displayName, Color colour,
      Function(DisableController) onClick) {
    String sensor = displayName.toLowerCase();
    return Row(children: [
      Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Text(displayName,
                style: Theme.of(context).textTheme.titleMedium),
          )),
      Expanded(
          flex: 4,
          child: ActiveButtonComponent(
              label: "Calibrate", onClick: (d) => onClick(d))),
      Expanded(
          flex: 6,
          child: Align(
              alignment: Alignment.centerRight,
              child: StreamedValueComponent(
                path:
                    "/driver/${widget.name}/${displayName.toLowerCase()}/value",
                colour: colour,
                fontSize: 32,
              ))),
    ]);
  }
}

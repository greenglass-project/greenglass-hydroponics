import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydroponics_node_setup/drivers/dosing_pump_driver/volume_dialog.dart';

import 'package:hydroponics_node_setup/drivers/driver_component_mixin.dart';
import 'package:hydroponics_node_setup/webservice/data_values.dart';
import 'package:hydroponics_node_setup/webservice/web_service.dart';

class DosingPumpDriverComponent extends StatefulWidget {
  final String name;
  DosingPumpDriverComponent(this.name);

  @override
  State<StatefulWidget> createState() => _DosingPumpDriverComponent();
}

class _DosingPumpDriverComponent extends State<DosingPumpDriverComponent> with DriverComponentMixin {
  double calibration = 0.0;
  bool state = false;
  bool initialised = false;
  WebService ws = Get.find();

  @override
  void initState() {
    _getSysInfo();
    _listenForValue();
    super.initState();
  }

  void _getSysInfo() async {
    ws.get("/driver/${widget.name}/calibrate").then((resp) {
      if (resp != null) {
        setState(() {
          calibration = DoubleValue.fromJson(jsonDecode(resp)).value;
          initialised = true;
        });
      }
    });
  }

  void _listenForValue() async {
    ws.subscribe("/driver/${widget.name}/state").listen((v) {
      if (mounted)
        setState(() =>
        state = BoolValue
            .fromJson(jsonDecode(v))
            .value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(!initialised)
      return Container();
    else
      return Column(children: [
        headerRow(context, widget.name),
        SizedBox(height: 10),
        stateRow(context, "State", state),
        SizedBox(height: 10),

        commandRow(context, "Settings", "Edit", (b) => showDialog(
          context: context,
          builder: (BuildContext context) {
            return calibrationDialog(
              context,
              child: VolumeDialog(widget.name),
            );
          },
        ).then((value) {
          if(value != null)
            setState(()=> calibration = value);
        })),
        textRow(context, "Volume", "${calibration.toString()} ml/s"),

      ]);
  }
}
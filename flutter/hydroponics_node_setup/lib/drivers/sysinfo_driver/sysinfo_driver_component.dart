import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hydroponics_node_setup/drivers/driver_component_mixin.dart';
import 'package:hydroponics_node_setup/drivers/sysinfo_driver/sysinfo_model.dart';
import 'package:hydroponics_node_setup/webservice/web_service.dart';

class SysinfoDriverComponent extends StatefulWidget {
  final String name;
  SysinfoDriverComponent(this.name);

  @override
  State<StatefulWidget> createState() => _SysinfoDriverComponent();
}

class _SysinfoDriverComponent extends State<SysinfoDriverComponent> with DriverComponentMixin {
  SysinfoModel? info;
  bool initialised = false;
  WebService ws = Get.find();

  @override
  void initState() {
    _getSysInfo();
    super.initState();
  }

  void _getSysInfo() async {
    ws.get("/driver/${widget.name}/sysinfo").then((resp) {
      if (resp != null) {
        setState(() {
          info = SysinfoModel.fromJson(jsonDecode(resp));
          initialised = true;
        });
      }
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
        textRow(context, "Hardware make", info!.hardwareMake),
        SizedBox(height: 8),
        textRow(context, "Hardware model", info!.hardwareModel),
        SizedBox(height: 8),
        textRow(context, "OS", info!.os),
        SizedBox(height: 8),
        textRow(context, "OS version make", info!.osVersion),
        SizedBox(height: 8),
        //textRow(context, "IP address", info!.ipAddress),
        //SizedBox(height: 8),
        textRow(context, "Host", info!.host),

      ]);
  }
}
import 'package:flutter/material.dart';
//import 'dart:html' as html;

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hydroponics_node_setup/screens/grid_main_screen.dart';
import 'package:hydroponics_node_setup/screens/web_service_screen.dart';
import 'package:hydroponics_node_setup/webservice/web_service.dart';
import 'drivers/dosing_pump_driver/dosing_pump_driver_component.dart';
import 'drivers/ezo_ept_driver/ezo_ept_driver_component.dart';
import 'drivers/drivers_registry.dart';
import 'drivers/sysinfo_driver/sysinfo_driver_component.dart';

void main() {
  runApp(const NodeApp());
}

class NodeApp extends StatefulWidget {
  const NodeApp({super.key});

  @override
  State<StatefulWidget> createState() => _NodeAppState();
}

class _NodeAppState extends State<NodeApp> {
  String? hostname;

  @override
  Widget build(BuildContext context) {
    DriversRegistry registry = DriversRegistry();
    registry.register("sysinfo", (n) => SysinfoDriverComponent(n));
    registry.register("ezo_ept", (n) => EzoEptDriverComponent(n));
    registry.register("gpio_dosing_pump", (n) => DosingPumpDriverComponent(n));
    Get.put(registry);

    //WebService ws = WebService(
    //    hostName: html.window.location.hostname!, port: 8181, isSecure: false
    //);

   // Get.put(ws);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: WebServiceScreen() //GridMainScreen()
    );
  }
}



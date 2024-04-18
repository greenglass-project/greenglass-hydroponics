import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/microservices/microservice_service.dart';

import 'main_screen.dart';

void main() {
  runApp(const GreenglassApp());
}

class GreenglassApp extends StatelessWidget {
  const GreenglassApp({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(MicroserviceService());
    //Get.put(SystemModelsCache());
    //Get.put(PlantModelCache());

    return GetMaterialApp(
        title: 'Greenglass',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        home: const MainScreen()
    );
  }
}


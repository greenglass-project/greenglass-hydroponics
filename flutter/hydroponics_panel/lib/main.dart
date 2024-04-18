import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/caches/plant_model_cache.dart';
import 'package:hydroponics_panel/screens/entry_screen.dart';

import 'package:industrial_theme/theme/industrial_theme.dart';
import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:hydroponics_framework/caches/system_models_cache.dart';
import 'package:hydroponics_panel/screens/config/system_selection.dart';
import 'package:hydroponics_panel/screens/installation/installations_list_screen.dart';

void main() {
  runApp(const GreenglassIotIndustrial());
}

class GreenglassIotIndustrial extends StatelessWidget {
  const GreenglassIotIndustrial({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(MicroserviceService());
    Get.put(SystemModelsCache());
    Get.put(PlantModelCache());

    return GetMaterialApp(
        title: 'Greenglass IoT Industrial',
        debugShowCheckedModeBanner: false,
        theme: IndustrialTheme().theme(),
        home: EntryWidget()
    );
  }
}

class EntryWidget extends StatelessWidget {
  EntryWidget({super.key});
  final ms = MicroserviceService.ms;

  @override
  Widget build(BuildContext context) {
    return GetX<MicroserviceService>(
      builder: (ms) {
        if(ms.connected.value == true) {
          return const EntryScreen();
        } else {
          return const SystemSelection();
        }
      });
  }
}

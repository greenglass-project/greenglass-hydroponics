import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/microservices/microservice_service.dart';
import 'package:logger/logger.dart';

import 'config/master_config_dialog.dart';
import 'installation/installations_list_screen.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<StatefulWidget> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {

  final ms = MicroserviceService.ms;
  final logger = Logger();

  @override
  void initState() {
    super.initState();

    const topic = "findone.masterconfig";
    logger.d("Sending request to $topic");
    ms.requestNoParameters(topic,
          (r) => Get.to(() => InstallationsListScreen()),
          (c, m)  =>
            Get.dialog(const MasterConfigDialog()).then((_) =>  Get.to(() => InstallationsListScreen()))
    );
  }

  @override
  Widget build(BuildContext context) => Container();
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/datamodels/system/system_model.dart';
import 'package:hydroponics_framework/mixins/error/error_dialog_mixin.dart';
import 'package:hydroponics_panel/screens/recipe/phases/phase_list_provider.dart';

class ViewPhasesComponent extends StatefulWidget {
  final SystemModel system;
  final PhaseListProvider phases;

  const ViewPhasesComponent({
    required this.system,
    required this.phases,
    super.key
  });

  @override
  State<ViewPhasesComponent> createState() => _ViewPhasesComponentState();
}

class _ViewPhasesComponentState extends State<ViewPhasesComponent> {
  Color draggableItemColor = Colors.green;
  bool canDrag = false;

  late PhaseListProvider phases;
  @override
  void initState() {
    phases = widget.phases;
    phases.changeStream().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(25, 10, 10, 10),
            child:
                Text("Phases", style: Theme.of(context).textTheme.labelMedium)),
        const Spacer(),
      ]),
      Expanded(
          child: ListView(
        //padding: const EdgeInsets.only(left: 15, right: 15),
        children: <Widget>[
          for (int index = 0; index < phases.size(); index += 1)
            Padding(
                key: Key('$index'),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.greenAccent,
                          width: 1.0,
                          style: BorderStyle.solid),
                    ),
                    child: InkWell(
                        onTap: () => phases.select(index),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 10, 18),
                          child: Row(
                              //tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
                              children: [
                                Text(
                                  phases.modelAt(index).name,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                const Spacer(),
                              ]),
                        ))))
        ],
      ))
    ]);
  }
}

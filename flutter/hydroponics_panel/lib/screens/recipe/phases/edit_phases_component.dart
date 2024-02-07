import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hydroponics_framework/datamodels/system/system_model.dart';
import 'package:hydroponics_panel/screens/recipe/phases/phase_list_provider.dart';
import 'package:hydroponics_panel/screens/recipe/phases/phase_type_dialog.dart';

import '../screen_mode.dart';

class EditPhasesComponent extends StatefulWidget {
  final SystemModel system;
  final PhaseListProvider phases;

  const EditPhasesComponent(
      {required this.system,
      required this.phases,
      super.key});

  @override
  State<EditPhasesComponent> createState() => _EditPhasesComponentState();
}

class _EditPhasesComponentState extends State<EditPhasesComponent> {
  Color draggableItemColor = Colors.green;
  bool canDrag = false;
  late ScreenMode mode;
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

    Widget proxyDecorator(
        Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue = Curves.easeInOut.transform(animation.value);
          final double elevation = lerpDouble(0, 6, animValue)!;
          return Material(
            elevation: elevation,
            color: draggableItemColor,
            shadowColor: draggableItemColor,
            child: child,
          );
        },
        child: child,
      );
    }
    return Column(children: [
      Row(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(25, 10, 10, 10),
            child:
                Text("Phases", style: Theme.of(context).textTheme.labelMedium)),
        const Spacer(),
        Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: InkWell(
                onTap: () => setState(() => canDrag = !canDrag),
                child: const Icon(Icons.menu_sharp,
                    color: Colors.white, size: 48))),
        Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: InkWell(
                onTap: () =>
                    Get.dialog(PhaseTypeDialog(widget.system)).then((v) {
                      if (v != null) {
                        phases.addModel(v);
                      }
                    }),
                child:
                    const Icon(Icons.add_sharp, color: Colors.white, size: 48)))
        ]),
        Expanded(
          child: _list()
     )
    ]);
  }

  Widget _list() {
    if(canDrag) {
      Widget proxyDecorator(
          Widget child, int index, Animation<double> animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            final double animValue = Curves.easeInOut.transform(animation.value);
            final double elevation = lerpDouble(0, 6, animValue)!;
            return Material(
              elevation: elevation,
              color: draggableItemColor,
              shadowColor: draggableItemColor,
              child: child,
            );
          },
          child: child,
        );
      }
      return ReorderableListView(
        //padding: const EdgeInsets.only(left: 15, right: 15),
        proxyDecorator: proxyDecorator,
        buildDefaultDragHandles: false,
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
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                      child: Row(
                        //tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
                          children: [
                            Text(
                              phases.modelAt(index).name,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const Spacer(),
                            ReorderableDragStartListener(
                                index: index,
                                child: const Padding(
                                    padding:
                                    EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    child: Icon(Icons.menu_sharp,
                                        color: Colors.white)))
                          ]),
                    )))
        ],
        onReorder: (int oldIndex, int newIndex) {
          phases.reorder(oldIndex, newIndex);
        },
      );

    } else {
      return ListView(
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
      );
    }
  }
}

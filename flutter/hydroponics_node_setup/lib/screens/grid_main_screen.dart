// See https://api.flutter.dev/flutter/rendering/SliverGridLayout-class.html

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:hydroponics_node_setup/components/settings_component.dart';
import 'package:hydroponics_node_setup/components/sparkplug_state_component.dart';

import 'package:hydroponics_node_setup/datamodels/driver_info.dart';
import 'package:hydroponics_node_setup/drivers/drivers_registry.dart';
import 'package:hydroponics_node_setup/webservice/web_service.dart';

import 'package:hydroponics_node_setup/datamodels/settings_model.dart';

class GridMainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GridMainScreen();
}

class _GridMainScreen extends State<GridMainScreen> {
  List<DriverInfo> drivers = [];
  SettingsModel? settings;
  WebService ws = Get.find();
  DriversRegistry registry = Get.find();
  bool initialised = false;

  @override
  void initState() {
    super.initState();
    _getDrivers();
  }

  void _getDrivers() {
    ws.get("/drivers").then((resp) {
      if (resp != null) {
        setState(() => drivers =
            List<Map<String, dynamic>>.from(jsonDecode(resp!))
                .map((d) => DriverInfo.fromJson(d))
                .toList());
        initialised = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!initialised)
      return Container();
    else

      return Card(
          elevation: 8.0,
          color: Colors.black,
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(40, 20, 20, 0),
                  child: SizedBox(
                      width: 159,
                      child: Image(image: AssetImage('images/logo.png')))),
              SettingsComponent(),
              Spacer(),
              SparkplugStateComponent()
            ]),
            Expanded(
                child: GridView.builder(
                    padding: const EdgeInsets.all(12.0),
                    gridDelegate: CustomGridDelegate(dimension: 320.0),
                    itemCount: drivers.length,
                    itemBuilder: (c, i) => _itemBuilder(c, i)))
          ]));
  }

  Widget _itemBuilder(BuildContext context, int index) {
    DriverInfo di = drivers[index];
    return GridTile(
      child: Container(
          margin: const EdgeInsets.all(12.0),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          child: registry.build(di.type)(di.name)),
    );
  }
}

class CustomGridDelegate extends SliverGridDelegate {
  CustomGridDelegate({required this.dimension});

  final double dimension;

  //final double height;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    // Determine how many squares we can fit per row.
    int count = constraints.crossAxisExtent ~/ dimension;
    if (count < 1) {
      count = 1; // Always fit at least one regardless.
    }
    final double squareDimension = constraints.crossAxisExtent / count;
    return CustomGridLayout(
      crossAxisCount: count,
      fullRowPeriod: 3,
      // Number of rows per block (one of which is the full row).
      dimension: squareDimension,
    );
  }

  @override
  bool shouldRelayout(CustomGridDelegate oldDelegate) {
    return dimension != oldDelegate.dimension;
  }
}

class CustomGridLayout extends SliverGridLayout {
  const CustomGridLayout({
    required this.crossAxisCount,
    required this.dimension,
    required this.fullRowPeriod,
  })  : assert(crossAxisCount > 0),
        assert(fullRowPeriod > 1),
        loopLength = crossAxisCount * (fullRowPeriod - 1) + 1,
        loopHeight = fullRowPeriod * dimension;

  final int crossAxisCount;
  final double dimension;
  final int fullRowPeriod;

  // Computed values.
  final int loopLength;
  final double loopHeight;

  @override
  double computeMaxScrollOffset(int childCount) {
    if (childCount == 0 || dimension == 0) {
      return 0;
    }
    return (childCount ~/ loopLength) * loopHeight +
        ((childCount % loopLength) ~/ crossAxisCount) * dimension;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final int loop = index ~/ loopLength;
    final int loopIndex = index % loopLength;
    if (loopIndex == loopLength - 1) {
      // Full width case.
      return SliverGridGeometry(
        scrollOffset: (loop + 1) * loopHeight - dimension, // "y"
        crossAxisOffset: 0, // "x"
        mainAxisExtent: dimension, // "height"
        crossAxisExtent: crossAxisCount * dimension, // "width"
      );
    }
    // Square case.
    final int rowIndex = loopIndex ~/ crossAxisCount;
    final int columnIndex = loopIndex % crossAxisCount;
    return SliverGridGeometry(
      scrollOffset: (loop * loopHeight) + (rowIndex * dimension), // "y"
      crossAxisOffset: columnIndex * dimension, // "x"
      mainAxisExtent: dimension, // "height"
      crossAxisExtent: dimension, // "width"
    );
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    final int rows = scrollOffset ~/ dimension;
    final int loops = rows ~/ fullRowPeriod;
    final int extra = rows % fullRowPeriod;
    return loops * loopLength + extra * crossAxisCount;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    final int rows = scrollOffset ~/ dimension;
    final int loops = rows ~/ fullRowPeriod;
    final int extra = rows % fullRowPeriod;
    final int count = loops * loopLength + extra * crossAxisCount;
    if (extra == fullRowPeriod - 1) {
      return count;
    }
    return count + crossAxisCount - 1;
  }
}

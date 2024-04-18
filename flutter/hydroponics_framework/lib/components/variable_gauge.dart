import 'package:flutter/material.dart';
import 'package:hydroponics_framework/datamodels/recipes/setpoint_model.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'package:hydroponics_framework/datamodels/system/process_variable_model.dart';

class VariableGauge extends StatefulWidget {
  final String installationId ;
  final ProcessVariableModel processVariable;
  final SetpointModel setpoint;
  final bool state;

  const VariableGauge({
    required this.installationId,
    required this.processVariable,
    required this.setpoint,
    required this.state,
    super.key
  });

  @override
  State<StatefulWidget> createState() => _VariableGaugeState();
}

class _VariableGaugeState extends State<VariableGauge> {

  double? setPoint;
  double? value;
  double? gaugeStart;
  double? gaugeEnd;
  bool state = false;

  var logger = Logger();

  @override
  void initState() {
   //widget.controlStream.listen((state) => this.state = state );
    state = widget.state;
    super.initState();
  }

  GaugeTextStyle axisLabelStyle() =>
      state? const GaugeTextStyle(color: Colors.white) : const GaugeTextStyle(color: Colors.white60);
  MajorTickStyle majorTickStyle() =>
    state? const MajorTickStyle(color: Colors.white60) : const MajorTickStyle(color: Colors.white54);
  MinorTickStyle minorTickStyle() =>
    state? const MinorTickStyle(color: Colors.white60) : const MinorTickStyle(color: Colors.white54);
  AxisLineStyle axisLineStyle() =>
    state? const AxisLineStyle(color: Colors.white60) : const AxisLineStyle(color: Colors.white54);

  TextStyle textTheme() {
    return state? Theme.of(context).textTheme.titleSmall! :
      Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.white24);
  }

  @override
  Widget build(BuildContext context) {
      return SfRadialGauge(
          backgroundColor: Colors.transparent,
          enableLoadingAnimation: true,
          animationDuration: 2,
          title: GaugeTitle(
              text: widget.processVariable.name,
              textStyle: textTheme(),
              alignment: GaugeAlignment.center
          ),
          axes: [
            RadialAxis(
                startAngle: -225,
                endAngle: 45,
                minimum: widget.processVariable.defaultt -
                    2 * widget.processVariable.tolerance,
                maximum: widget.processVariable.defaultt +
                    2 * widget.processVariable.tolerance,
                showLastLabel: true,
                //maximumLabels: 1,
                //interval: 2,
                axisLabelStyle: axisLabelStyle(),
                majorTickStyle: majorTickStyle(),
                minorTickStyle: minorTickStyle(),
                axisLineStyle: axisLineStyle(),
                annotations: [],
                ranges: _generateRanges(),
                pointers: _pointer()
                )
          ]);
    }


  List<NeedlePointer> _pointer() {
    List<NeedlePointer> pointers = [];
    if(state) {
      pointers.add(NeedlePointer(
          value: widget.processVariable.defaultt,
          needleColor: state ? Colors.white : Colors.white24
      ));
    }
    return pointers;
  }

  List<GaugeRange> _generateRanges() {
    List<GaugeRange> ranges = [];
    ranges.add(GaugeRange(
        startValue: widget.processVariable.defaultt - 2*widget.processVariable.tolerance,
        endValue: widget.processVariable.defaultt - widget.processVariable.tolerance,
        color: state?Colors.orangeAccent : Colors.white12
    ));
    ranges.add(GaugeRange(
        startValue: widget.processVariable.defaultt - widget.processVariable.tolerance,
        endValue: widget.processVariable.defaultt + widget.processVariable.tolerance,
        color: state?Colors.greenAccent : Colors.white10
    ));
    ranges.add(GaugeRange(
        startValue: widget.processVariable.defaultt + widget.processVariable.tolerance,
        endValue: widget.processVariable.defaultt + 2*widget.processVariable.tolerance,
        color: state?Colors.orangeAccent : Colors.white12
    ));
    return ranges;
  }
}


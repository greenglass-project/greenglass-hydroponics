import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hydroponics_framework/components/binary_component.dart';
import 'package:hydroponics_framework/datamodels/nodes/metric.dart';
import 'package:hydroponics_framework/datamodels/nodes/metric_data_type.dart';
import 'package:hydroponics_framework/datamodels/nodes/metric_direction.dart';
import 'package:hydroponics_framework/datamodels/nodes/metric_value.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

import 'modify/modify_boolean_value_component.dart';
import 'modify/modify_double_value_component.dart';
import 'modify/modify_int_value_component.dart';
import 'modify/modify_long_value_component.dart';

class EditableMetricValueComponent extends StatefulWidget {
  final String installationId;
  final String nodeId;
  final Metric metric;
  final BehaviorSubject<MetricValue> valueStream;

  const EditableMetricValueComponent(this.installationId, this.nodeId, this.metric, this.valueStream,
      {super.key});

  @override
  State<StatefulWidget> createState() => _EditableMetricValueComponentState();
}

class _EditableMetricValueComponentState
    extends State<EditableMetricValueComponent> {

  MetricValue? value;
  var logger = Logger();

  @override
  void initState() {
    widget.valueStream.listen((m) {
      if (mounted) {
        logger.d("STREAM ${m.value}");
        setState(() => value = m);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Row(children: _components());

  List<Widget> _components() {
    List<Widget> c = [];
    if (value != null) {
      switch (value!.type) {
        case MetricDataType.int8 :
        case MetricDataType.int16 :
        case MetricDataType.int32 :
        case MetricDataType.int64 :
        case MetricDataType.uInt8 :
        case MetricDataType.uInt16 :
        case MetricDataType.uInt32 :
        case MetricDataType.uInt64 :
          if (widget.metric.direction == MetricDirection.write) {
            c.add(_change());
          }
          c.add(const Spacer());
          c.add(Text((value!.value as int).toString(), style: Theme
              .of(context)
              .textTheme
              .labelSmall));
          break;

        case MetricDataType.float :
        case MetricDataType.double :
          if (widget.metric.direction == MetricDirection.write) {
            c.add(_change());
          }
          c.add(const Spacer());
          c.add(Text((value!.value as double).toString(), style: Theme
              .of(context)
              .textTheme
              .labelSmall));
          break;

        case MetricDataType.boolean :
          if (widget.metric.direction == MetricDirection.write) {
            c.add(_change());
          }
          c.add(const Spacer());
          c.add(BinaryComponent(value!.value as bool));
          break;

        case MetricDataType.dateTime :
          c.add(const Spacer());
          c.add(Text((value!.value as DateTime).toIso8601String(), style: Theme
              .of(context)
              .textTheme
              .labelSmall));
          break;

        case MetricDataType.string :
        case MetricDataType.text :
          c.add(const Spacer());
          c.add(Text(value!.value as String, style: Theme
              .of(context)
              .textTheme
              .labelSmall));
          break;

        default:
          logger.d("METRIC DATA TYPE = ${value!.type}");
          c.add(const Spacer());
          c.add(Text("Unknown", style: Theme
              .of(context)
              .textTheme
              .labelSmall!
              .copyWith(color: Colors.deepOrangeAccent)));
      }
    } else {
      logger.d("VALUE IS NULL");
      c.add(const Spacer());
      c.add(Text("Unknown", style: Theme
          .of(context)
          .textTheme
          .labelSmall!
          .copyWith(color: Colors.deepOrangeAccent)));
    }
    return c;
  }

  Widget _change() {
    return InkWell(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
            child :
            Center(
                child:
                Text("Change", style: Theme.of(context)
                        .textTheme
                        .labelSmall
                )
            )
        ),
        onTap: () {
          switch (widget.metric.type) {
            case MetricDataType.double :
              Get.dialog(
                  ModifyDoubleValueComponent(
                      installationId: widget.installationId,
                      nodeId: widget.nodeId,
                      metric: widget.metric,
                      value: value!
                  )
              );
              break;

            case MetricDataType.int32 :
              Get.dialog(
                  ModifyIntValueComponent(
                      installationId: widget.installationId,
                      nodeId: widget.nodeId,
                      metric: widget.metric,
                      value: value!
                  )
              );
              break;
            case MetricDataType.int64 :
              Get.dialog(
                  ModifyLongValueComponent(
                      installationId: widget.installationId,
                      nodeId: widget.nodeId,
                      metric: widget.metric,
                      value: value!
                  )
              );
              break;

              case MetricDataType.boolean :
              Get.dialog(
                  ModifyBooleanValueComponent(
                      installationId: widget.installationId,
                      nodeId: widget.nodeId,
                      metric: widget.metric,
                      value: value!
                  )
              );
              break;
            default:
          }
        });
  }
}
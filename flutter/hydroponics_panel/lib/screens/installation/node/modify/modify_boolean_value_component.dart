import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import 'package:hydroponics_framework/datamodels/nodes/metric.dart';
import 'package:hydroponics_framework/datamodels/nodes/metric_data_type.dart';
import 'package:hydroponics_framework/datamodels/nodes/metric_value.dart';
import 'package:hydroponics_framework/datamodels/nodes/node_metric_name_value.dart';

import 'modify_metric_value_mixin.dart';

class ModifyBooleanValueComponent extends StatefulWidget {
  final String installationId;
  final String nodeId;
  final Metric metric;
  final MetricValue value;

  const ModifyBooleanValueComponent({
    required this.installationId,
    required this.nodeId,
    required this.metric,
    required this.value,
    super.key
  });

  @override
  State<StatefulWidget> createState() => _ModifyBooleanValueComponentState();
}

class _ModifyBooleanValueComponentState
    extends State<ModifyBooleanValueComponent> with ModifyMetricValueMixin{

  @override
  void initState() {
    formKey = GlobalKey<FormBuilderState>();
    installationId = widget.installationId;
    nodeId = widget.nodeId;
    super.initState();
  }

  @override
  Widget modifyForm() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(50, 50, 50, 50),
        child:
        FormBuilderCheckbox(
            autofocus: true,
            name: 'boolean',
            initialValue: widget.value.value as bool,
            title: Text("", style: Theme.of(context).textTheme.titleSmall),
            controlAffinity: ListTileControlAffinity.trailing,
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (v) {},
            onSaved: (v) => newValue = v
        ),
    );
  }

  @override
  NodeMetricNameValue metric() {
    return NodeMetricNameValue(
        nodeId : widget.nodeId,
        metricName: widget.metric.metricName,
        value:  MetricValue(
            type: MetricDataType.boolean,
            value: newValue as bool,
            timestamp: DateTime.now()
          )
    );
  }
}

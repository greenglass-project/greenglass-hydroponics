import 'package:logger/logger.dart';

import '../implementation/implementation_node_model.dart';
import '../nodes/metric.dart';

class InstallationNodeModel {
  final String nodeId;
  final String implName;
  final String nodeType;
  final String nodeName;
  final String nodeDescription;
  final String nodeImage;
  final List<Metric> metrics;

  InstallationNodeModel(this.nodeId, this.implName, this.nodeType,
      this.nodeName, this.nodeDescription, this.nodeImage, this.metrics);

  static InstallationNodeModel fromJson(Map<String, dynamic> json) {
    return InstallationNodeModel(
        json["nodeId"],
        json["implName"],
        json["nodeType"],
        json["nodeName"],
        json["nodeDescription"],
        json["nodeImage"],
        List.from(json["metrics"]).map((m) => Metric.fromJson(m)).toList());
  }
}

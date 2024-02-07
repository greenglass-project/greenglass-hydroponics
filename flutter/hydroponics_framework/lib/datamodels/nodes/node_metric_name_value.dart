import '../json_model.dart';
import 'metric_value.dart';

class NodeMetricNameValue extends JsonModel {
  final String nodeId;
  final String metricName;
  final MetricValue value;

  NodeMetricNameValue({
    required this.nodeId,
    required this.metricName,
    required this.value
  }) : super();

  static NodeMetricNameValue fromJson(Map<String, dynamic> json) {
    return NodeMetricNameValue(
        nodeId :json["nodeId"],
        metricName : json["metricName"],
        value : MetricValue.fromJson(json["value"])
    );
  }

  @override
  Map<String, Object> toJson() {
    return {
      "nodeId" : nodeId,
      "metricName" : metricName,
      "value" : value.toMap()
    };
  }
}
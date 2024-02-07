import 'metric_data_type.dart';
import 'metric_direction.dart';

class Metric {
  final String metricName;
  final MetricDataType type;
  final MetricDirection direction;
  final String description;

  Metric(this.metricName, this.type, this.direction, this.description);

  static Metric fromJson(Map<String, dynamic> json) {
    return Metric(
        json["metricName"],
        MetricDataType.getByName(json["type"])!,
        MetricDirection.getByName(json["direction"])!,
        json["description"]
    );
  }
}
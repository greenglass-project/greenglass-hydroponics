import 'metric.dart';

class PhysicalEonNode {
  final String nodeId;
  final String type;
  final String name;
  final String description;
  final String image;
  final List<Metric> metrics;

  PhysicalEonNode(this.nodeId, this.type, this.name, this.description, this.image, this.metrics);

  static PhysicalEonNode fromJson(Map<String, dynamic> json) {
    return PhysicalEonNode(
        json["nodeId"],
        json["type"],
        json["name"],
        json["description"],
        json["image"],
        List<Map<String, dynamic>>.from(json["metrics"])
        .map((m) => Metric.fromJson(m)).toList()
    );
  }
}

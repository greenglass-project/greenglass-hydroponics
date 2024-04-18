import 'metric.dart';

class NodeType {
  late String type;
  late String name;
  late String description;
  late String image;
  late List<Metric> metrics;

  NodeType(this.type, this.name, this.description, this.image, this.metrics);

  NodeType.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    name = json["name"];
    description = json["description"];
    image = json["image"];
    metrics = List<Map<String, dynamic>>.from(json["metrics"])
        .map((m) => Metric.fromJson(m)).toList();
  }
}

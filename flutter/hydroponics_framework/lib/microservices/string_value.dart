import 'package:hydroponics_framework/datamodels/json_model.dart';

class StringValue implements JsonModel {
  late String value;

  StringValue(this.value);

  StringValue.fromJson(Map<String, dynamic> json) {
    value = json["value"];
  }

  @override
  Map<String, dynamic> toJson() {
    return {"value": value};
  }
}
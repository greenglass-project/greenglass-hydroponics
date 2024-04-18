import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../datamodels/metric_value.dart';

class CalibrationRequest {
  final String command;
  final double value;

  CalibrationRequest({
    required this.command,
    this.value = 0.0
  });

  Map<String, dynamic> toJson() => {
    "command" : command,
    "value" : value
  };
}

class CalibrationController {
  final String url;
  final int initialState;
  late final BehaviorSubject calibrationState;

  CalibrationController(this.url, this.initialState) {
    calibrationState = BehaviorSubject<int>();
    calibrationState.add(initialState);
  }

  WebSocketChannel? channel;

  void connect() async {
    final wsUrl = Uri.parse(url);
    final channel = WebSocketChannel.connect(wsUrl);
    await channel.ready;
    channel.stream.listen((resp) {
      var m = MetricValue.fromJson(jsonDecode(resp));
      if(m.value is int) {
        calibrationState.add(m.value);
      }
    });
  }

  void calibrate(CalibrationRequest request) =>
      channel?.sink.add(jsonEncode(request.toJson()));
}
import 'dart:convert';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:dart_nats/dart_nats.dart';
import 'package:logger/logger.dart';

import 'package:hydroponics_framework/datamodels/json_model.dart';
import 'package:hydroponics_framework/utilities.dart';

import 'errors.dart';

class NatsHeaders {

  bool result = false;
  String code = "";
  String msg = "";

  NatsHeaders(Message<dynamic> response) {
    if(response.header != null && response.header!.headers != null) {
      var headerFields = response.header!.headers!;
      var res = headerFields["result"];
      logger.d("RESULT = $res");
      if(res == "ok") {
        result = true;
      } else {
        result = false;
        code = headerFields["code"] ?? "";
        msg = headerFields["msg"] ?? "";
        logger.d("ERROR = [$code] [$msg] ");
      }
    } else {
     throw Exception("Message has no headers");
    }
  }
  var logger = Logger();
}

class MicroserviceService extends GetxController {

  static MicroserviceService get ms => Get.find();

  var connected = false.obs;
  Client client = Client();
  var logger = Logger();

  connect(String server) {
    String url = "nats://$server:4222";
    logger.d("Connecting to server $url");
    client.connect(Uri.parse(url), retry: true, retryCount: -1,
      connectOption: ConnectOption(headers: true)
    );
    client.statusStream.listen((status) {
      switch (status) {
        case Status.connected :
          //logger.d("Server connected");
          connected.value = true;
          break;
        default :
          connected.value = false;
          break;
      }
    });
  }

  void request(String topic, JsonModel data, Function(Map<String,dynamic>?) onSuccess, Function(String, String) onError) {
    final json = jsonEncode(data.toJson());
    logger.d("request to $topic with data = $json");
    client.request(topic, Utilities.convertStringToUint8List(json))
        .then((response) {
      final headers = NatsHeaders(response);
      if(headers.result) {
        if(response.byte.isNotEmpty) {
          final string = Utilities.convertUint8ListToString(response.byte);
          logger.d("topic $topic Received $string");
          final json = jsonDecode(string);
          onSuccess(json);
        } else {
          onSuccess({});
        }
      } else {
        logger.d("Error ${headers.code} ${headers.msg}");
        onError(headers.code, headers.msg);
      }
    }).onError((error, stackTrace) => onError(Errors.communicationsError, error.toString()));
  }

  void requestList(String topic, JsonModel data, Function(List<Map<String,dynamic>>?) onSuccess, Function(String,String) onError) {
    final json = jsonEncode(data.toJson());
    logger.d("request to $topic with data = $json");
    client.request(topic, Utilities.convertStringToUint8List(json)).then((response) {
      final headers = NatsHeaders(response);
      if(headers.result) {
        final string = Utilities.convertUint8ListToString(response.byte);
        logger.d("topic $topic Received $string");
        final jsonList = List<Map<String, dynamic>>.from(jsonDecode(string));
        onSuccess(jsonList);
      } else {
        logger.d("Error ${headers.code} ${headers.msg}");
        onError(headers.code, headers.msg);
      }
    }).onError((error, stackTrace) => onError(Errors.communicationsError, error.toString()));
  }

  void requestNoParameters(String topic, Function(Map<String,dynamic>) onSuccess, Function(String, String) onError) {
    logger.d("request to $topic");
    client.request(topic, Uint8List(0)).then((response) {
      final headers = NatsHeaders(response);
      if(headers.result) {
        if(response.byte.isNotEmpty) {
          final string = Utilities.convertUint8ListToString(response.byte);
          logger.d("topic $topic Received $string");
          final json = jsonDecode(string);
          onSuccess(json);
        } else {
          onSuccess({});
        }
      } else {
        logger.d("Error ${headers.code} ${headers.msg}");
        onError(headers.code, headers.msg);
      }
    }); //.onError((error, stackTrace) {}); //onError(Errors.communicationsError, ""));
  }
  void requestListNoParameters(String topic, Function(List<Map<String,dynamic>>) onSuccess, Function(String,String) onError) {
    logger.d("request to $topic");
    client.request(topic, Uint8List(0)).then((response) {
      final headers = NatsHeaders(response);
      if(headers.result) {
        final string = Utilities.convertUint8ListToString(response.byte);
        logger.d("topic $topic Received $string");
        final jsonList = List<Map<String, dynamic>>.from(jsonDecode(string));
        onSuccess(jsonList);
      } else {
        logger.d("Error ${headers.code} ${headers.msg}");
        onError(headers.code, headers.msg);
      }
    }).onError((error, stackTrace) => onError(Errors.communicationsError, error.toString()));
  }

  void requestDataNoParameters(String topic, Function(Uint8List) onSuccess, Function(String, String) onError) {

    logger.d("request to $topic");
    client.request(topic, Uint8List(0)).then((response) {
      final headers = NatsHeaders(response);
      if(headers.result) {
        onSuccess(response.data as Uint8List);
      } else {
        logger.d("Error ${headers.code} ${headers.msg}");
        onError(headers.code, headers.msg);
      }
    }).onError((error, stackTrace) => onError(Errors.communicationsError, error.toString()));
  }

  void listen(String topic, Function(Map<String,dynamic>) onEvent) {
    client.sub(topic).stream.listen((event) {
      final string = Utilities.convertUint8ListToString(event.byte);
      logger.d("Received $string");
      final json = jsonDecode(string);
      onEvent(json);
    });
  }

  void publish(String topic, JsonModel data) {
    final json = jsonEncode(data.toJson());
    logger.d("Publishing data $json to $topic");
    client.pub(topic, Utilities.convertStringToUint8List(json));
  }
}
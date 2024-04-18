import 'dart:async';
import 'dart:convert';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SubscriptionContext {
  Stream<String> stream;
  int referenceCount;
  SubscriptionContext(this.stream, this.referenceCount);
}

class WebService {
  final String hostName;
  final int port;
  final bool isSecure;

  late final String wsScheme;
  late final String httpScheme;

  final logger = Logger();

  WebService({
    required this.hostName,
    required this.port,
    required this.isSecure
  }) {
    if(isSecure) {
      wsScheme = "wss";
      httpScheme = "https";
    } else {
      wsScheme = "ws";
      httpScheme = "http";
    }
  }

  Map<String, SubscriptionContext> subscriptions = {};

  Future<Stream<Map<String,dynamic>>> stream(String path) async {
    final wsUrl = Uri(scheme: wsScheme, host: hostName, port: port, path: path);
    logger.d("STREAM url ${wsUrl.toString()}");
    StreamController<Map<String,dynamic>> streamController = StreamController.broadcast();
    WebSocketChannel channel = WebSocketChannel.connect(wsUrl);
    await channel.ready;
    channel.stream.listen((message) => streamController.add(jsonDecode(message)));
    return streamController.stream;
  }

  Future<String?> post(String path, Map<String,dynamic> data) async {
    Uri uri = Uri(scheme: httpScheme, host: hostName, port: port, path: path);
    logger.d("POST url ${uri.toString()} DATA = ${jsonEncode(data)}");
    var response = await http.post(uri, body: jsonEncode(data));
    if(response.statusCode == 200 && response.contentLength != null && response.contentLength != 0) {
      logger.d("POST url ${uri.toString()} RESPONSE = ${response.body}");
      return response.body;
    }
    return null;
  }

  Future<String?> put(String path, Map<String,dynamic> data) async {
    Uri uri = Uri(scheme: httpScheme, host: hostName, port: port, path: path);
    logger.d("PUT url ${uri.toString()} DATA = ${jsonEncode(data)}");
    var response = await http.put(uri, body: jsonEncode(data));
    if(response.statusCode == 200 && response.contentLength != null && response.contentLength != 0) {
      logger.d("POST url ${uri.toString()} RESPONSE = ${response.body}");
      return response.body;
    }
    return null;
  }

  Future<String?> get(String path) async {
    Uri uri = Uri(scheme: httpScheme, host: hostName, port: port, path: path);
    logger.d("GET url ${uri.toString()}");
    var response = await http.get(uri);
    if(response.statusCode == 200 && response.contentLength != null && response.contentLength != 0) {
      logger.d("GET url ${uri.toString()} RESPONSE = ${response.body}");
      return response.body;
    }
    return null;
  }

  /*Stream<String> listenSse(String path) {
    Uri uri = Uri(scheme: httpScheme, host: hostName, port: port, path: path);
    logger.d("LISTEN url ${uri.toString()}");
    StreamController<String> events = StreamController.broadcast();

    SSEClient.subscribeToSSE(
        method: SSERequestType.GET,
        url: uri.toString(),
        header: {
          "Accept": "text/event-stream",
          "Cache-Control": "no-cache",
        }
    ).listen((event) {
      logger.d("FECEIVED ${event.data}");
      events.add(event.data!);
    },
    );
  }*/

  Stream<String> subscribe(String path) {
    SubscriptionContext? subscription = subscriptions[path];

    if(subscription == null) {
      BehaviorSubject<String> streamController = BehaviorSubject();
      _openWebSocket(path, streamController);
      subscriptions[path] = SubscriptionContext(streamController.stream, 1);
      return streamController.stream;

    } else {
      ++subscription.referenceCount;
      return subscription.stream;
    }
  }

  void _openWebSocket(String path, BehaviorSubject<String> streamController) async {
    Uri uri = Uri(scheme: wsScheme, host: hostName, port: port, path: path);
    logger.d("OPENING SOCKET url ${uri.toString()}");
    final channel = WebSocketChannel.connect(uri);
      await channel.ready;
      channel.stream.listen((e) {
        if(e is String)
          streamController.add(e);
        },
        onError: (err) {
          logger.d("WEBSOCKET ERROR $err");
        },
        onDone: () {
          logger.d("WEBSOCKET CLOSED");
          SubscriptionContext? subscription = subscriptions[path];
          if(subscription != null && subscription.referenceCount > 0)
            _openWebSocket(path, streamController);
        }
      );
  }
}
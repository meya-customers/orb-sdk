import 'dart:async';

import 'package:flutter/services.dart';

import 'package:meta/meta.dart';

class ConnectionOptions {
  final String gridUrl;
  final String appId;
  final String integrationId;
  final Map<dynamic, dynamic> pageContext;
  final String gridUserId;
  final String userId;
  final String threadId;
  final String sessionToken;
  final String magicLinkId;
  final String url;
  final String referrer;

  ConnectionOptions({
    @required this.gridUrl,
    @required this.appId,
    @required this.integrationId,
    this.pageContext,
    this.gridUserId,
    this.userId,
    this.threadId,
    this.sessionToken,
    this.magicLinkId,
    this.url,
    this.referrer,
  });
}

class OrbPlugin {
  static const MethodChannel channel = const MethodChannel('orb');
  static void Function(ConnectionOptions) connect;
  static void Function() disconnect;
  static void Function(Map<dynamic, dynamic>) publishEvent;
  static Set<String> subscriptions = {};

  static void init() {
    channel.setMethodCallHandler(nativeMethodCallHandler);
  }

  static Future<dynamic> nativeMethodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'connect':
        if (connect != null)
          connect(ConnectionOptions(
            gridUrl: call.arguments['gridUrl'],
            appId: call.arguments['appId'],
            integrationId: call.arguments['integrationId'],
            pageContext: call.arguments['pageContext'],
            userId: call.arguments['userId'],
            threadId: call.arguments['threadId'],
            sessionToken: call.arguments['sessionToken'],
            magicLinkId: call.arguments['magicLinkId'],
            url: call.arguments['url'],
            referrer: call.arguments['referrer'],
          ));
        return 'Called connected';
      case 'disconnect':
        if (disconnect != null) disconnect();
        return 'Disconnect called';
      case 'publishEvent':
        if (publishEvent != null) publishEvent(call.arguments['event']);
        return 'Publish event called';
      case 'subscribe':
        final name = call.arguments['name'];
        subscriptions.add(name);
        return 'Subscribed to $name';
      case 'unsubscribe':
        final name = call.arguments['name'];
        subscriptions.remove(name);
        return 'Subscribed to $name';
      default:
        return 'Unsupported method call ${call.method}';
    }
  }

  static bool isSubscribed(String name) => subscriptions.contains(name);

  static Future<String> get platformVersion async {
    return await channel.invokeMethod('getPlatformVersion');
  }

  static Future<String> ready() async {
    return await channel.invokeMethod('ready');
  }

  static Future<String> connected() async {
    return await channel.invokeMethod('connected');
  }

  static Future<String> disconnected() async {
    return await channel.invokeMethod('disconnected');
  }

  static Future<String> firstConnect(
    List<Map<String, dynamic>> eventStream,
  ) async {
    return await channel
        .invokeMethod('firstConnect', {'eventStream': eventStream});
  }

  static Future<String> reconnect(
    List<Map<String, dynamic>> eventStream,
  ) async {
    return await channel
        .invokeMethod('reconnect', {'eventStream': eventStream});
  }

  static Future<String> event(
    Map<String, dynamic> event,
    List<Map<String, dynamic>> eventStream,
  ) async {
    return await channel.invokeMethod('event', {
      'event': event,
      'eventStream': eventStream,
    });
  }

  static Future<String> eventStream(
    List<Map<String, dynamic>> eventStream,
  ) async {
    return await channel.invokeMethod(
      'eventStream',
      <String, dynamic>{
        'eventStream': eventStream,
      },
    );
  }
}
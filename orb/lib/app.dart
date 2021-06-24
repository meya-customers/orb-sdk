import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:orb/connection.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/plugin.dart';
import 'package:orb/ui/chat.dart';
import 'package:orb/ui/design.dart';

class OrbApp extends StatefulWidget {
  @override
  _OrbAppState createState() => _OrbAppState();
}

class _OrbAppState extends State<OrbApp> {
  final OrbThemeData theme = OrbThemeData();

  OrbConnection connection;
  String platformVersion = "Unknown";
  bool ready = false;

  @override
  void initState() {
    super.initState();
    OrbPlugin.init();
    initPlatformState();
    OrbPlugin.ready();
    OrbPlugin.connect = connect;
    OrbPlugin.disconnect = disconnect;
    OrbPlugin.publishEvent = publishEvent;
  }

  Future<void> initPlatformState() async {
    String version;
    try {
      version = await OrbPlugin.platformVersion;
    } on PlatformException {
      version = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      print('Platform version: $version');
      platformVersion = version;
    });
  }

  void connect(ConnectionOptions options) {
    setState(() {
      connection = OrbConnection(
        gridUrl: options.gridUrl,
        appId: options.appId,
        integrationId: options.integrationId,
        pageContext: options.pageContext,
        userId: options.userId,
        threadId: options.threadId,
        sessionToken: options.sessionToken,
        magicLinkId: options.magicLinkId,
        url: options.url,
        referrer: options.referrer,
        deviceId: options.deviceId,
        deviceToken: options.deviceToken,
        enableCloseButton: options.enableCloseButton,
      );
      connection.addOrbListener('connected', onConnected);
      connection.addOrbListener('firstConnect', onFirstConnect);
      connection.addOrbListener('reconnect', onReconnect);
      connection.addOrbListener('event', onEvent);
      connection.addOrbListener('eventStream', onEventStream);
      connection.addOrbListener('closeUi', onCloseUi);
      connection.addListener(
        () => setState(() {
          // New event stream ready for building
        }),
      );
      connection.connect();
    });
  }

  void disconnect(bool logOut) {
    connection.disconnect(logOut: logOut);
    setState(() {
      connection = null;
    });
    OrbPlugin.disconnected();
  }

  void publishEvent(Map<dynamic, dynamic> event) {
    if (connection == null) throw Exception('Orb is not connected.');
    if (connection != null) {
      connection.publishEvent(OrbEvent.fromEventMap(event));
    }
  }

  void onConnected(Map<String, dynamic> arguments) {
    OrbPlugin.connected();
  }

  void onFirstConnect(Map<String, dynamic> arguments) {
    if (!OrbPlugin.isSubscribed('firstConnect')) return null;
    final OrbEventStream eventStream = arguments['eventStream'];
    OrbPlugin.firstConnect(eventStream.rawEvents);
  }

  void onReconnect(Map<String, dynamic> arguments) {
    if (!OrbPlugin.isSubscribed('reconnect')) return null;
    final OrbEventStream eventStream = arguments['eventStream'];
    OrbPlugin.reconnect(eventStream.rawEvents);
  }

  void onEvent(Map<String, dynamic> arguments) {
    if (!OrbPlugin.isSubscribed('event')) return null;
    final OrbEvent event = arguments['event'];
    final OrbEventStream eventStream = arguments['eventStream'];
    OrbPlugin.event(event.toEventMap(), eventStream.rawEvents);
  }

  void onEventStream(Map<String, dynamic> arguments) {
    if (!OrbPlugin.isSubscribed('eventStream')) return null;
    final OrbEventStream eventStream = arguments['eventStream'];
    OrbPlugin.eventStream(eventStream.rawEvents);
  }

  void onCloseUi(Map<String, dynamic> arguments) {
    OrbPlugin.closeUi();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme.toMaterialThemeData(),
      home: connection != null
          ? OrbChat(
              eventStream: connection.getEventStream(),
              connection: connection,
            )
          : Scaffold(
              backgroundColor: theme.palette.brandLight,
              body: Center(
                child: Text('Ready to connect'),
              ),
            ),
      builder: theme.builder,
    );
  }
}

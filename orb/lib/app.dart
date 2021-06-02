import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:orb/connection.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/orb.dart';
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
    Orb.init();
    initPlatformState();
    Orb.ready();
    Orb.connect = connect;
    Orb.disconnect = disconnect;
    Orb.publishEvent = publishEvent;
  }

  Future<void> initPlatformState() async {
    String version;
    try {
      version = await Orb.platformVersion;
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
      );
      connection.addOrbListener('connected', onConnected);
      connection.addOrbListener('firstConnect', onFirstConnect);
      connection.addOrbListener('reconnect', onReconnect);
      connection.addOrbListener('event', onEvent);
      connection.addOrbListener('eventStream', onEventStream);
      connection.addListener(
        () => setState(() {
          // New event stream ready for building
        }),
      );
      connection.connect();
    });
  }

  void onConnected(Map<String, dynamic> arguments) {
    Orb.connected();
  }

  void onFirstConnect(Map<String, dynamic> arguments) {
    if (!Orb.isSubscribed('firstConnect')) return null;
    final OrbEventStream eventStream = arguments['eventStream'];
    Orb.firstConnect(eventStream.rawEvents);
  }

  void onReconnect(Map<String, dynamic> arguments) {
    if (!Orb.isSubscribed('reconnect')) return null;
    final OrbEventStream eventStream = arguments['eventStream'];
    Orb.reconnect(eventStream.rawEvents);
  }

  void onEvent(Map<String, dynamic> arguments) {
    if (!Orb.isSubscribed('event')) return null;
    final OrbEvent event = arguments['event'];
    final OrbEventStream eventStream = arguments['eventStream'];
    Orb.event(event.toEventMap(), eventStream.rawEvents);
  }

  void onEventStream(Map<String, dynamic> arguments) {
    if (!Orb.isSubscribed('eventStream')) return null;
    final OrbEventStream eventStream = arguments['eventStream'];
    Orb.eventStream(eventStream.rawEvents);
  }

  void disconnect() {
    setState(() {
      connection = null;
      Orb.disconnected();
    });
  }

  void publishEvent(Map<dynamic, dynamic> event) {
    if (connection == null) throw Exception('Orb is not connected.');
    if (connection != null) {
      connection.publishEvent(OrbEvent.fromEventMap(event));
    }
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

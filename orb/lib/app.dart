import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:orb/config.dart';
import 'package:orb/config_provider.dart';
import 'package:orb/connection.dart';
import 'package:orb/design.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/plugin.dart';
import 'package:orb/theme_provider.dart';
import 'package:orb/ui/chat.dart';
import 'package:orb/ui/menu.dart';

class OrbApp extends StatefulWidget {
  const OrbApp({Key? key}) : super(key: key);

  @override
  _OrbAppState createState() => _OrbAppState();
}

class _OrbAppState extends State<OrbApp> with WidgetsBindingObserver {
  OrbConfig config = const OrbConfig.init();
  OrbEventStream? eventStream;
  OrbConnection? connection;
  String platformVersion = 'Unknown';
  bool ready = false;
  AppLifecycleState deviceState = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    OrbPlugin.init();
    initPlatformState();
    OrbPlugin.ready();
    OrbPlugin.configure = configure;
    OrbPlugin.connect = connect;
    OrbPlugin.disconnect = disconnect;
    OrbPlugin.publishEvent = publishEvent;
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  Future<void> initPlatformState() async {
    String version;
    try {
      version = await OrbPlugin.platformVersion ?? 'Unknown';
    } on PlatformException {
      version = 'Failed to get platform version.';
    }

    if (!mounted) {
      return;
    }

    setState(() {
      log('Platform version: $version');
      platformVersion = version;
    });
  }

  void configure(OrbConfig Function(OrbConfig) update) {
    setState(() {
      config = update(const OrbConfig.init());
    });
  }

  void connect(ConnectionOptions options) {
    disconnect(logOut: false);
    setState(() {
      connection = OrbConnection(
        options: options,
        mediaUpload: OrbMediaUploadConfigResult.resolve(config.mediaUpload),
        deviceState: deviceState,
      );
      connection!.addOrbListener('connected', onConnected);
      connection!.addOrbListener('disconnected', onDisconnected);
      connection!.addOrbListener('firstConnect', onFirstConnect);
      connection!.addOrbListener('reconnect', onReconnect);
      connection!.addOrbListener('event', onEvent);
      connection!.addOrbListener('eventStream', onEventStream);
      connection!.addOrbListener('closeUi', onCloseUi);
      connection!.getConfig();
      connection!.connect();
    });
  }

  void disconnect({required bool logOut}) {
    setState(() {
      eventStream = null;
      connection?.disconnect(logOut: logOut);
      connection?.removeOrbListener('connected', onConnected);
      connection?.removeOrbListener('disconnected', onDisconnected);
      connection?.removeOrbListener('firstConnect', onFirstConnect);
      connection?.removeOrbListener('reconnect', onReconnect);
      connection?.removeOrbListener('event', onEvent);
      connection?.removeOrbListener('eventStream', onEventStream);
      connection?.removeOrbListener('closeUi', onCloseUi);
      connection = null;
    });
  }

  void publishEvent(Map<dynamic, dynamic> event) {
    connection?.publishEvent(OrbEvent.fromEventMap(event));
  }

  void onConnected() {
    OrbPlugin.connected();
  }

  void onDisconnected() {
    OrbPlugin.disconnected();
  }

  void onFirstConnect({required OrbEventStream eventStream}) {
    if (!OrbPlugin.isSubscribed('firstConnect')) {
      return;
    }
    OrbPlugin.firstConnect(eventStream.rawEvents);
  }

  void onReconnect({required OrbEventStream eventStream}) {
    if (!OrbPlugin.isSubscribed('reconnect')) {
      return;
    }
    OrbPlugin.reconnect(eventStream.rawEvents);
  }

  void onEvent({required OrbEventStream eventStream, required OrbEvent event}) {
    setState(() {
      this.eventStream = eventStream;
    });
    if (!OrbPlugin.isSubscribed('event')) {
      return;
    }
    OrbPlugin.event(event.toEventMap(), eventStream.rawEvents);
  }

  void onEventStream({required OrbEventStream eventStream}) {
    setState(() {
      this.eventStream = eventStream;
    });
    if (!OrbPlugin.isSubscribed('eventStream')) {
      return;
    }
    OrbPlugin.eventStream(eventStream.rawEvents);
  }

  void onCloseUi() {
    OrbPlugin.closeUi();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      deviceState = state;
      connection?.deviceState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OrbConfigProvider(
      config: config,
      connection: connection,
      child: OrbThemeProvider(
        child: OrbMenuProvider(
          child: OrbMaterialApp(
            eventStream: eventStream,
            connection: connection,
          ),
        ),
      ),
    );
  }
}

class OrbMaterialApp extends StatelessWidget {
  final OrbEventStream? eventStream;
  final OrbConnection? connection;

  const OrbMaterialApp({
    required this.eventStream,
    required this.connection,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: OrbTheme.of(context).toMaterialThemeData(),
      home: connection != null &&
              eventStream != null &&
              eventStream!.events.any(
                (event) =>
                    event.data['composer'] != null &&
                    !eventStream!.isSelfEvent(event),
              )
          ? OrbChat(
              eventStream: eventStream!,
              connection: connection!,
            )
          : const OrbSplash(),
      builder: OrbTheme.of(context).builder,
    );
  }
}

class OrbSplash extends StatelessWidget {
  const OrbSplash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrbTheme.of(context).palette.blank,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: !OrbConfig.of(context).ui.visible
                  ? OrbTheme.of(context).palette.disabled
                  : OrbTheme.of(context).palette.brand,
            ),
            SizedBox(height: OrbTheme.of(context).lengths.medium),
            Text(
              !OrbConfig.of(context).ui.visible
                  ? ''
                  : OrbConfig.of(context).splash.readyText,
              style: (OrbTheme.of(context).text.font.normal)
                  .merge(OrbTheme.of(context).text.style.normal)
                  .merge(OrbTheme.of(context).text.size.medium)
                  .copyWith(color: OrbTheme.of(context).palette.brand),
            )
          ],
        ),
      ),
    );
  }
}

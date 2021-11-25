import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'package:orb/config.dart';
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

class _OrbAppState extends State<OrbApp> with WidgetsBindingObserver {
  late OrbConfig orbConfig;
  OrbConnection? connection;
  String platformVersion = "Unknown";
  bool ready = false;
  AppLifecycleState deviceState = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    orbConfig = OrbConfig.init();
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
      version = await OrbPlugin.platformVersion ?? "Unknown";
    } on PlatformException {
      version = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      print('Platform version: $version');
      platformVersion = version;
    });
  }

  void configure(
    ThemeConfigSpec theme,
    ComposerConfigSpec composer,
    SplashConfigSpec splash,
    MediaUploadConfigSpec mediaUpload,
  ) {
    orbConfig.update(
        theme: theme,
        composer: composer,
        splash: splash,
        mediaUpload: mediaUpload);
  }

  void connect(ConnectionOptions options) {
    setState(() {
      connection?.disconnect();
      connection = OrbConnection(
        orbConfig: orbConfig,
        options: options,
        deviceState: deviceState,
      );
      connection!.addOrbListener('connected', onConnected);
      connection!.addOrbListener('disconnected', onDisconnected);
      connection!.addOrbListener('firstConnect', onFirstConnect);
      connection!.addOrbListener('reconnect', onReconnect);
      connection!.addOrbListener('event', onEvent);
      connection!.addOrbListener('eventStream', onEventStream);
      connection!.addOrbListener('closeUi', onCloseUi);
      connection!.addListener(
        () => setState(() {
          // New event stream ready for building
        }),
      );
      connection!.connect();
    });
  }

  void disconnect(bool logOut) {
    connection?.disconnect(logOut: logOut);
    setState(() {
      connection = null;
    });
  }

  void publishEvent(Map<dynamic, dynamic>? event) {
    connection?.publishEvent(OrbEvent.fromEventMap(event));
  }

  void onConnected(Map<String, dynamic> arguments) {
    OrbPlugin.connected();
  }

  void onDisconnected(Map<String, dynamic> arguments) {
    OrbPlugin.disconnected();
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      deviceState = state;
      connection?.deviceState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OrbConfig>(
      create: (_) => orbConfig,
      builder: (context, child) {
        final orbConfig = context.watch<OrbConfig>();
        return MaterialApp(
          theme: orbConfig.orbThemeData.toMaterialThemeData(),
          home: connection != null
              ? OrbChat(
                  eventStream: connection!.getEventStream(),
                  connection: connection!,
                )
              : OrbSplash(),
          builder: orbConfig.orbThemeData.builder,
        );
      },
    );
  }
}

class OrbSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orbConfig = context.watch<OrbConfig>();
    return Scaffold(
      backgroundColor: OrbTheme.of(context).palette.blank,
      body: Center(
        child: Text(orbConfig.splash.readyText!),
      ),
    );
  }
}

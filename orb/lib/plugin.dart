import 'dart:async';

import 'package:flutter/services.dart';

import 'package:orb/config.dart';
import 'package:orb/connection.dart';
import 'package:orb/event.dart';

class OrbPlugin {
  static const MethodChannel channel = MethodChannel('orb');
  static void Function(OrbConfig Function(OrbConfig))? configure;
  static void Function(ConnectionOptions)? connect;
  static void Function({required bool logOut})? disconnect;
  static void Function(Map<dynamic, dynamic>)? publishEvent;
  static Set<String?> subscriptions = {};

  static void init() {
    channel.setMethodCallHandler(nativeMethodCallHandler);
  }

  static Future<dynamic> nativeMethodCallHandler(MethodCall call) async {
    final method = call.method;
    final Map<dynamic, dynamic> arguments = call.arguments;
    switch (method) {
      case 'configure':
        final Map<dynamic, dynamic> theme = arguments['theme'] ?? {};
        final Map<dynamic, dynamic> composer = arguments['composer'] ?? {};
        final Map<dynamic, dynamic> header = arguments['header'] ?? {};
        final Map<dynamic, dynamic>? headerTitle = header['title'];
        final Map<dynamic, dynamic>? headerProgress = header['progress'];
        final Map<dynamic, dynamic> menu = arguments['menu'] ?? {};
        final Map<dynamic, dynamic> splash = arguments['splash'] ?? {};
        final Map<dynamic, dynamic> mediaUpload =
            arguments['mediaUpload'] ?? {};
        configure?.call(
          (config) => config.copyWith(
            theme: config.theme.copyWith(
              brandColor: theme['brandColor'],
              backgroundTranslucency: theme['backgroundTranslucency'],
            ),
            composer: config.composer.copyWith(
              focus: OrbComposerFocusExtension.fromString(composer['focus']),
              placeholder: composer['placeholder'],
              collapsePlaceholder: composer['collapsePlaceholder'],
              visibility: OrbComposerVisibilityExtension.fromString(
                composer['visibility'],
              ),
              placeholderText: composer['placeholderText'],
              collapsePlaceholderText: composer['collapsePlaceholderText'],
              fileButtonText: composer['fileButtonText'],
              fileSendText: composer['fileSendText'],
              imageButtonText: composer['imageButtonText'],
              cameraButtonText: composer['cameraButtonText'],
              galleryButtonText: composer['galleryButtonText'],
            ),
            header: config.header.copyWith(
              buttons: header['buttons'],
              title: OrbHeaderTitleEventSpec.fromMap(
                headerTitle != null
                    ? {
                        'icon': headerTitle['title'],
                        'title': headerTitle['title'],
                      }
                    : null,
              ),
              progress: OrbHeaderProgressEventSpec.fromMap(
                headerProgress != null
                    ? {
                        'value': headerProgress['value'],
                        'show_percent': headerProgress['showPercent'],
                      }
                    : null,
              ),
              milestones: header['milestones'],
              extraButtons: header['extraButtons'],
            ),
            menu: config.menu.copyWith(
              closeText: menu['closeText'],
              backText: menu['backText'],
            ),
            splash: config.splash.copyWith(
              readyText: splash['readyText'],
            ),
            mediaUpload: config.mediaUpload.copyWith(
              all: mediaUpload['all'],
              image: mediaUpload['image'],
              file: mediaUpload['file'],
            ),
          ),
        );
        return 'Configure called';
      case 'connect':
        connect?.call(
          ConnectionOptions(
            gridUrl: arguments['gridUrl'],
            appId: arguments['appId'],
            integrationId: arguments['integrationId'],
            pageContext: arguments['pageContext'],
            userId: arguments['userId'],
            threadId: arguments['threadId'],
            sessionToken: arguments['sessionToken'],
            magicLinkId: arguments['magicLinkId'],
            url: arguments['url'],
            referrer: arguments['referrer'],
            deviceId: arguments['deviceId'],
            deviceToken: arguments['deviceToken'],
            enableCloseButton: arguments['enableCloseButton'] ?? true,
          ),
        );
        return 'Connect called';
      case 'disconnect':
        disconnect?.call(logOut: arguments['logOut'] ?? false);
        return 'Disconnect called';
      case 'publishEvent':
        publishEvent?.call(arguments['event']);
        return 'Publish event called';
      case 'subscribe':
        final name = arguments['name'];
        subscriptions.add(name);
        return 'Subscribed to $name';
      case 'unsubscribe':
        final name = arguments['name'];
        subscriptions.remove(name);
        return 'Subscribed to $name';
      default:
        return 'Unsupported method call $method';
    }
  }

  static bool isSubscribed(String name) => subscriptions.contains(name);

  static Future<String?> get platformVersion async {
    return await channel.invokeMethod('getPlatformVersion');
  }

  static Future<String?> ready() async {
    return await channel.invokeMethod('ready');
  }

  static Future<String?> connected() async {
    return await channel.invokeMethod('connected');
  }

  static Future<String?> disconnected() async {
    return await channel.invokeMethod('disconnected');
  }

  static Future<String?> firstConnect(
    List<Map<String, dynamic>> eventStream,
  ) async {
    return await channel
        .invokeMethod('firstConnect', {'eventStream': eventStream});
  }

  static Future<String?> reconnect(
    List<Map<String, dynamic>> eventStream,
  ) async {
    return await channel
        .invokeMethod('reconnect', {'eventStream': eventStream});
  }

  static Future<String?> event(
    Map<String, dynamic> event,
    List<Map<String, dynamic>> eventStream,
  ) async {
    return await channel.invokeMethod('event', {
      'event': event,
      'eventStream': eventStream,
    });
  }

  static Future<String?> eventStream(
    List<Map<String, dynamic>> eventStream,
  ) async {
    return await channel.invokeMethod(
      'eventStream',
      <String, dynamic>{
        'eventStream': eventStream,
      },
    );
  }

  static Future<String?> closeUi() async {
    return await channel.invokeMethod('closeUi');
  }
}

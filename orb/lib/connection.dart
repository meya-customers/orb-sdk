import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:msgpack_dart/msgpack_dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:orb/blob.dart';
import 'package:orb/event.dart';
import 'package:orb/event_emitter.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/util.dart';
import 'package:orb/version.dart';

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
  final String deviceId;
  final String deviceToken;
  final bool enableCloseButton;

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
    this.deviceId,
    this.deviceToken,
    this.enableCloseButton,
  });
}

class OrbConnection extends ChangeNotifier {
  String gridUrl;
  String blobUrl;
  String appId;
  String integrationId;
  Map<dynamic, dynamic> pageContext;
  String gridUserId;
  String userId;
  String threadId;
  String sessionToken;
  String magicLinkId;
  String url;
  String referrer;
  String deviceId;
  String deviceToken;
  bool enableCloseButton;
  Function(Map<dynamic, dynamic>, Function) onFirstConnect;

  bool firstConnect = true;
  bool reconnect = false;
  int retries = 0;

  Timer _heartbeatTimer;
  Timer _timer;
  bool _connected = false;
  WebSocketChannel _channel;
  EventEmitter _eventEmitter = EventEmitter();
  OrbEventStream _eventStream = OrbEventStream();
  FlutterSecureStorage _storage = FlutterSecureStorage();
  AppLifecycleState _deviceState = AppLifecycleState.resumed;

  OrbConnection({
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
    this.deviceId,
    this.deviceToken,
    this.onFirstConnect,
    this.enableCloseButton,
    AppLifecycleState deviceState,
  }) {
    blobUrl = '$gridUrl/gateway/v2/blob/$appId/blob';
    if (deviceState != null) _deviceState = deviceState;
  }

  bool get connected => _connected;

  AppLifecycleState get deviceState => _deviceState;

  set deviceState(AppLifecycleState state) {
    _deviceState = state;
    if (connected) {
      publishEvent(OrbEvent.createDeviceStateEvent(
        deviceId: deviceId,
        deviceState: deviceState,
      ));
    }
  }

  void addOrbListener(String type, Function(Map<String, dynamic>) listener) =>
      _eventEmitter.on(type, listener);

  void removeOrbListener(
          String type, Function(Map<String, dynamic>) listener) =>
      _eventEmitter.off(type, listener);

  Future<void> connect() async {
    userId = await _storage.read(key: "orbUserId");
    threadId = await _storage.read(key: "orbThreadId") ??
        OrbUtil.generateOrbIntegrationId();
    sessionToken = await _storage.read(key: "orbSessionToken");

    Uri url = Uri.parse('$gridUrl/gateway/v2/orb/$appId/$integrationId');
    Map<String, dynamic> queryParams = {};
    if (userId != null) {
      queryParams['user_id'] = userId;
    }
    queryParams['thread_id'] = threadId;
    if (sessionToken != null) {
      queryParams['session_token'] = sessionToken;
    }
    if (magicLinkId != null && firstConnect) {
      queryParams['magic_link_id'] = magicLinkId;
    }
    queryParams['version'] = await version();
    url = url.replace(
      scheme: "wss",
      host: url.host,
      port: url.port,
      path: url.path,
      queryParameters: queryParams,
    );

    _channel = IOWebSocketChannel.connect(url.toString());
    _connected = false;
    reconnect = true;

    final timeoutInterval = _getTimeoutInterval();
    _timer = Timer(timeoutInterval, () {
      print('TIMEOUT $timeoutInterval');
      _channel.sink.close();
    });

    print("Listening $_channel");
    _channel.stream.listen(
      (streamEvent) {
        final payload = deserialize(streamEvent);
        if (payload["type"] == "meya.orb.entry.ws.connected_request") {
          _timer?.cancel();
          final gridVersion = payload['data']['grid_version'];
          print("CONNECTED grid-v$gridVersion");
          _eventEmitter.emit('connected', {});

          gridUserId = payload['data']['grid_user_id'];
          userId = payload['data']['user_id'];
          sessionToken = payload['data']['session_token'];

          _storage.write(key: "orbUserId", value: userId);
          _storage.write(key: "orbThreadId", value: threadId);
          _storage.write(key: "orbSessionToken", value: sessionToken);

          final List<OrbEvent> historyEvents =
              (payload['data']['history_events'] ?? [])
                  .map<OrbEvent>((eventMap) => OrbEvent.fromEventMap(eventMap))
                  .toList();
          final historyUserData = (payload['data']['history_user_data'] ?? {})
              .map((key, value) => MapEntry(key, OrbUserData.fromMap(value)))
              .cast<String, OrbUserData>();

          _connected = true;

          if (deviceToken != null) {
            publishEvent(OrbEvent.createDeviceConnectEvent(
              deviceId: deviceId,
              deviceToken: deviceToken,
              deviceState: deviceState,
            ));
          }

          final heartbeatIntervalSeconds =
              payload['data']['heartbeat_interval_seconds'];
          _startHeartbeat(heartbeatIntervalSeconds);

          final firstConnect = this.firstConnect;
          if (firstConnect) {
            this.firstConnect = false;
            final onFirstConnect =
                this.onFirstConnect ?? (data, next) => next();
            onFirstConnect(
              payload['data'],
              () => _onFirstConnect(payload['data']),
            );
          }

          _receiveAll(
            receiveBuffer: historyEvents,
            userData: historyUserData,
            emit: () => _eventEmitter.emit(
              firstConnect ? 'firstConnect' : 'reconnect',
              {'eventStream': _eventStream},
            ),
          );

          notifyListeners();
        } else if (payload["type"] == "meya.orb.entry.ws.publish_request") {
          final eventMap = payload["data"]["event"];
          final event = OrbEvent.fromEventMap(eventMap);
          final userData = (payload["data"]["user_data"] ?? {})
              .map((key, value) => MapEntry(key, OrbUserData.fromMap(value)))
              .cast<String, OrbUserData>();

          _receiveAll(
            receiveBuffer: [event],
            userData: <String, OrbUserData>{
              ..._eventStream.userData,
              ...userData,
            },
            emit: () => _eventEmitter.emit(
              'event',
              {'event': event, 'eventStream': _eventStream},
            ),
          );
          notifyListeners();
        }
      },
      onDone: () {
        print("DONE");
        _timer?.cancel();
        _heartbeatTimer?.cancel();
        _connected = false;
        _reconnect();
        notifyListeners();
      },
      onError: (error, stackTrace) {
        print('ERROR $error');
        _timer?.cancel();
        _heartbeatTimer?.cancel();
      },
    );
  }

  void disconnect({bool logOut = false}) {
    if (logOut) {
      gridUserId = null;
      userId = null;
      sessionToken = null;
      magicLinkId = null;
      _storage.deleteAll();
      firstConnect = true;
      _eventStream = OrbEventStream();
      _eventEmitter.emit('eventStream', {'eventStream': _eventStream});
    }
    reconnect = false;
    retries = 0;
    _timer?.cancel();
    _heartbeatTimer?.cancel();
    _channel?.sink?.close();
    _eventEmitter.emit('disconnected', {});
  }

  void publishEvent(OrbEvent event) {
    final eventMap = {
      'type': event.type,
      'data': event.data,
    };
    final payloadMap = {
      'type': 'meya.orb.entry.ws.publish_request',
      'data': {
        'request_id': OrbUtil.uuid4Hex(),
        'event': eventMap,
        'thread_id': this.threadId,
      }
    };
    _channel.sink.add(serialize(payloadMap));
  }

  OrbEventStream getEventStream() {
    return _eventStream;
  }

  void _onFirstConnect(Map<dynamic, dynamic> connectData) {
    publishEvent(
        OrbEvent.createPageOpenEvent(url, referrer, null, pageContext));
    if (connectData.containsKey('magic_link_event')) {
      this.publishEvent(OrbEvent.fromEventMap(connectData['magic_link_event']));
    }
  }

  void _startHeartbeat(int heartbeatIntervalSeconds) {
    _heartbeatTimer?.cancel();
    if (heartbeatIntervalSeconds != null && heartbeatIntervalSeconds >= 5) {
      _heartbeatTimer = Timer.periodic(
        Duration(seconds: heartbeatIntervalSeconds),
        (timer) {
          if (deviceState != AppLifecycleState.resumed) return;
          print('HEARTBEAT $deviceId');
          publishEvent(OrbEvent.createDeviceHeartbeatEvent(
            deviceId: deviceId,
          ));
        },
      );
    }
  }

  void _reconnect() async {
    final retryInterval = _getRetryTimeoutInterval();
    print('RETRYING $retries $retryInterval');
    await Future.delayed(retryInterval);

    if (!reconnect) {
      print('Retry cancelled.');
      return;
    }

    retries++;
    connect();
  }

  Duration _getTimeoutInterval() => Duration(milliseconds: 3000);

  Duration _getRetryTimeoutInterval() {
    final base = 10;
    final variance = Random().nextDouble() * 0.2 + 0.9;
    final backoff = pow(2, retries);
    return Duration(
      milliseconds: (base * variance * backoff).toInt(),
    );
  }

  void _receiveAll({
    @required List<OrbEvent> receiveBuffer,
    @required Map<String, OrbUserData> userData,
    @required Function emit,
  }) {
    final newEventStream = OrbEventStream(gridUserId: gridUserId, events: [
      ...receiveBuffer,
      ..._eventStream.events
    ], userData: <String, OrbUserData>{
      ..._eventStream.userData,
      ...userData,
    });
    if (newEventStream.events.length != _eventStream.events.length) {
      _eventStream = newEventStream;
      _eventEmitter.emit('eventStream', {'eventStream': _eventStream});
      emit();
    }
  }

  Future<Uri> postBlob(OrbBlob blob) async {
    var mimeType = lookupMimeType(blob.file.path);
    var body = await blob.file.readAsBytes();

    final response = await http.post(
      Uri.parse(blobUrl),
      headers: {
        "Content-Type": mimeType,
      },
      body: body,
    );
    if (response.statusCode != 201) {
      throw Exception('Upload error');
    }
    final blobId = response.body;
    return Uri.parse('$blobUrl/$blobId');
  }

  Future postBlobAndPublishEvent(OrbBlob blob) async {
    final url = await postBlob(blob);
    OrbEvent event;
    if (blob.type == OrbFileType.image) {
      event = OrbEvent.createImageEvent(url.toString(), blob.basename);
    } else {
      event = OrbEvent.createFileEvent(url.toString(), blob.basename);
    }
    publishEvent(event);
  }

  void closeUi() => _eventEmitter.emit('closeUi', {});
}

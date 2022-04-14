import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:msgpack_dart/msgpack_dart.dart';
import 'package:path/path.dart' as p;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:orb/config.dart';
import 'package:orb/event.dart';
import 'package:orb/event_emitter.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/util.dart';
import 'package:orb/version.dart';

class ConnectionOptions {
  final String gridUrl;
  final String appId;
  final String integrationId;
  final Map<dynamic, dynamic>? pageContext;
  final String? gridUserId;
  final String? userId;
  final String? threadId;
  final String? sessionToken;
  final String? magicLinkId;
  final String? url;
  final String? referrer;
  final String? deviceId;
  final String? deviceToken;
  void Function(Map<dynamic, dynamic>?, void Function())? onFirstConnect;
  final bool? enableCloseButton;

  ConnectionOptions({
    required this.gridUrl,
    required this.appId,
    required this.integrationId,
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
  });
}

class OrbConnection {
  final String _url;
  final String _blobUrl;
  final Map<dynamic, dynamic>? _pageContext;
  final String? _initialThreadId;
  final String? _pageUrl;
  final String? _referrer;
  final String? _deviceId;
  final String? _deviceToken;
  final void Function(Map<dynamic, dynamic>?, void Function())? _onFirstConnect;
  final bool? _enableCloseButton;
  final EventEmitter _eventEmitter = EventEmitter();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _gridUserId;
  String? _userId;
  String? _threadId;
  String? _sessionToken;
  String? _magicLinkId;
  bool _firstConnect = true;
  Map<dynamic, dynamic>? _configData;
  bool _reconnectOnSocketClose = false;
  int _retries = 0;
  Timer? _heartbeatTimer;
  Timer? _timer;
  bool _connected = false;
  WebSocketChannel? _channel;
  OrbEventStream _eventStream = OrbEventStream();
  OrbMediaUploadConfigResult _mediaUpload;
  AppLifecycleState _deviceState;

  OrbConnection({
    required ConnectionOptions options,
    required OrbMediaUploadConfigResult mediaUpload,
    AppLifecycleState? deviceState,
  })  : _mediaUpload = mediaUpload,
        _url =
            '${options.gridUrl}/gateway/v2/orb_mobile/${options.appId}/${options.integrationId}',
        _blobUrl = '${options.gridUrl}/gateway/v2/blob/${options.appId}/blob',
        _pageContext = options.pageContext,
        _gridUserId = options.gridUserId,
        _userId = options.userId,
        _threadId = options.threadId,
        _initialThreadId = options.threadId,
        _sessionToken = options.sessionToken,
        _magicLinkId = options.magicLinkId,
        _pageUrl = options.url,
        _referrer = options.referrer,
        _deviceId = options.deviceId,
        _deviceToken = options.deviceToken,
        _onFirstConnect = options.onFirstConnect,
        _enableCloseButton = options.enableCloseButton,
        _deviceState = deviceState ?? AppLifecycleState.resumed;

  bool get connected => _connected;

  bool get enableCloseButton => _enableCloseButton != false;

  AppLifecycleState get deviceState => _deviceState;

  set deviceState(AppLifecycleState state) {
    _deviceState = state;
    if (connected) {
      publishEvent(
        OrbEvent.createDeviceStateEvent(
          deviceId: _deviceId,
          deviceState: deviceState,
        ),
      );
    }
  }

  void addOrbListener(String type, Function listener) =>
      _eventEmitter.on(type, listener);

  void removeOrbListener(String type, Function listener) =>
      _eventEmitter.off(type, listener);

  Future<void> getConfig() async {
    final Map<String, dynamic> queryParams = {};
    const cacheSeconds = 60;
    queryParams['timestamp'] =
        ((DateTime.now().millisecondsSinceEpoch / 1000 / cacheSeconds).floor() *
                cacheSeconds)
            .toString();
    final configUrl = Uri.parse('$_url/config').replace(
      queryParameters: queryParams,
    );
    final response = await http.get(configUrl);
    if (response.statusCode == 200) {
      _receiveAllConfig(configData: jsonDecode(response.body), partial: false);
    } else {
      throw Exception('Invalid config status ${response.statusCode}');
    }
  }

  Future<void> connect() async {
    _userId = _userId ?? await _storage.read(key: 'orbUserId');
    _threadId = _threadId ??
        await _storage.read(key: 'orbThreadId') ??
        OrbUtil.generateOrbIntegrationId();
    _sessionToken = await _storage.read(key: 'orbSessionToken');

    final Map<String, dynamic> queryParams = {};
    if (_userId != null) {
      queryParams['user_id'] = _userId!;
    }
    queryParams['thread_id'] = _threadId;
    if (_sessionToken != null) {
      queryParams['session_token'] = _sessionToken!;
    }
    if (_magicLinkId != null && _firstConnect) {
      queryParams['magic_link_id'] = _magicLinkId!;
    }
    queryParams['version'] = await version();
    final socketUrl = Uri.parse(_url).replace(
      scheme: 'wss',
      queryParameters: queryParams,
    );

    _channel = IOWebSocketChannel.connect(socketUrl.toString());
    _connected = false;
    _reconnectOnSocketClose = true;

    final timeoutInterval = _getTimeoutInterval();
    _timer = Timer(timeoutInterval, () {
      log('TIMEOUT $timeoutInterval');
      _channel!.sink.close();
    });

    log('Listening $_channel');
    _channel!.stream.listen(
      (streamEvent) {
        final Map<dynamic, dynamic> wsEntry = deserialize(streamEvent);
        final Map<dynamic, dynamic> wsEntryData = wsEntry['data'];
        if (wsEntry['type'] == 'meya.orb.entry.ws.connected_request') {
          _timer?.cancel();
          final gridVersion = wsEntryData['grid_version'];
          log('CONNECTED grid-v$gridVersion');
          _eventEmitter.emit('connected', {});

          _gridUserId = wsEntryData['grid_user_id'];
          _userId = wsEntryData['user_id'];
          _sessionToken = wsEntryData['session_token'];

          _storage
            ..write(key: 'orbUserId', value: _userId)
            ..write(key: 'orbThreadId', value: _threadId)
            ..write(key: 'orbSessionToken', value: _sessionToken);

          final List<OrbEvent> historyEvents =
              (wsEntryData['history_events'] as List<dynamic>? ?? [])
                  .map<OrbEvent>((eventMap) => OrbEvent.fromEventMap(eventMap))
                  .toList();
          final historyUserData = (wsEntryData['history_user_data']
                      as Map<dynamic, dynamic>? ??
                  {})
              .map((key, value) => MapEntry(key, OrbUserData.fromMap(value)))
              .cast<String, OrbUserData>();

          _connected = true;

          if (_deviceToken != null) {
            publishEvent(
              OrbEvent.createDeviceConnectEvent(
                deviceId: _deviceId,
                deviceToken: _deviceToken,
                deviceState: deviceState,
              ),
            );
          }

          final heartbeatIntervalSeconds =
              wsEntryData['heartbeat_interval_seconds'];
          _startHeartbeat(heartbeatIntervalSeconds);

          final firstConnect = _firstConnect;
          if (firstConnect) {
            _firstConnect = false;
            final onFirstConnect = _onFirstConnect ?? (data, next) => next();
            onFirstConnect(
              wsEntryData,
              () => _onBaseFirstConnect(wsEntryData),
            );
          }

          _receiveAllConfig(
            configData: wsEntryData['config'] ?? {},
            partial: false,
          );
          _receiveAllEvents(
            receiveBuffer: historyEvents,
            userData: historyUserData,
            emit: () => _eventEmitter.emit(
              firstConnect ? 'firstConnect' : 'reconnect',
              {#eventStream: _eventStream},
            ),
          );
        } else if (wsEntry['type'] == 'meya.orb.entry.ws.config_request') {
          _receiveAllConfig(
            configData: {wsEntryData['key']: wsEntryData['value']},
            partial: true,
          );
        } else if (wsEntry['type'] == 'meya.orb.entry.ws.publish_request') {
          final eventMap = wsEntryData['event'];
          final event = OrbEvent.fromEventMap(eventMap);
          final userData = (wsEntryData['user_data']
                      as Map<dynamic, dynamic>? ??
                  {})
              .map((key, value) => MapEntry(key, OrbUserData.fromMap(value)))
              .cast<String, OrbUserData>();

          _receiveAllEvents(
            receiveBuffer: [event],
            userData: <String, OrbUserData>{
              ..._eventStream.userData,
              ...userData,
            },
            emit: () => _eventEmitter.emit(
              'event',
              {#event: event, #eventStream: _eventStream},
            ),
          );
        }
      },
      onDone: () {
        log('DONE');
        _timer?.cancel();
        _heartbeatTimer?.cancel();
        _connected = false;
        _reconnect();
      },
      onError: (error, stackTrace) {
        log('ERROR $error');
        _timer?.cancel();
        _heartbeatTimer?.cancel();
      },
    );
  }

  void disconnect({bool logOut = false}) {
    if (logOut) {
      _gridUserId = null;
      _userId = null;
      _threadId = _initialThreadId;
      _sessionToken = null;
      _magicLinkId = null;
      _storage.deleteAll();
      _firstConnect = true;
      _configData = null;
      _eventStream = OrbEventStream();
      _eventEmitter.emit('eventStream', {#eventStream: _eventStream});
    }
    _reconnectOnSocketClose = false;
    _retries = 0;
    _timer?.cancel();
    _heartbeatTimer?.cancel();
    _channel?.sink.close();
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
        'thread_id': _threadId,
      }
    };
    _channel?.sink.add(serialize(payloadMap));
  }

  Map<dynamic, dynamic>? getConfigData() {
    return _configData;
  }

  OrbEventStream getEventStream() {
    return _eventStream;
  }

  void setMediaUpload(OrbMediaUploadConfigResult mediaUpload) {
    _mediaUpload = mediaUpload;
  }

  void _onBaseFirstConnect(Map<dynamic, dynamic> connectData) {
    publishEvent(
      OrbEvent.createPageOpenEvent(
        _pageUrl,
        _referrer,
        pageContext: _pageContext,
      ),
    );
    if (connectData.containsKey('magic_link_event')) {
      publishEvent(OrbEvent.fromEventMap(connectData['magic_link_event']));
    }
  }

  void _startHeartbeat(int? heartbeatIntervalSeconds) {
    _heartbeatTimer?.cancel();
    if (heartbeatIntervalSeconds != null && heartbeatIntervalSeconds >= 5) {
      _heartbeatTimer = Timer.periodic(
        Duration(seconds: heartbeatIntervalSeconds),
        (timer) {
          if (deviceState != AppLifecycleState.resumed) {
            return;
          }
          log('HEARTBEAT $_deviceId');
          publishEvent(
            OrbEvent.createDeviceHeartbeatEvent(
              deviceId: _deviceId,
            ),
          );
        },
      );
    }
  }

  void _reconnect() async {
    final retryInterval = _getRetryTimeoutInterval();
    log('RETRYING $_retries $retryInterval');
    await Future.delayed(retryInterval);

    if (!_reconnectOnSocketClose) {
      log('Retry cancelled.');
      return;
    }

    _retries++;
    connect();
  }

  Duration _getTimeoutInterval() => const Duration(milliseconds: 3000);

  Duration _getRetryTimeoutInterval() {
    const base = 10;
    final variance = math.Random().nextDouble() * 0.2 + 0.9;
    final backoff = math.pow(2, _retries);
    return Duration(
      milliseconds: (base * variance * backoff).toInt(),
    );
  }

  void _receiveAllConfig({
    required Map<dynamic, dynamic> configData,
    required bool partial,
  }) {
    if (!partial) {
      _configData = configData;
    } else if (_configData != null) {
      _configData = {
        ..._configData!,
        ...configData,
      };
    } else {
      return;
    }
    _eventEmitter.emit('config', {#configData: _configData!});
  }

  void _receiveAllEvents({
    required List<OrbEvent> receiveBuffer,
    required Map<String, OrbUserData> userData,
    required void Function() emit,
  }) {
    final newEventStream = OrbEventStream(
      gridUserId: _gridUserId,
      events: [...receiveBuffer, ..._eventStream.events],
      userData: <String, OrbUserData>{
        ..._eventStream.userData,
        ...userData,
      },
    );
    if (newEventStream.events.length != _eventStream.events.length) {
      _eventStream = newEventStream;
      _eventEmitter.emit('eventStream', {#eventStream: _eventStream});
      emit();
    }
  }

  Future<Uri> postBlob(File blob, {String? mimeType}) async {
    mimeType ??= lookupMimeType(blob.path);
    final body = await blob.readAsBytes();

    final response = await http.post(
      Uri.parse(_blobUrl),
      headers: {
        'Content-Type': mimeType!,
      },
      body: body,
    );
    if (response.statusCode != 201) {
      throw Exception('Upload error');
    }
    final blobId = response.body;
    return Uri.parse('$_blobUrl/$blobId');
  }

  Future<void> postBlobAndPublishEvent(File blob) async {
    final mimeType = lookupMimeType(blob.path);
    OrbEvent event;
    if (mimeType != null && mimeType.startsWith('image/')) {
      if (!_mediaUpload.image) {
        return;
      }
      final url = await postBlob(blob);
      event = OrbEvent.createImageEvent(url.toString(), p.basename(blob.path));
    } else {
      if (!_mediaUpload.file) {
        return;
      }
      final url = await postBlob(blob);
      event = OrbEvent.createFileEvent(url.toString(), p.basename(blob.path));
    }
    publishEvent(event);
  }

  void closeUi() => _eventEmitter.emit('closeUi', {});
}

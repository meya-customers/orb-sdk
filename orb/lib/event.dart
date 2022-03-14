import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

class OrbEvent implements Comparable<OrbEvent> {
  String? id;
  String type;
  Map<dynamic, dynamic> data;
  bool showAvatar = false;
  bool isFirstInGroup = false;

  OrbEvent({this.id, required this.type, required this.data});

  @override
  int compareTo(OrbEvent other) {
    final _id = id!.split('-');
    final _ts = int.parse(_id[0]);
    final _seq = int.parse(_id[1]);
    final _otherId = other.id!.split('-');
    final _otherTs = int.parse(_otherId[0]);
    final _otherSeq = int.parse(_otherId[1]);
    if (_ts < _otherTs) {
      return -1;
    } else if (_ts > _otherTs) {
      return 1;
    } else {
      if (_seq < _otherSeq) {
        return -1;
      } else if (_seq > _otherSeq) {
        return 1;
      } else {
        return 0;
      }
    }
  }

  @override
  String toString() {
    return 'Event($id, $type, $data)';
  }

  Map<String, dynamic> toEventMap() => {
        'id': id,
        'type': type,
        'data': data,
      };

  factory OrbEvent.fromEventMap(Map<dynamic, dynamic>? eventMap) {
    if (eventMap == null)
      throw Exception('Cannot create an OrbEvent from \'null\'.');
    if (eventMap['type'] == null)
      throw Exception('Cannot create an OrbEvent with an empty \'type\'.');
    return OrbEvent(
      id: eventMap['id'],
      type: eventMap['type'],
      data: eventMap['data'],
    );
  }

  factory OrbEvent.createDeviceConnectEvent({
    String? deviceId,
    String? deviceToken,
    AppLifecycleState? deviceState,
  }) {
    String platform = 'unsupported';
    if (Platform.isAndroid) {
      platform = 'android';
    } else if (Platform.isIOS) {
      platform = 'ios';
    }
    return OrbEvent(
      type: 'meya.orb.event.device.connect',
      data: {
        'device_id': deviceId,
        'key': 'state',
        'value': deviceState.state,
        'device_token': deviceToken,
        'state': deviceState.state,
        'platform': platform,
      },
    );
  }

  factory OrbEvent.createDeviceStateEvent({
    String? deviceId,
    AppLifecycleState? deviceState,
  }) {
    return OrbEvent(
      type: 'meya.orb.event.device.state',
      data: {
        'device_id': deviceId,
        'key': 'state',
        'value': deviceState.state,
        'state': deviceState.state,
      },
    );
  }

  factory OrbEvent.createDeviceHeartbeatEvent({
    String? deviceId,
  }) {
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    return OrbEvent(
      type: 'meya.orb.event.device.heartbeat',
      data: {
        'device_id': deviceId,
        'key': 'timestamp',
        'value': timestamp,
        'timestamp': timestamp,
      },
    );
  }

  factory OrbEvent.createSayEvent(String? text,
      {Map<dynamic, dynamic>? context}) {
    return OrbEvent(
      type: 'meya.text.event.say',
      data: {
        'context': context ?? {},
        'text': text,
      },
    );
  }

  factory OrbEvent.createButtonClickEvent(
    String buttonId, {
    String? text,
    Map<dynamic, dynamic>? context,
  }) {
    return OrbEvent(
      type: 'meya.button.event.click',
      data: {
        'context': context ?? {},
        'button_id': buttonId,
        'text': text,
      },
    );
  }

  factory OrbEvent.createPageButtonClickEvent(
    String pageId,
    String buttonId,
    List<dynamic> inputData, {
    String? text,
    Map<dynamic, dynamic>? context,
  }) {
    return OrbEvent(
      type: 'meya.widget.event.page.button_click',
      data: {
        'context': context ?? {},
        'page_id': pageId,
        'button_id': buttonId,
        'input_data': inputData,
        'text': text,
      },
    );
  }

  factory OrbEvent.createFieldButtonClickEvent(
    String fieldId,
    String buttonId,
    dynamic inputData, {
    String? text,
    Map<dynamic, dynamic>? context,
  }) {
    return OrbEvent(
      type: 'meya.widget.event.field.button_click',
      data: {
        'context': context ?? {},
        'field_id': fieldId,
        'button_id': buttonId,
        'input_data': inputData,
        'text': text,
      },
    );
  }

  factory OrbEvent.createPageOpenEvent(
    String? url,
    String? referrer,
    bool? magicLinkOk,
    Map<dynamic, dynamic>? pageContext,
  ) {
    return OrbEvent(
      type: 'meya.session.event.page.open',
      data: {
        'context': pageContext ?? {},
        'magic_link_ok': magicLinkOk,
        'referrer': referrer,
        'url': url ?? 'https://meya.ai/orb',
      },
    );
  }

  factory OrbEvent.createImageEvent(String url, String filename) {
    return OrbEvent(
      type: 'meya.image.event',
      data: {
        'url': url,
        'filename': filename,
      },
    );
  }

  factory OrbEvent.createFileEvent(String url, String filename) {
    return OrbEvent(
      type: 'meya.file.event',
      data: {
        'url': url,
        'filename': filename,
      },
    );
  }

  factory OrbEvent.createFormSubmitEvent(
      String? formId, Map<String?, String> fields) {
    return OrbEvent(
        type: 'meya.form.event.submit',
        data: {'fields': fields, 'form_id': formId});
  }
}

enum ComposerFocus { file, image, text, blur }

extension ComposerFocusExtension on ComposerFocus {
  static ComposerFocus fromString(String? focus) {
    switch (focus) {
      case 'file':
        return ComposerFocus.file;
      case 'image':
        return ComposerFocus.image;
      case 'blur':
        return ComposerFocus.blur;
      default:
        return ComposerFocus.text;
    }
  }
}

enum ComposerVisibility { collapse, hide, show }

extension ComposerVisibilityExtension on ComposerVisibility {
  static ComposerVisibility fromString(String? focus) {
    switch (focus) {
      case 'collapse':
        return ComposerVisibility.collapse;
      case 'hide':
        return ComposerVisibility.hide;
      default:
        return ComposerVisibility.show;
    }
  }
}

class ComposerEventSpec {
  final ComposerFocus? focus;
  final String? placeholder;
  final ComposerVisibility? visibility;

  ComposerEventSpec({this.focus, this.placeholder, this.visibility});

  static ComposerEventSpec? fromMap(Map? map) {
    if (map == null) return null;
    return ComposerEventSpec(
      focus: ComposerFocusExtension.fromString(map['focus']),
      placeholder: map['placeholder'],
      visibility: ComposerVisibilityExtension.fromString(map['visibility']),
    );
  }
}

extension DeviceState on AppLifecycleState? {
  String? get state {
    switch (this) {
      case AppLifecycleState.resumed:
        return "resumed";
      case AppLifecycleState.inactive:
        return "inactive";
      case AppLifecycleState.paused:
        return "paused";
      case AppLifecycleState.detached:
        return "detached";
      default:
        return null;
    }
  }
}

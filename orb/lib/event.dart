import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:orb/ui/icon.dart';

class OrbEvent implements Comparable<OrbEvent> {
  String? id;
  String type;
  Map<dynamic, dynamic> data;
  bool showAvatar = false;
  bool isFirstInGroup = false;

  OrbEvent({required this.type, required this.data, this.id});

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

  factory OrbEvent.fromEventMap(Map<dynamic, dynamic> eventMap) {
    if (eventMap['type'] == null) {
      throw Exception('Cannot create an OrbEvent with an empty \'type\'.');
    }
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

  factory OrbEvent.createSayEvent(
    String? text, {
    Map<dynamic, dynamic>? context,
  }) {
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
    String? referrer, {
    bool? magicLinkOk,
    Map<dynamic, dynamic>? pageContext,
  }) {
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
    String? formId,
    Map<String?, String> fields,
  ) {
    return OrbEvent(
      type: 'meya.form.event.submit',
      data: {'fields': fields, 'form_id': formId},
    );
  }
}

enum OrbComposerFocus { file, image, text, blur }

extension OrbComposerFocusExtension on OrbComposerFocus {
  static OrbComposerFocus? fromString(String? focus) {
    switch (focus) {
      case 'file':
        return OrbComposerFocus.file;
      case 'image':
        return OrbComposerFocus.image;
      case 'blur':
        return OrbComposerFocus.blur;
      case 'text':
        return OrbComposerFocus.text;
      default:
        return null;
    }
  }
}

enum OrbComposerVisibility { collapse, hide, show }

extension OrbComposerVisibilityExtension on OrbComposerVisibility {
  static OrbComposerVisibility? fromString(String? visibility) {
    switch (visibility) {
      case 'collapse':
        return OrbComposerVisibility.collapse;
      case 'hide':
        return OrbComposerVisibility.hide;
      case 'show':
        return OrbComposerVisibility.show;
      default:
        return null;
    }
  }
}

class OrbComposerEventSpec {
  final OrbComposerFocus? focus;
  final String? placeholder;
  final String? collapsePlaceholder;
  final OrbComposerVisibility? visibility;

  const OrbComposerEventSpec({
    this.focus,
    this.placeholder,
    this.collapsePlaceholder,
    this.visibility,
  });

  static OrbComposerEventSpec? fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return OrbComposerEventSpec(
      focus: OrbComposerFocusExtension.fromString(map['focus']),
      placeholder: map['placeholder'],
      collapsePlaceholder: map['collapsePlaceholder'],
      visibility: OrbComposerVisibilityExtension.fromString(map['visibility']),
    );
  }
}

class OrbHeaderTitleEventSpec {
  final OrbIconSpec? icon;
  final String? text;

  const OrbHeaderTitleEventSpec({
    this.icon,
    this.text,
  });

  static OrbHeaderTitleEventSpec? fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return OrbHeaderTitleEventSpec(
      icon: OrbIconSpec.fromMap(map['icon']),
      text: map['text'],
    );
  }
}

class OrbHeaderProgressEventSpec {
  final num? value;
  final bool? showPercent;

  const OrbHeaderProgressEventSpec({
    this.value,
    this.showPercent = false,
  });

  static OrbHeaderProgressEventSpec? fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return OrbHeaderProgressEventSpec(
      value: map['value'],
      showPercent: map['show_percent'],
    );
  }
}

class OrbHeaderEventSpec {
  final List<dynamic>? buttons;
  final OrbHeaderTitleEventSpec? title;
  final OrbHeaderProgressEventSpec? progress;
  final List<dynamic>? milestones;
  final List<dynamic>? extraButtons;

  const OrbHeaderEventSpec({
    this.buttons,
    this.title,
    this.progress,
    this.milestones,
    this.extraButtons,
  });

  static OrbHeaderEventSpec? fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return OrbHeaderEventSpec(
      buttons: map['buttons'],
      title: OrbHeaderTitleEventSpec.fromMap(map['title']),
      progress: OrbHeaderProgressEventSpec.fromMap(map['progress']),
      milestones: map['milestones'],
      extraButtons: map['extra_buttons'],
    );
  }
}

extension OrbDeviceState on AppLifecycleState? {
  String? get state {
    switch (this) {
      case AppLifecycleState.resumed:
        return 'resumed';
      case AppLifecycleState.inactive:
        return 'inactive';
      case AppLifecycleState.paused:
        return 'paused';
      case AppLifecycleState.detached:
        return 'detached';
      default:
        return null;
    }
  }
}

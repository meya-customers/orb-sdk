import 'package:meta/meta.dart';

import 'package:orb/event.dart';
import 'package:orb/ui/avatar.dart';
import 'package:orb/ui/card/event_map.dart';

class OrbEventStream {
  final List<OrbEvent> events;
  final bool Function(OrbEvent event) isSelfEvent;
  final bool Function(OrbEvent event) isHiddenEvent;
  final bool Function(OrbEvent event) isActiveEvent;
  final String Function(OrbEvent event) getEventText;
  final bool Function(OrbEvent event) isAttributionEvent;
  final OrbEvent quickRepliesEvent;
  final Map<String, OrbUserData> userData;
  final Map<String, bool> buttonClicks;
  final Map<String, OrbFormView> forms;

  OrbEventStream._({
    @required this.events,
    @required this.isSelfEvent,
    @required this.isHiddenEvent,
    @required this.isActiveEvent,
    @required this.getEventText,
    @required this.isAttributionEvent,
    @required this.quickRepliesEvent,
    @required this.userData,
    @required this.buttonClicks,
    @required this.forms,
  });

  factory OrbEventStream({
    String gridUserId,
    List<OrbEvent> events = const [],
    Map<String, OrbUserData> userData = const {},
  }) {
    final isSelfEvent = _createIsSelfEvent(gridUserId);
    final isHiddenEvent = _createIsHiddenEvent();
    final isActiveEvent = _createIsActiveEvent(events);
    final getEventText = _createGetEventText(events);
    final isAttributionEvent = _createIsAttributionEvent();
    final quickRepliesEvent = _createQuickRepliesEvent(events, isHiddenEvent);
    final buttonClicks = _createButtonClicks(events);
    final forms = _createForms(events);
    final eventStream = OrbEventStream._(
      events: _sortAndRemoveDuplicates(events),
      isSelfEvent: isSelfEvent,
      isHiddenEvent: isHiddenEvent,
      isActiveEvent: isActiveEvent,
      getEventText: getEventText,
      isAttributionEvent: isAttributionEvent,
      quickRepliesEvent: quickRepliesEvent,
      userData: userData,
      buttonClicks: buttonClicks,
      forms: forms,
    );
    return eventStream.preProcessEvents();
  }

  static List<OrbEvent> _sortAndRemoveDuplicates(List<OrbEvent> events) {
    var sortedEvents = events.toList();
    sortedEvents.sort((a, b) => b.compareTo(a));
    final ids = sortedEvents.map((e) => e.id).toSet();
    sortedEvents.retainWhere((e) => ids.remove(e.id));
    return sortedEvents;
  }

  OrbEventStream preProcessEvents() {
    String otherUserId;
    List<OrbEvent> newEvents = [];
    int count = 0;
    for (final event in events) {
      if (event.type == 'virtual.orb.event.user_name') continue;
      final eventClass = EventMap[event.type];
      final text = getEventText(event);
      final isVisible = eventClass != null || text != null;
      final isHidden = isHiddenEvent(event);
      final isSelfEvent = this.isSelfEvent(event);
      final isAttributionEvent = this.isAttributionEvent(event);
      final userId = event.data['user_id'];
      event.showAvatar = false;
      event.isFirstInGroup = false;

      if ((isVisible && isSelfEvent) || !isAttributionEvent || isHidden) {
        if (newEvents.isNotEmpty) newEvents.last.isFirstInGroup = true;
        if (isAttributionEvent) {
          final userNameEvent = OrbEvent.createVirtualUserNameEvent(
            '$count-0',
            otherUserId ?? userId,
          );
          newEvents.add(userNameEvent);
        }
        otherUserId = null;
      } else if (isVisible) {
        if (userId != otherUserId) {
          if (otherUserId != null) {
            final userNameEvent =
                OrbEvent.createVirtualUserNameEvent('$count-0', otherUserId);
            newEvents.add(userNameEvent);
          }
          event.showAvatar = true;
          event.isLastInGroup = true;
          otherUserId = userId;
        }
      }
      newEvents.add(event);
      count++;
    }
    return OrbEventStream._(
      events: newEvents,
      isSelfEvent: isSelfEvent,
      isHiddenEvent: isHiddenEvent,
      isActiveEvent: isActiveEvent,
      getEventText: getEventText,
      isAttributionEvent: isAttributionEvent,
      quickRepliesEvent: quickRepliesEvent,
      userData: userData,
      buttonClicks: buttonClicks,
      forms: forms,
    );
  }

  List<Map<String, dynamic>> get rawEvents =>
      events.map((e) => e.toEventMap()).toList();

  static bool Function(OrbEvent event) _createIsSelfEvent(String gridUserId) {
    return (OrbEvent event) =>
        gridUserId != '' && event.data['user_id'] == gridUserId;
  }

  static bool Function(OrbEvent event) _createIsHiddenEvent() {
    return (event) =>
        ['meya.button.event.click', 'meya.form.event.ok'].contains(event.type);
  }

  static bool Function(OrbEvent) _createIsActiveEvent(List<OrbEvent> events) {
    String activeId;
    for (final event in events) {
      if (![
        'meya.session.event.chat.close',
        'meya.analytics.event.identify',
        'meya.session.event.chat.open',
        'meya.session.event.page.open',
        'meya.orb.event.screen.continue',
        'meya.orb.event.screen.end',
        'meya.orb.event.device',
        'meya.orb.event.device.heartbeat',
        'meya.analytics.event.track',
        'meya.directly.event.webhook',
        'meya.presence.event.typing.on',
        'meya.presence.event.typing.off',
      ].contains(event.type)) {
        activeId = event.id;
        break;
      }
    }
    return (OrbEvent event) => event.id == activeId;
  }

  static String Function(OrbEvent) _createGetEventText(List<OrbEvent> events) {
    final quickReplyButtons = {};
    for (final event in events) {
      final quickReplies = event.data['quick_replies'];
      if (quickReplies != null) {
        for (final button in quickReplies) {
          if (button.containsKey('button_id') != null) {
            quickReplyButtons[button['button_id']] = button['text'];
          }
        }
      }
    }
    return (OrbEvent event) {
      if (event.type == 'meya.button.event.click') {
        return quickReplyButtons[event.data['button_id']];
      } else {
        return event.data['text'];
      }
    };
  }

  static bool Function(OrbEvent) _createIsAttributionEvent() {
    return (OrbEvent event) => !['meya.text.event.status'].contains(event.type);
  }

  static OrbEvent _createQuickRepliesEvent(
    List<OrbEvent> events,
    bool Function(OrbEvent event) isHiddenEvent,
  ) {
    for (final event in events) {
      final quickReplies = event.data['quick_replies'];
      if (isHiddenEvent(event)) {
        break;
      } else if (quickReplies != null) {
        return event;
      }
    }
    return null;
  }

  static Map<String, bool> _createButtonClicks(List<OrbEvent> events) {
    final Map<String, bool> buttonClicks = {};
    for (final event in events) {
      if (event.type == 'meya.button.event.click') {
        buttonClicks[event.data['button_id']] = true;
      }
    }
    return buttonClicks;
  }

  static Map<String, OrbFormView> _createForms(List<OrbEvent> events) {
    final Map<String, OrbFormView> forms = {};
    for (final event in events.reversed) {
      if (event.type == 'meya.form.event.ask') {
        forms[event.data['form_id']] = OrbFormView(askEvent: event);
      } else {
        final OrbFormView formView = forms[event.data['form_id']];
        if (event.type == 'meya.form.event.submit') {
          formView?.submitEvent = event;
        } else if (event.type == 'meya.form.event.error') {
          formView?.errorEvent = event;
        } else if (event.type == 'meya.form.event.ok') {
          formView?.okEvent = event;
        }
      }
    }
    return forms;
  }
}

enum OrbUserType { bot, agent, user, system }

extension OrbUserTypeExtension on OrbUserType {
  static OrbUserType fromString(String type) =>
      {
        'bot': OrbUserType.bot,
        'agent': OrbUserType.agent,
        'user': OrbUserType.user,
        'system': OrbUserType.system
      }[type] ??
      OrbUserType.bot;
}

class OrbUserData {
  final String name;
  final OrbAvatar avatar;
  final OrbUserType type;

  OrbUserData({
    @required this.name,
    @required this.avatar,
    @required this.type,
  });

  factory OrbUserData.fromMap(Map<dynamic, dynamic> map) {
    return OrbUserData(
      name: map['name'],
      avatar: OrbAvatar.fromMap(map['avatar']),
      type: OrbUserTypeExtension.fromString(map['type']),
    );
  }
}

class OrbFormView {
  OrbEvent askEvent;
  OrbEvent submitEvent;
  OrbEvent errorEvent;
  OrbEvent okEvent;

  OrbFormView({
    @required this.askEvent,
    this.submitEvent,
    this.errorEvent,
    this.okEvent,
  });
}

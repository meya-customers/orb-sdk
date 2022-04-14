import 'package:orb/event.dart';
import 'package:orb/ui/avatar.dart';
import 'package:orb/ui/card/ask_buttons.dart';
import 'package:orb/ui/card/ask_form.dart';
import 'package:orb/ui/card/ask_tiles.dart';
import 'package:orb/ui/card/choice_input.dart';
import 'package:orb/ui/card/file.dart';
import 'package:orb/ui/card/image.dart';
import 'package:orb/ui/card/rating.dart';
import 'package:orb/ui/card/status.dart';
import 'package:orb/ui/card/text_input.dart';
import 'package:orb/ui/page.dart';

class OrbEventStream {
  final List<OrbEvent> events;
  final Map<String, OrbUserData> userData;
  final bool Function(OrbEvent event) isActiveEvent;
  final bool Function(OrbEvent event) isSelfEvent;
  final bool Function(OrbEvent event) isHiddenEvent;
  final bool Function(OrbEvent event) isVisibleEvent;
  final bool Function(OrbEvent event) isInvisibleEvent;
  final bool Function(OrbEvent event) isAttributionEvent;
  final String? Function(OrbEvent event) getEventText;
  final Map<String, bool> buttonClicks;
  final Map<String, OrbFormView> forms;
  final Map<String, OrbEvent> fieldEvents;
  final OrbEvent? quickRepliesEvent;
  final OrbEvent? typingOnEvent;
  final OrbEvent? pageEvent;

  OrbEventStream._({
    required this.events,
    required this.userData,
    required this.isActiveEvent,
    required this.isSelfEvent,
    required this.isHiddenEvent,
    required this.isVisibleEvent,
    required this.isInvisibleEvent,
    required this.isAttributionEvent,
    required this.getEventText,
    required this.buttonClicks,
    required this.forms,
    required this.fieldEvents,
    required this.quickRepliesEvent,
    required this.typingOnEvent,
    required this.pageEvent,
  });

  factory OrbEventStream({
    String? gridUserId,
    List<OrbEvent> events = const [],
    Map<String, OrbUserData> userData = const {},
  }) {
    events = _sortAndRemoveDuplicates(events);
    final isSelfEvent = _createIsSelfEvent(gridUserId);
    final getEventText = _createGetEventText(events);
    final isHiddenEvent = _createIsHiddenEvent();
    final fieldEvents = _createFieldEvents(events);
    final isInvisibleEvent = _createIsInvisibleEvent();
    final isActiveEvent = _createIsActiveEvent(events, isInvisibleEvent);
    final isVisibleEvent =
        _createIsVisibleEvent(getEventText, fieldEvents, isActiveEvent);
    final isAttributionEvent = _createIsAttributionEvent();
    final quickRepliesEvent = _createQuickRepliesEvent(events);
    final typingOnEvent =
        _createTypingOnEvent(events, isInvisibleEvent, isSelfEvent);
    final pageEvent = _createPageEvent(events, isHiddenEvent, isInvisibleEvent);
    final buttonClicks = _createButtonClicks(events);
    final forms = _createForms(events);
    final eventStream = OrbEventStream._(
      events: events,
      userData: userData,
      isActiveEvent: isActiveEvent,
      isSelfEvent: isSelfEvent,
      isHiddenEvent: isHiddenEvent,
      isVisibleEvent: isVisibleEvent,
      isInvisibleEvent: isInvisibleEvent,
      isAttributionEvent: isAttributionEvent,
      getEventText: getEventText,
      buttonClicks: buttonClicks,
      forms: forms,
      fieldEvents: fieldEvents,
      quickRepliesEvent: quickRepliesEvent,
      typingOnEvent: typingOnEvent,
      pageEvent: pageEvent,
    );
    eventStream.preProcessEvents();
    return eventStream;
  }

  static List<OrbEvent> _sortAndRemoveDuplicates(List<OrbEvent> events) {
    final sortedEvents = events.toList();
    sortedEvents.sort((a, b) => b.compareTo(a));
    final ids = sortedEvents.map((e) => e.id).toSet();
    sortedEvents.retainWhere((e) => ids.remove(e.id));
    return sortedEvents;
  }

  void preProcessEvents() {
    String? otherUserId;
    OrbEvent? otherUserEvent;
    for (final event in events) {
      final isVisible = isVisibleEvent(event);
      final isSelfEvent = this.isSelfEvent(event);
      final isAttributionEvent = this.isAttributionEvent(event);
      final String userId = event.data['user_id'];
      event.showAvatar = false;
      event.isFirstInGroup = false;

      if ((isVisible && isSelfEvent) || !isAttributionEvent) {
        if (otherUserEvent != null) {
          otherUserEvent.isFirstInGroup = true;
        }
        otherUserId = null;
        otherUserEvent = null;
      } else if (isVisible) {
        if (userId != otherUserId) {
          event.isFirstInGroup = true;
          event.showAvatar = true;
          otherUserId = userId;
        } else {
          otherUserEvent!.isFirstInGroup = false;
          event.isFirstInGroup = true;
        }
        otherUserEvent = event;
      }
    }
  }

  List<Map<String, dynamic>> get rawEvents =>
      events.map((e) => e.toEventMap()).toList();

  static bool Function(OrbEvent event) _createIsSelfEvent(String? gridUserId) {
    return (event) => gridUserId != '' && event.data['user_id'] == gridUserId;
  }

  static bool Function(OrbEvent event) _createIsHiddenEvent() {
    return (event) => [
          'meya.button.event.click',
          'meya.form.event.ok',
          'meya.widget.event.field.button_click',
          'meya.widget.event.page.button_click',
          'meya.widget.event.page'
        ].contains(event.type);
  }

  static bool Function(OrbEvent event) _createIsVisibleEvent(
    String? Function(OrbEvent event) getEventText,
    Map<String, OrbEvent> fieldEvents,
    bool Function(OrbEvent event) isActiveEvent,
  ) {
    return (event) {
      switch (event.type) {
        case 'meya.button.event.ask':
          return OrbAskButtons.isVisible(event);
        case 'meya.file.event':
          return OrbFile.isVisible(event);
        case 'meya.form.event.ask':
          return OrbAskForm.isVisible(event);
        case 'meya.image.event':
          return OrbImage.isVisible(event);
        case 'meya.orb.event.hero':
          return true;
        case 'meya.text.event.info':
          return true;
        case 'meya.text.event.input':
          return OrbTextInput.isVisible(event, fieldEvents);
        case 'meya.text.event.status':
          return OrbStatus.isVisible(event, isActiveEvent);
        case 'meya.tile.event.ask':
          return OrbAskTiles.isVisible(event);
        case 'meya.tile.event.choice':
          return OrbChoiceInput.isVisible(event, fieldEvents);
        case 'meya.tile.event.rating':
          return OrbRating.isVisible(event);
        default:
          return (getEventText(event) ?? '') != '';
      }
    };
  }

  static bool Function(OrbEvent event) _createIsInvisibleEvent() {
    return (event) => [
          'meya.analytics.event.identify',
          'meya.analytics.event.track',
          'meya.orb.event.device',
          'meya.orb.event.device.heartbeat',
          'meya.orb.event.screen.continue',
          'meya.orb.event.screen.end',
          'meya.presence.event.typing.off',
          'meya.presence.event.typing.on',
          'meya.session.event.chat.close',
          'meya.session.event.chat.open',
          'meya.session.event.page.open',
        ].contains(event.type);
  }

  static bool Function(OrbEvent) _createIsActiveEvent(
    List<OrbEvent> events,
    bool Function(OrbEvent event) isInvisibleEvent,
  ) {
    String? activeId;
    for (final event in events) {
      final isInvisible = isInvisibleEvent(event);
      if (!isInvisible) {
        activeId = event.id;
        break;
      }
    }
    return (event) => event.id == activeId;
  }

  static String? Function(OrbEvent) _createGetEventText(List<OrbEvent> events) {
    final quickReplyButtons = {};
    var firstQuickReplies = true;
    for (final event in events) {
      final quickReplies = event.data['quick_replies'];
      if (quickReplies != null) {
        if (firstQuickReplies) {
          firstQuickReplies = false;
        } else {
          for (final Map<dynamic, dynamic> button in quickReplies) {
            if (button.containsKey('button_id')) {
              quickReplyButtons[button['button_id']] = button['text'];
            }
          }
        }
      }
    }
    return (event) {
      if ([
        'meya.button.event.click',
        'meya.widget.event.field.button_click',
        'meya.widget.event.page.button_click'
      ].contains(event.type)) {
        return quickReplyButtons[event.data['button_id']];
      } else {
        return event.data['text'];
      }
    };
  }

  static bool Function(OrbEvent) _createIsAttributionEvent() {
    return (event) => !['meya.text.event.info', 'meya.text.event.status']
        .contains(event.type);
  }

  static OrbEvent? _createQuickRepliesEvent(List<OrbEvent> events) {
    for (final event in events) {
      final List? quickReplies = event.data['quick_replies'];
      if (quickReplies != null) {
        return event;
      }
    }
    return null;
  }

  static OrbEvent? _createTypingOnEvent(
    List<OrbEvent> events,
    bool Function(OrbEvent event) isInvisibleEvent,
    bool Function(OrbEvent event) isSelfEvent,
  ) {
    for (final event in events) {
      final isInvisible = isInvisibleEvent(event);
      final isSelf = isSelfEvent(event);
      if (!isInvisible && !isSelf) {
        break;
      } else if (event.type == 'meya.presence.event.typing.on' && !isSelf) {
        return event;
      }
    }
    return null;
  }

  static OrbEvent? _createPageEvent(
    List<OrbEvent> events,
    bool Function(OrbEvent event) isHiddenEvent,
    bool Function(OrbEvent event) isInvisibleEvent,
  ) {
    for (final event in events) {
      final isHidden = isHiddenEvent(event);
      final isInvisible = isInvisibleEvent(event);
      if (!isHidden && !isInvisible) {
        break;
      } else if (event.type == 'meya.widget.event.page') {
        if (OrbPage.isVisible(event)) {
          return event;
        } else {
          break;
        }
      }
    }
    return null;
  }

  static Map<String, bool> _createButtonClicks(List<OrbEvent> events) {
    final Map<String, bool> buttonClicks = {};
    for (final event in events) {
      if ([
        'meya.button.event.click',
        'meya.widget.event.field.button_click',
        'meya.widget.event.page.button_click'
      ].contains(event.type)) {
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
        final OrbFormView? formView = forms[event.data['form_id']];
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

  static Map<String, OrbEvent> _createFieldEvents(List<OrbEvent> events) {
    final Map<String, OrbEvent> fieldEvents = {};
    for (final event in events) {
      if (['meya.text.event.input', 'meya.tile.event.choice']
          .contains(event.type)) {
        final String fieldId = event.data['field_id'];
        if (fieldEvents[fieldId] == null) {
          fieldEvents[fieldId] = event;
        }
      }
    }
    return fieldEvents;
  }
}

enum OrbUserType { bot, agent, user, system }

extension OrbUserTypeExtension on OrbUserType {
  static OrbUserType fromString(String? type) =>
      {
        'bot': OrbUserType.bot,
        'agent': OrbUserType.agent,
        'user': OrbUserType.user,
        'system': OrbUserType.system
      }[type!] ??
      OrbUserType.bot;
}

class OrbUserData {
  final String? name;
  final OrbAvatar? avatar;
  final OrbUserType type;

  OrbUserData({
    required this.name,
    required this.avatar,
    required this.type,
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
  OrbEvent? submitEvent;
  OrbEvent? errorEvent;
  OrbEvent? okEvent;

  OrbFormView({
    required this.askEvent,
    this.submitEvent,
    this.errorEvent,
    this.okEvent,
  });
}

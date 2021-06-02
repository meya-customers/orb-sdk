import 'package:meta/meta.dart';

class OrbEvent implements Comparable<OrbEvent> {
  String id;
  String type;
  Map data;
  bool showAvatar = false;
  bool isFirstInGroup = false;
  bool isLastInGroup = false;

  OrbEvent({this.id, @required this.type, @required this.data});

  @override
  int compareTo(OrbEvent other) {
    final _id = int.parse(id.replaceFirst('-', ''));
    final _otherId = int.parse(other.id.replaceFirst('-', ''));
    if (_id < _otherId) {
      return -1;
    } else if (_id > _otherId) {
      return 1;
    } else {
      return 0;
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

  factory OrbEvent.createSayEvent(String text,
      {Map<dynamic, dynamic> context}) {
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
    String text,
    Map<dynamic, dynamic> context,
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

  factory OrbEvent.createPageOpenEvent(
    String url,
    String referrer,
    bool magicLinkOk,
    Map<dynamic, dynamic> pageContext,
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
      String formId, Map<String, String> fields) {
    return OrbEvent(
        type: 'meya.form.event.submit',
        data: {'fields': fields, 'form_id': formId});
  }

  factory OrbEvent.createVirtualUserNameEvent(String id, String userId) {
    return OrbEvent(
        id: id, type: 'virtual.orb.event.user_name', data: {'user_id': userId});
  }
}

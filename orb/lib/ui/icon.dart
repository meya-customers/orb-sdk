import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

import 'package:orb/ui/color.dart';
import 'package:orb/ui/design.dart';

const String MEYA_CDN_URL = 'https://cdn-staging.meya.ai';

class OrbIcon extends StatelessWidget {
  final OrbIconSpec src;
  Color color;

  OrbIcon(this.src, {Color color, Color defaultColor}) {
    if (src.color != null) {
      this.color = colorFromString(src.color);
    } else if (color != null) {
      this.color = color;
    } else if (defaultColor != null) {
      this.color = defaultColor;
    } else {
      this.color = OrbThemePalette().normal;
    }
  }

  static OrbIcon fromSpec(dynamic icon, {Color defaultColor}) {
    final iconSpec = OrbIconSpec.fromSpec(icon);
    if (iconSpec == null) return null;
    return OrbIcon(
      iconSpec,
      defaultColor: defaultColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!src.url.startsWith("http")) {
      return Icon(Icons.check_box_outline_blank);
    }
    return SvgPicture.network(
      src.url,
      color: color,
      placeholderBuilder: (BuildContext context) =>
          Icon(Icons.check_box_outline_blank),
    );
  }

  Color colorFromString(String color) {
    return {
          "black": Colors.black,
          "white": Colors.white,
          "red": Colors.red,
          "pink": Colors.pink,
          "purple": Colors.amber,
          "yellow": Colors.yellow,
          "blue": Colors.blue,
          "brown": Colors.brown,
          "cyan": Colors.cyan,
          "indigo": Colors.indigo,
          "green": Colors.green,
          "grey": Colors.grey,
          "teal": Colors.teal,
          "orange": Colors.orange,
          "lime": Colors.lime,
        }[color] ??
        HexColor.fromHex(color) ??
        OrbThemePalette().normal;
  }

  OrbIcon copyWith({
    OrbIconSpec src,
    Color color,
  }) {
    return OrbIcon(src ?? this.src, color: color ?? this.color);
  }
}

class OrbIconSpec {
  final String url;
  final String color;

  OrbIconSpec._({@required this.url, this.color});

  factory OrbIconSpec({
    @required String url,
    String color,
  }) {
    /*
     TODO: Unify web & mobile icons - currently flutter_svg does not support
           CSS styles.
     */
    if (url.contains(MEYA_CDN_URL) && !url.contains("orb-mobile")) {
      url = url.replaceFirst("icon", "icon/orb-mobile");
    } else if (url.startsWith("streamline")) {
      url = urlFromPath(url);
    }
    return OrbIconSpec._(url: url, color: color);
  }

  factory OrbIconSpec.buildIconSpec(String path) =>
      OrbIconSpec(url: urlFromPath(path));

  static OrbIconSpec fromMap(Map<dynamic, dynamic> icon) {
    if (icon == null || icon['url'] == null) return null;
    return OrbIconSpec(url: icon['url'], color: icon['color']);
  }

  static OrbIconSpec fromSpec(dynamic icon) {
    if (icon is Map) {
      return fromMap(icon);
    } else if (icon is String) {
      return OrbIconSpec.buildIconSpec(icon);
    } else {
      return null;
    }
  }

  static String urlFromPath(String path) =>
      '$MEYA_CDN_URL/icon/orb-mobile/${path.replaceAll(RegExp(r'\s&\s|[:\s]'), '-')}';
}

class OrbIcons {
  static OrbIconSpec check = OrbIconSpec.buildIconSpec(
      'streamline-regular/01-interface essential/33-form-validation/check-circle-1.svg');

  static OrbIconSpec expandInput = OrbIconSpec.buildIconSpec(
      'streamline-regular/21-messages-chat-smileys/02-messages-speech-bubbles/messages-bubble-edit.svg');

  static OrbIconSpec extraInput = OrbIconSpec.buildIconSpec(
      'streamline-regular/01-interface essential/43-remove:add/add-square.svg');

  static OrbIconSpec file = OrbIconSpec.buildIconSpec(
      'streamline-regular/16-files-folders/01-common-files/common-file-text.svg');

  static OrbIconSpec left = OrbIconSpec.buildIconSpec(
      'streamline-regular/52-arrows-diagrams/01-arrows/arrow-left-1.svg');

  static OrbIconSpec right = OrbIconSpec.buildIconSpec(
      'streamline-regular/52-arrows-diagrams/01-arrows/arrow-right-1.svg');

  static OrbIconSpec sendText = OrbIconSpec.buildIconSpec(
      'streamline-regular/19-emails/01-send-email/send-email-2.svg');

  static OrbIconSpec sendFile = OrbIconSpec.buildIconSpec(
      'streamline-regular/16-files-folders/01-common-files/common-file-text-add.svg');

  static OrbIconSpec sendImage = OrbIconSpec.buildIconSpec(
      'streamline-regular/13-images-photography/18-image-files/image-file-add.svg');

  static OrbIconSpec camera = OrbIconSpec.buildIconSpec(
      'streamline-regular/13-images-photography/02-cameras/camera-1.svg');

  static OrbIconSpec gallery = OrbIconSpec.buildIconSpec(
      'streamline-regular/13-images-photography/05-pictures/picture-stack-landscape.svg');

  static OrbIconSpec emailAddress = OrbIconSpec.buildIconSpec(
      'streamline-regular/19-emails/02-read-email/read-email-at.svg');

  static OrbIconSpec phone = OrbIconSpec.buildIconSpec(
      'streamline-regular/20-phones-mobile-devices/01-phone/phone.svg');

  static OrbIconSpec flag = OrbIconSpec.buildIconSpec(
      'streamline-regular/22-social-medias-rewards-rating/13-flags/flag-plain-3.svg');

  static OrbIconSpec user = OrbIconSpec.buildIconSpec(
      'streamline-regular/17-users/10-geomertic-close up-single user-neutral/single-neutral.svg');

  static OrbIconSpec pencil = OrbIconSpec.buildIconSpec(
      'streamline-regular/01-interface essential/22-edit/pencil.svg');

  static OrbIconSpec link = OrbIconSpec.buildIconSpec(
      'streamline-regular/01-interface essential/52-expand:retract/expand-6.svg');

  static OrbIconSpec close = OrbIconSpec.buildIconSpec(
      'streamline-regular/01-interface essential/43-remove:add/remove.svg');
}

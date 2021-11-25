import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

import 'package:orb/string.dart';
import 'package:orb/ui/design.dart';

const String MEYA_CDN_URL = 'https://cdn.meya.ai';

class OrbIcon extends StatelessWidget {
  final OrbIconSpec src;
  final Color color;

  OrbIcon._({
    required this.src,
    required this.color,
  });

  factory OrbIcon(src, {Color? color, Color? defaultColor}) {
    Color _color = OrbThemePalette().normal;
    if (src.color != null) {
      _color = src.color as Color;
    } else if (color != null) {
      _color = color;
    } else if (defaultColor != null) {
      _color = defaultColor;
    }
    return OrbIcon._(
      src: src,
      color: _color,
    );
  }

  static OrbIcon? fromSpec(dynamic icon, {Color? defaultColor}) {
    final iconSpec = OrbIconSpec.fromSpec(icon);
    if (iconSpec == null) return null;
    return OrbIcon(
      iconSpec,
      defaultColor: defaultColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (src.svg != null && color == src.color) {
      return src.svg!;
    } else if (src.url != null) {
      if (!src.url!.startsWith("http")) {
        return placeholderIcon;
      }
      return SvgPicture.network(
        src.url!,
        color: color,
        placeholderBuilder: (BuildContext context) => placeholderIcon,
      );
    } else if (src.assetName != null) {
      return SvgPicture.asset(
        src.assetName!,
        bundle: src.assetBundle ?? DefaultAssetBundle.of(context),
        package: src.package ?? 'orb',
        color: color,
        placeholderBuilder: (BuildContext context) => placeholderIcon,
      );
    } else {
      throw OrbIconError(
          "Invalid OrbIconSpec, the icon spec requires either a 'url' or "
          "'assetName'");
    }
  }

  Widget fromAsset(BuildContext context) {
    return SvgPicture.asset(
      src.assetName!,
      bundle: src.assetBundle ?? DefaultAssetBundle.of(context),
      package: src.package ?? 'orb',
      color: color,
      placeholderBuilder: (BuildContext context) => placeholderIcon,
    );
  }

  Icon get placeholderIcon => Icon(
        Icons.check_box_outline_blank,
        color: color,
      );

  OrbIcon copyWith({
    OrbIconSpec? src,
    Color? color,
  }) {
    return OrbIcon(src ?? this.src, color: color ?? this.color);
  }
}

class OrbIconError extends Error {
  final String message;

  OrbIconError(this.message);

  String toString() => "OrbIconError: $message";
}

class OrbIconSpec {
  final String? url;
  final String? assetName;
  final AssetBundle? assetBundle;
  final String? package;
  final Color? color;
  final Widget? svg;

  OrbIconSpec._({
    this.url,
    this.assetName,
    this.assetBundle,
    this.package,
    this.color,
    this.svg,
  });

  factory OrbIconSpec({
    String? url,
    String? assetName,
    AssetBundle? assetBundle,
    String? package,
    String? color,
    Widget? svg,
  }) {
    if (svg != null) {
      return OrbIconSpec._(
        assetName: assetName,
        assetBundle: assetBundle,
        package: package,
        svg: svg,
      );
    } else if (url != null) {
      // TODO: Unify web & mobile icons - currently flutter_svg does not support CSS styles.
      if (url.contains(MEYA_CDN_URL) && !url.contains("orb-mobile")) {
        url = url.replaceFirst("icon", "icon/orb-mobile");
      } else if (url.startsWith("streamline")) {
        url = urlFromPath(url);
      }
      return OrbIconSpec._(url: url, color: color?.toColor());
    } else if (assetName != null) {
      return OrbIconSpec._(
        assetName: assetName,
        assetBundle: assetBundle,
        package: package,
        color: color?.toColor(),
      );
    } else {
      throw OrbIconSpecError(
          "An icon spec must contain either a 'url', 'assetName' or 'svg'");
    }
  }

  factory OrbIconSpec.buildIconSpec(String path) =>
      OrbIconSpec(url: urlFromPath(path));

  factory OrbIconSpec.buildAssetIconSpec(
    String assetName, {
    String package = 'orb',
  }) =>
      OrbIconSpec(
        assetName: assetName,
        package: package,
        svg: SvgPicture.asset(assetName, package: package),
      );

  static OrbIconSpec? fromMap(Map<dynamic, dynamic> icon) {
    if (icon['url'] == null) return null;
    return OrbIconSpec(url: icon['url'], color: icon['color']);
  }

  static OrbIconSpec? fromSpec(dynamic icon) {
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

class OrbIconSpecError extends Error {
  final String message;

  OrbIconSpecError(this.message);

  String toString() => "OrbIconSpecError: $message";
}

class OrbIcons {
  static OrbIconSpec check =
      OrbIconSpec.buildAssetIconSpec('icons/check-circle-1.svg');

  static OrbIconSpec expandInput =
      OrbIconSpec.buildAssetIconSpec('icons/messages-bubble-edit.svg');

  static OrbIconSpec extraInput =
      OrbIconSpec.buildAssetIconSpec('icons/add-square.svg');

  static OrbIconSpec file =
      OrbIconSpec.buildAssetIconSpec('icons/common-file-text.svg');

  static OrbIconSpec left =
      OrbIconSpec.buildAssetIconSpec('icons/arrow-left-1.svg');

  static OrbIconSpec right =
      OrbIconSpec.buildAssetIconSpec('icons/arrow-right-1.svg');

  static OrbIconSpec sendText =
      OrbIconSpec.buildAssetIconSpec('icons/send-email-2.svg');

  static OrbIconSpec sendFile =
      OrbIconSpec.buildAssetIconSpec('icons/common-file-text-add.svg');

  static OrbIconSpec sendImage =
      OrbIconSpec.buildAssetIconSpec('icons/image-file-add.svg');

  static OrbIconSpec camera =
      OrbIconSpec.buildAssetIconSpec('icons/camera-1.svg');

  static OrbIconSpec gallery =
      OrbIconSpec.buildAssetIconSpec('icons/picture-stack-landscape.svg');

  static OrbIconSpec emailAddress =
      OrbIconSpec.buildAssetIconSpec('icons/read-email-at.svg');

  static OrbIconSpec phone = OrbIconSpec.buildAssetIconSpec('icons/phone.svg');

  static OrbIconSpec flag =
      OrbIconSpec.buildAssetIconSpec('icons/flag-plain-3.svg');

  static OrbIconSpec user =
      OrbIconSpec.buildAssetIconSpec('icons/single-neutral.svg');

  static OrbIconSpec pencil =
      OrbIconSpec.buildAssetIconSpec('icons/pencil.svg');

  static OrbIconSpec link =
      OrbIconSpec.buildAssetIconSpec('icons/expand-6.svg');

  static OrbIconSpec close = OrbIconSpec.buildAssetIconSpec('icons/remove.svg');
}

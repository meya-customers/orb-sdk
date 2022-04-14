import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

import 'package:orb/string.dart';

const String meyaCdnUrl = 'https://cdn.meya.ai';
const String meyaCdnStagingUrl = 'https://cdn-staging.meya.ai';

class OrbIcon extends StatelessWidget {
  final double size;
  final OrbIconSpec src;
  final Color? color;

  const OrbIcon._({
    required this.src,
    required this.color,
    required this.size,
    Key? key,
  }) : super(key: key);

  factory OrbIcon(
    OrbIconSpec src, {
    required double size,
    Color? color,
    Color? defaultColor,
    Key? key,
  }) {
    Color? _color;
    if (src.color != null) {
      _color = src.color;
    } else if (color != null) {
      _color = color;
    } else if (defaultColor != null) {
      _color = defaultColor;
    }
    return OrbIcon._(
      src: src,
      color: _color,
      size: size,
      key: key,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: buildIcon(context),
    );
  }

  Widget buildIcon(BuildContext context) {
    if (src.url != null) {
      if (!src.url!.startsWith('http')) {
        return placeholderIcon;
      }
      return SvgPicture.network(
        src.url!,
        color: color,
        placeholderBuilder: (context) => placeholderIcon,
      );
    } else if (src.assetName != null) {
      return SvgPicture.asset(
        src.assetName!,
        bundle: src.assetBundle ?? DefaultAssetBundle.of(context),
        package: src.package ?? 'orb',
        color: color,
        placeholderBuilder: (context) => placeholderIcon,
      );
    } else {
      throw OrbIconError(
        "Invalid OrbIconSpec, the icon spec requires either a 'url' or "
        "'assetName'",
      );
    }
  }

  Icon get placeholderIcon => Icon(Icons.check_box_outline_blank, color: color);

  OrbIcon copyWith({
    OrbIconSpec? src,
    double? size,
    Color? color,
  }) {
    return OrbIcon(
      src ?? this.src,
      size: size ?? this.size,
      color: color ?? this.color,
    );
  }
}

class OrbIconError extends Error {
  final String message;

  OrbIconError(this.message);

  @override
  String toString() => 'OrbIconError: $message';
}

class OrbIconSpec {
  final String? url;
  final String? assetName;
  final AssetBundle? assetBundle;
  final String? package;
  final Color? color;

  OrbIconSpec._({
    this.url,
    this.assetName,
    this.assetBundle,
    this.package,
    this.color,
  });

  factory OrbIconSpec({
    String? url,
    String? assetName,
    AssetBundle? assetBundle,
    String? package,
    Color? color,
  }) {
    if (url != null) {
      // TODO: Unify web & mobile icons - currently flutter_svg does not support CSS styles.
      if ((url.startsWith(meyaCdnUrl) || url.startsWith(meyaCdnStagingUrl)) &&
          !url.contains('orb-mobile')) {
        url = url.replaceFirst('icon', 'icon/orb-mobile');
      } else if (url.startsWith('streamline')) {
        url = urlFromPath(url);
      }
      return OrbIconSpec._(url: url, color: color);
    } else if (assetName != null) {
      return OrbIconSpec._(
        assetName: assetName,
        assetBundle: assetBundle,
        package: package,
        color: color,
      );
    } else {
      throw OrbIconSpecError(
        "An icon spec must contain either a 'url' or 'assetName'",
      );
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
      );

  static OrbIconSpec? fromMap(Map<dynamic, dynamic>? icon) {
    if (icon == null || icon['url'] == null) {
      return null;
    }
    return OrbIconSpec(
      url: icon['url'],
      color: (icon['color'] as String).toColor(),
    );
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
      '$meyaCdnUrl/icon/orb-mobile/${path.replaceAll(RegExp(r'\s&\s|[:\s]'), '-')}';
}

class OrbIconSpecError extends Error {
  final String message;

  OrbIconSpecError(this.message);

  @override
  String toString() => 'OrbIconSpecError: $message';
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

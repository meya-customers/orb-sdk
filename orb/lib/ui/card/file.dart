import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;

import 'package:orb/design.dart';
import 'package:orb/event.dart';
import 'package:orb/ui/card/util/url.dart';
import 'package:orb/ui/card/widget_mode.dart';
import 'package:orb/ui/icon.dart';
import 'package:orb/ui/presence/user_avatar.dart';

abstract class OrbFile extends StatelessWidget {
  final OrbEvent event;
  final String filename;
  final String url;
  final bool isSelfEvent;
  final OrbUserAvatar? userAvatar;

  const OrbFile._({
    required this.event,
    required this.filename,
    required this.url,
    required this.isSelfEvent,
    required this.userAvatar,
    Key? key,
  }) : super(key: key);

  factory OrbFile({
    required OrbEvent event,
    required bool isSelfEvent,
    required OrbUserAvatar? userAvatar,
    required OrbWidgetMode mode,
    Key? key,
  }) {
    final filename = event.data['filename'];
    final url = event.data['url'];
    final basename = p.basename(filename);
    if (isSelfEvent) {
      return OrbFileSelf._(
        event: event,
        filename: basename,
        url: url,
        isSelfEvent: isSelfEvent,
        userAvatar: userAvatar,
        key: key,
      );
    } else {
      return OrbFileOther._(
        event: event,
        filename: basename,
        url: url,
        isSelfEvent: isSelfEvent,
        userAvatar: userAvatar,
        mode: mode,
        key: key,
      );
    }
  }

  static bool isVisible(OrbEvent event) {
    return (event.data['url'] ?? '') != '';
  }

  Widget buildContainer(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 300,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.70,
        padding: EdgeInsets.all(OrbTheme.of(context).lengths.medium),
        decoration: buildBoxDecoration(context),
        child: buildFile(context),
      ),
    );
  }

  BoxDecoration buildBoxDecoration(BuildContext context) {
    return BoxDecoration(
      boxShadow: [OrbTheme.of(context).outerShadow.small],
      color: OrbTheme.of(context).palette.blank,
      borderRadius: BorderRadius.all(OrbTheme.of(context).borderRadius.small),
    );
  }

  Widget buildFile(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(right: OrbTheme.of(context).lengths.small),
          child: buildIcon(context),
        ),
        Expanded(
          child: InkWell(
            child: Text(
              filename,
              style: (OrbTheme.of(context).text.font.normal)
                  .merge(OrbTheme.of(context).text.style.bold)
                  .merge(OrbTheme.of(context).text.size.medium)
                  .copyWith(color: OrbTheme.of(context).palette.brand),
            ),
            onTap: () async {
              await OrbUrl(url).tryLaunch(context);
            },
          ),
        ),
      ],
    );
  }

  OrbIcon buildIcon(BuildContext context) {
    final iconSpec = OrbIconSpec.fromMap(event.data['icon']);
    if (iconSpec != null) {
      return OrbIcon(
        iconSpec,
        size: OrbTheme.of(context).size.icon.medium,
        color: OrbTheme.of(context).palette.brand,
      );
    } else {
      return OrbIcon(
        OrbIcons.file,
        size: OrbTheme.of(context).size.icon.medium,
        color: OrbTheme.of(context).palette.brand,
      );
    }
  }
}

class OrbFileSelf extends OrbFile {
  const OrbFileSelf._({
    required OrbEvent event,
    required String filename,
    required String url,
    required bool isSelfEvent,
    required OrbUserAvatar? userAvatar,
    Key? key,
  }) : super._(
          event: event,
          filename: filename,
          url: url,
          isSelfEvent: isSelfEvent,
          userAvatar: userAvatar,
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [buildContainer(context)],
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
    );
  }
}

class OrbFileOther extends OrbFile {
  final OrbWidgetMode mode;

  const OrbFileOther._({
    required OrbEvent event,
    required String filename,
    required String url,
    required bool isSelfEvent,
    required OrbUserAvatar? userAvatar,
    required this.mode,
    Key? key,
  }) : super._(
          event: event,
          filename: filename,
          url: url,
          isSelfEvent: isSelfEvent,
          userAvatar: userAvatar,
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return mode == OrbWidgetMode.standalone
        ? Row(
            children: [
              OrbUserAvatar.avatarOrPlaceholder(
                context,
                avatar: userAvatar,
              ),
              buildContainer(context),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildContainer(context),
            ],
          );
  }
}

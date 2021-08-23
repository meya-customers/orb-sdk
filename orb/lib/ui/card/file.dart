import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;

import 'package:orb/event.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/icon.dart';
import 'package:orb/ui/presence/user_avatar.dart';

abstract class OrbFile extends StatelessWidget {
  final OrbEvent event;
  final String filename;
  final String url;
  final bool isSelfEvent;
  final OrbUserAvatar userAvatar;

  OrbFile._({
    @required this.event,
    @required this.filename,
    @required this.url,
    @required this.isSelfEvent,
    @required this.userAvatar,
  });

  factory OrbFile({
    @required OrbEvent event,
    @required String filename,
    @required String url,
    @required bool isSelfEvent,
    @required OrbUserAvatar userAvatar,
  }) {
    final basename = p.basename(filename);
    if (isSelfEvent) {
      return OrbFileSelf._(
        event: event,
        filename: basename,
        url: url,
        isSelfEvent: isSelfEvent,
        userAvatar: userAvatar,
      );
    } else {
      return OrbFileOther._(
        event: event,
        filename: basename,
        url: url,
        isSelfEvent: isSelfEvent,
        userAvatar: userAvatar,
      );
    }
  }

  Widget buildContainer(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 300,
      ),
      child: Container(
        margin: EdgeInsets.only(
          top: (!event.isFirstInGroup
              ? OrbTheme.of(context).lengths.large
              : OrbTheme.of(context).lengths.small),
        ),
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
        // TODO: Download file
        Expanded(
          child: Text(
            filename,
            style: (OrbTheme.of(context).text.font.normal)
                .merge(OrbTheme.of(context).text.style.bold)
                .merge(OrbTheme.of(context).text.size.medium)
                .copyWith(color: OrbTheme.of(context).palette.brand),
          ),
        ),
      ],
    );
  }

  OrbIcon buildIcon(BuildContext context) {
    if (event.data.containsKey("icon")) {
      return OrbIcon(
        OrbIconSpec(
          url: event.data["icon"]["url"],
          color: event.data["icon"]["color"],
        ),
        color: OrbTheme.of(context).palette.brand,
      );
    } else {
      return OrbIcon(
        OrbIcons.file,
        color: OrbTheme.of(context).palette.brand,
      );
    }
  }
}

class OrbFileSelf extends OrbFile {
  OrbFileSelf._({
    @required OrbEvent event,
    @required String filename,
    @required String url,
    @required bool isSelfEvent,
    @required OrbUserAvatar userAvatar,
  }) : super._(
          event: event,
          filename: filename,
          url: url,
          isSelfEvent: isSelfEvent,
          userAvatar: userAvatar,
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
  OrbFileOther._({
    @required OrbEvent event,
    @required String filename,
    @required String url,
    @required bool isSelfEvent,
    @required OrbUserAvatar userAvatar,
  }) : super._(
          event: event,
          filename: filename,
          url: url,
          isSelfEvent: isSelfEvent,
          userAvatar: userAvatar,
        );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OrbUserAvatar.avatarOrPlaceholder(
          context,
          avatar: userAvatar,
        ),
        buildContainer(context),
      ],
    );
  }
}

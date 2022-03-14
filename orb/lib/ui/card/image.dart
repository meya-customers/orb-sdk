import 'package:flutter/material.dart';

import 'package:orb/event.dart';
import 'package:orb/ui/card/widget_mode.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/presence/user_avatar.dart';

abstract class OrbImage extends StatelessWidget {
  final OrbEvent event;
  final String url;
  final String? alt;
  final bool isSelfEvent;
  final OrbUserAvatar? userAvatar;

  OrbImage._({
    required this.event,
    required this.url,
    required this.alt,
    required this.isSelfEvent,
    required this.userAvatar,
  });

  factory OrbImage({
    required OrbEvent event,
    required bool isSelfEvent,
    required OrbUserAvatar? userAvatar,
    required OrbWidgetMode mode,
  }) {
    final url = event.data['url'];
    final alt = event.data['alt'];
    if (isSelfEvent) {
      return OrbImageSelf._(
        event: event,
        url: url,
        alt: alt,
        isSelfEvent: isSelfEvent,
        userAvatar: userAvatar,
      );
    } else {
      return OrbImageOther._(
          event: event,
          url: url,
          alt: alt,
          isSelfEvent: isSelfEvent,
          userAvatar: userAvatar,
          mode: mode);
    }
  }

  static bool isVisible(OrbEvent event) {
    return (event.data['url'] ?? '') != "";
  }

  Widget buildContainer(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: (!event.isFirstInGroup
            ? OrbTheme.of(context).lengths.large
            : OrbTheme.of(context).lengths.small),
      ),
      padding: EdgeInsets.all(0.0),
      decoration: buildBoxDecoration(context),
      child: buildImage(context),
    );
  }

  BoxDecoration buildBoxDecoration(BuildContext context) {
    return BoxDecoration(
      boxShadow: [OrbTheme.of(context).outerShadow.small],
      color: OrbTheme.of(context).palette.blank,
      borderRadius: BorderRadius.all(OrbTheme.of(context).borderRadius.small),
    );
  }

  Widget buildImage(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.80,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(OrbTheme.of(context).borderRadius.small),
        child: Image.network(
          url,
          semanticLabel: alt,
          loadingBuilder: (context, child, progress) {
            return progress == null
                ? child
                : LinearProgressIndicator(
                    value: progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!,
                  );
          },
        ),
      ),
    );
  }
}

class OrbImageSelf extends OrbImage {
  OrbImageSelf._({
    required OrbEvent event,
    required String url,
    required String? alt,
    required bool isSelfEvent,
    required OrbUserAvatar? userAvatar,
  }) : super._(
          event: event,
          url: url,
          alt: alt,
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

class OrbImageOther extends OrbImage {
  final OrbWidgetMode mode;

  OrbImageOther._({
    required OrbEvent event,
    required String url,
    required String? alt,
    required bool isSelfEvent,
    required OrbUserAvatar? userAvatar,
    required this.mode,
  }) : super._(
          event: event,
          url: url,
          alt: alt,
          isSelfEvent: isSelfEvent,
          userAvatar: userAvatar,
        );

  @override
  Widget build(BuildContext context) {
    return mode == OrbWidgetMode.standalone
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                child: (userAvatar ?? OrbUserAvatar.placeholder(context)),
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

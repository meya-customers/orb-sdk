import 'package:flutter/material.dart';

import 'package:orb/design.dart';
import 'package:orb/event.dart';
import 'package:orb/ui/card/widget_mode.dart';
import 'package:orb/ui/presence/user_avatar.dart';

abstract class OrbImage extends StatelessWidget {
  final OrbEvent event;
  final String url;
  final String? alt;
  final bool isSelfEvent;
  final OrbUserAvatar? userAvatar;

  const OrbImage._({
    required this.event,
    required this.url,
    required this.alt,
    required this.isSelfEvent,
    required this.userAvatar,
    Key? key,
  }) : super(key: key);

  factory OrbImage({
    required OrbEvent event,
    required bool isSelfEvent,
    required OrbUserAvatar? userAvatar,
    required OrbWidgetMode mode,
    Key? key,
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
        key: key,
      );
    } else {
      return OrbImageOther._(
        event: event,
        url: url,
        alt: alt,
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
    return Container(
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
  const OrbImageSelf._({
    required OrbEvent event,
    required String url,
    required String? alt,
    required bool isSelfEvent,
    required OrbUserAvatar? userAvatar,
    Key? key,
  }) : super._(
          event: event,
          url: url,
          alt: alt,
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

class OrbImageOther extends OrbImage {
  final OrbWidgetMode mode;

  const OrbImageOther._({
    required OrbEvent event,
    required String url,
    required String? alt,
    required bool isSelfEvent,
    required OrbUserAvatar? userAvatar,
    required this.mode,
    Key? key,
  }) : super._(
          event: event,
          url: url,
          alt: alt,
          isSelfEvent: isSelfEvent,
          userAvatar: userAvatar,
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return mode == OrbWidgetMode.standalone
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                child: userAvatar ?? OrbUserAvatar.placeholder(context),
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

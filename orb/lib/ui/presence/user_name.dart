import 'package:flutter/material.dart';

import 'package:orb/event_stream.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/presence/user_avatar.dart';

abstract class OrbUserName extends StatelessWidget {
  final OrbEventStream eventStream;
  final String? userId;

  OrbUserName._({
    required this.eventStream,
    required this.userId,
  });

  factory OrbUserName({
    required OrbEventStream eventStream,
    required userId,
    required bool isSelfEvent,
  }) {
    if (isSelfEvent) {
      return OrbUserNameSelf._(
        eventStream: eventStream,
        userId: userId,
      );
    } else {
      return OrbUserNameOther._(
        eventStream: eventStream,
        userId: userId,
      );
    }
  }

  Widget buildContainer(BuildContext context) {
    final userData = eventStream.userData[userId!];
    final name = getUserName(userData);

    return Container(
      margin: EdgeInsets.only(
        top: OrbTheme.of(context).lengths.large,
        left: OrbTheme.of(context).lengths.small,
      ),
      child: Text(
        name,
        style: (OrbTheme.of(context).text.font.normal)
            .merge(OrbTheme.of(context).text.style.normal)
            .merge(OrbTheme.of(context).text.size.small)
            .copyWith(color: OrbTheme.of(context).palette.disabledDark),
      ),
    );
  }

  static String getUserName(OrbUserData? userData) {
    return userData?.name ?? getDefaultUserName(userData);
  }

  static String getDefaultUserName(OrbUserData? userData) {
    final type = userData?.type ?? OrbUserType.bot;
    final role = type.toString().split('.').last;
    return role[0].toUpperCase() + role.substring(1);
  }
}

class OrbUserNameSelf extends OrbUserName {
  OrbUserNameSelf._({
    required OrbEventStream eventStream,
    required userId,
  }) : super._(
          eventStream: eventStream,
          userId: userId,
        );

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}

class OrbUserNameOther extends OrbUserName {
  OrbUserNameOther._({
    required OrbEventStream eventStream,
    required userId,
  }) : super._(
          eventStream: eventStream,
          userId: userId,
        );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: OrbUserAvatar.defaultMargin(context),
          child: OrbUserAvatar.placeholder(context),
        ),
        buildContainer(context),
      ],
    );
  }
}

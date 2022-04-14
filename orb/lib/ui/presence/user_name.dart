import 'package:flutter/material.dart';

import 'package:orb/design.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/presence/user_avatar.dart';

abstract class OrbUserName extends StatelessWidget {
  final OrbEventStream eventStream;
  final String? userId;

  const OrbUserName._({
    required this.eventStream,
    required this.userId,
    Key? key,
  }) : super(key: key);

  factory OrbUserName({
    required OrbEventStream eventStream,
    required userId,
    required bool isSelfEvent,
    Key? key,
  }) {
    if (isSelfEvent) {
      return OrbUserNameSelf._(
        eventStream: eventStream,
        userId: userId,
        key: key,
      );
    } else {
      return OrbUserNameOther._(
        eventStream: eventStream,
        userId: userId,
        key: key,
      );
    }
  }

  Widget buildContainer(BuildContext context) {
    final userData = eventStream.userData[userId!];
    final name = getUserName(userData);

    return Container(
      margin: EdgeInsets.only(
        bottom: OrbTheme.of(context).lengths.small,
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
  const OrbUserNameSelf._({
    required OrbEventStream eventStream,
    required userId,
    Key? key,
  }) : super._(
          eventStream: eventStream,
          userId: userId,
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class OrbUserNameOther extends OrbUserName {
  const OrbUserNameOther._({
    required OrbEventStream eventStream,
    required userId,
    Key? key,
  }) : super._(
          eventStream: eventStream,
          userId: userId,
          key: key,
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

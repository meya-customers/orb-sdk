import 'package:flutter/material.dart';

import 'package:orb/event.dart';
import 'package:orb/ui/design.dart';
import 'package:orb/ui/presence/user_avatar.dart';

abstract class OrbText extends StatelessWidget {
  final OrbEvent event;
  final String text;
  final bool isSelfEvent;
  final OrbUserAvatar userAvatar;

  OrbText._({
    @required this.event,
    @required this.text,
    @required this.isSelfEvent,
    @required this.userAvatar,
  });

  factory OrbText({
    @required OrbEvent event,
    @required String text,
    @required bool isSelfEvent,
    @required OrbUserAvatar userAvatar,
  }) {
    if (isSelfEvent) {
      return OrbTextSelf._(
        event: event,
        text: text,
        isSelfEvent: isSelfEvent,
        userAvatar: userAvatar,
      );
    } else {
      return OrbTextOther._(
        event: event,
        text: text,
        isSelfEvent: isSelfEvent,
        userAvatar: userAvatar,
      );
    }
  }

  Widget buildContainer(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: (!event.isFirstInGroup
            ? OrbTheme.of(context).lengths.large
            : OrbTheme.of(context).lengths.small),
      ),
      padding: EdgeInsets.all(OrbTheme.of(context).lengths.medium),
      decoration: buildBoxDecoration(context),
      child: buildText(context),
    );
  }

  BoxDecoration buildBoxDecoration(BuildContext context) {
    return BoxDecoration(
      boxShadow: [OrbTheme.of(context).outerShadow.tiny],
    );
  }

  Widget buildText(BuildContext context) {
    return Text(
      text,
      style: (OrbTheme.of(context).text.font.normal)
          .merge(OrbTheme.of(context).text.style.normal)
          .merge(OrbTheme.of(context).text.size.medium)
          .copyWith(color: OrbTheme.of(context).palette.normal),
    );
  }
}

class OrbTextSelf extends OrbText {
  OrbTextSelf._({
    @required OrbEvent event,
    @required String text,
    @required bool isSelfEvent,
    @required OrbUserAvatar userAvatar,
  }) : super._(
          event: event,
          text: text,
          isSelfEvent: isSelfEvent,
          userAvatar: userAvatar,
        );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: OrbUserAvatar.defaultMargin(context),
          child: OrbUserAvatar.placeholder(context),
        ),
        Flexible(
          child: Column(
            children: [buildContainer(context)],
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
          ),
        ),
      ],
    );
  }

  @override
  BoxDecoration buildBoxDecoration(BuildContext context) {
    return super.buildBoxDecoration(context).copyWith(
          color: OrbTheme.of(context).palette.brandNeutral,
          border: OrbTheme.of(context).innerBorder.thin(
                OrbTheme.of(context).palette.brandLight,
              ),
          borderRadius:
              BorderRadius.all(OrbTheme.of(context).borderRadius.medium) -
                  BorderRadius.only(
                    bottomRight: OrbTheme.of(context).borderRadius.medium,
                  ),
        );
  }
}

class OrbTextOther extends OrbText {
  final bool containerOnly;

  OrbTextOther._({
    @required OrbEvent event,
    @required String text,
    @required bool isSelfEvent,
    @required OrbUserAvatar userAvatar,
    this.containerOnly = false,
  }) : super._(
          event: event,
          text: text,
          isSelfEvent: isSelfEvent,
          userAvatar: userAvatar,
        );

  factory OrbTextOther.container({
    @required OrbEvent event,
    @required String text,
  }) {
    return OrbTextOther._(
      event: event,
      text: text,
      isSelfEvent: false,
      userAvatar: null,
      containerOnly: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (containerOnly) {
      return buildContainer(context);
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildUserAvatar(context),
          Flexible(
            child: Column(
              children: [
                buildContainer(context),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget buildUserAvatar(BuildContext context) {
    return Container(
      margin: OrbUserAvatar.defaultMargin(context),
      child: userAvatar ?? OrbUserAvatar.placeholder(context),
    );
  }

  @override
  BoxDecoration buildBoxDecoration(BuildContext context) {
    return super.buildBoxDecoration(context).copyWith(
          color: OrbTheme.of(context).palette.blank,
          border: OrbTheme.of(context).innerBorder.thin(
                OrbTheme.of(context).palette.outline,
              ),
          borderRadius:
              BorderRadius.all(OrbTheme.of(context).borderRadius.medium) -
                  BorderRadius.only(
                    topLeft: OrbTheme.of(context).borderRadius.medium,
                  ),
        );
  }
}

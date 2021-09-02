import 'package:flutter/material.dart';

import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

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
    @required bool isSelfEvent,
    @required OrbUserAvatar userAvatar,
  }) {
    final text = event.data['text'];
    if (isSelfEvent) {
      return OrbTextSelf(
        event: event,
        text: text,
        isSelfEvent: isSelfEvent,
        userAvatar: userAvatar,
      );
    } else {
      return OrbTextOther(
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
    final List markdown = event.data['markdown'];
    final OrbThemeData orbTheme = OrbTheme.of(context);
    final TextStyle normal = orbTheme.text.font.normal
        .merge(orbTheme.text.style.normal)
        .merge(orbTheme.text.size.medium)
        .copyWith(color: orbTheme.palette.normal);

    if (markdown != null &&
        markdown.length == 1 &&
        markdown.contains('linkify')) {
      return Linkify(
        onOpen: (link) async {
          await _launchUrl(context, link.url);
        },
        text: text,
        style: normal,
        linkStyle: normal.copyWith(color: orbTheme.palette.brand),
      );
    } else if (markdown != null && markdown.isNotEmpty) {
      return MarkdownBody(
        data: text,
        selectable: true,
        styleSheet: OrbTheme.of(context).markdownStyleSheet,
        onTapLink: (String text, String url, String title) async {
          await _launchUrl(context, url);
        },
        inlineSyntaxes: [if (markdown.contains('breaks')) OrbLineBreakSyntax()],
      );
    } else {
      return SelectableText(text, style: normal);
    }
  }

  Future _launchUrl(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Could not open '$url'"),
          duration: Duration(milliseconds: 2000)));
    }
  }
}

class OrbTextSelf extends OrbText {
  @protected
  OrbTextSelf({
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

  @protected
  OrbTextOther({
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
    return OrbTextOther(
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
          OrbUserAvatar.avatarOrPlaceholder(
            context,
            avatar: userAvatar,
          ),
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

class OrbLineBreakSyntax extends md.InlineSyntax {
  OrbLineBreakSyntax() : super(r'(?:\\|)\n');

  /// Create a void <br> element.
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.empty('br'));
    return true;
  }
}

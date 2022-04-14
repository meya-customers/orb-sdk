import 'package:flutter/material.dart';

import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import 'package:orb/design.dart';
import 'package:orb/event.dart';
import 'package:orb/ui/card/util/url.dart';
import 'package:orb/ui/presence/user_avatar.dart';

abstract class OrbText extends StatelessWidget {
  final OrbEvent event;
  final String text;
  final bool isSelfEvent;
  final OrbUserAvatar? userAvatar;
  final List<dynamic>? markdownDefault;

  const OrbText._({
    required this.event,
    required this.text,
    required this.isSelfEvent,
    required this.userAvatar,
    this.markdownDefault,
    Key? key,
  }) : super(key: key);

  factory OrbText({
    required OrbEvent event,
    required String text,
    required bool isSelfEvent,
    required OrbUserAvatar? userAvatar,
    List<dynamic>? markdownDefault,
    Key? key,
  }) {
    if (isSelfEvent) {
      return OrbTextSelf(
        event: event,
        text: text,
        isSelfEvent: isSelfEvent,
        userAvatar: userAvatar,
        markdownDefault: markdownDefault,
        key: key,
      );
    } else {
      return OrbTextOther(
        event: event,
        text: text,
        isSelfEvent: isSelfEvent,
        userAvatar: userAvatar,
        markdownDefault: markdownDefault,
        key: key,
      );
    }
  }

  Widget buildContainer(BuildContext context) {
    return Container(
      padding: buildPadding(context),
      decoration: buildBoxDecoration(context),
      child: buildText(context),
    );
  }

  EdgeInsetsGeometry buildPadding(BuildContext context) {
    return EdgeInsets.all(OrbTheme.of(context).lengths.medium);
  }

  BoxDecoration buildBoxDecoration(BuildContext context) {
    return BoxDecoration(
      boxShadow: [OrbTheme.of(context).outerShadow.tiny],
    );
  }

  Widget buildText(BuildContext context) {
    final List<dynamic>? markdown = event.data['markdown'] ?? markdownDefault;
    final OrbTheme orbTheme = OrbTheme.of(context);
    final TextStyle normal = orbTheme.text.font.normal
        .merge(orbTheme.text.style.normal)
        .merge(orbTheme.text.size.medium)
        .copyWith(color: orbTheme.palette.normal);

    if (markdown != null &&
        markdown.length == 1 &&
        markdown.contains('linkify')) {
      return Linkify(
        onOpen: (link) async {
          await OrbUrl(link.url).tryLaunch(context);
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
        onTapLink: (text, url, title) async {
          await OrbUrl(url!).tryLaunch(context);
        },
        inlineSyntaxes: [if (markdown.contains('breaks')) OrbLineBreakSyntax()],
      );
    } else {
      return SelectableText(text, style: normal);
    }
  }
}

class OrbTextSelf extends OrbText {
  @protected
  const OrbTextSelf({
    required OrbEvent event,
    required String text,
    required bool isSelfEvent,
    required OrbUserAvatar? userAvatar,
    List<dynamic>? markdownDefault,
    Key? key,
  }) : super._(
          event: event,
          text: text,
          isSelfEvent: isSelfEvent,
          userAvatar: userAvatar,
          markdownDefault: markdownDefault,
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: OrbUserAvatar.defaultMargin(context),
          child: OrbUserAvatar.placeholder(context),
        ),
        Flexible(child: buildContainer(context)),
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
  @protected
  const OrbTextOther({
    required OrbEvent event,
    required String text,
    required bool isSelfEvent,
    required OrbUserAvatar? userAvatar,
    List<dynamic>? markdownDefault,
    Key? key,
  }) : super._(
          event: event,
          text: text,
          isSelfEvent: isSelfEvent,
          userAvatar: userAvatar,
          markdownDefault: markdownDefault,
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        OrbUserAvatar.avatarOrPlaceholder(
          context,
          avatar: userAvatar,
        ),
        Flexible(
          child: buildContainer(context),
        ),
      ],
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

class OrbTextInfo extends OrbText {
  OrbTextInfo({
    required OrbEvent event,
    required List<dynamic>? markdown,
    Key? key,
  }) : super._(
          event: event,
          text: event.data['info'],
          isSelfEvent: false,
          userAvatar: null,
          markdownDefault: markdown,
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: buildContainer(context),
        ),
      ],
    );
  }

  @override
  EdgeInsetsGeometry buildPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: OrbTheme.of(context).lengths.medium,
    );
  }

  @override
  BoxDecoration buildBoxDecoration(BuildContext context) {
    return const BoxDecoration();
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

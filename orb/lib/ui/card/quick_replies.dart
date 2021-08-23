import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:orb/connection.dart';
import 'package:orb/event.dart';
import 'package:orb/ui/design.dart';

class OrbQuickReplies extends StatelessWidget {
  final OrbEvent event;
  final OrbConnection connection;

  OrbQuickReplies({
    @required this.event,
    @required this.connection,
  });

  @override
  Widget build(BuildContext context) {
    final quickReplies = event.data["quick_replies"] as List<dynamic>;
    if (quickReplies.length == 0) {
      return SizedBox.shrink();
    } else {
      return Container(
        alignment: Alignment.centerRight,
        child: Wrap(
          alignment: WrapAlignment.end,
          children: [
            for (final quickReply in quickReplies)
              QuickReply(
                text: quickReply["text"],
                onTap: () {
                  if (quickReply["button_id"] != null) {
                    connection.publishEvent(OrbEvent.createButtonClickEvent(
                      quickReply["button_id"],
                      text: quickReply["text"],
                      context: quickReply["context"],
                    ));
                  } else {
                    connection.publishEvent(OrbEvent.createSayEvent(
                      quickReply["text"],
                      context: quickReply["context"],
                    ));
                  }
                },
              )
          ],
        ),
      );
    }
  }
}

class QuickReply extends StatelessWidget {
  final String text;
  final Function onTap;

  QuickReply({
    @required this.text,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          top: OrbTheme.of(context).lengths.large,
          left: OrbTheme.of(context).lengths.small,
          right: OrbTheme.of(context).lengths.small,
        ),
        padding: EdgeInsets.all(OrbTheme.of(context).lengths.medium),
        decoration: BoxDecoration(
          boxShadow: [OrbTheme.of(context).outerShadow.tiny],
          color: OrbTheme.of(context).palette.blank,
          border: OrbTheme.of(context).innerBorder.thick(
                OrbTheme.of(context).palette.brand,
              ),
          borderRadius:
              BorderRadius.all(OrbTheme.of(context).borderRadius.medium) -
                  BorderRadius.only(
                    bottomRight: OrbTheme.of(context).borderRadius.medium,
                  ),
        ),
        child: FittedBox(
          child: Text(
            text,
            style: (OrbTheme.of(context).text.font.normal)
                .merge(OrbTheme.of(context).text.style.bold)
                .merge(OrbTheme.of(context).text.size.medium)
                .copyWith(color: OrbTheme.of(context).palette.brand),
          ),
        ),
      ),
    );
  }
}

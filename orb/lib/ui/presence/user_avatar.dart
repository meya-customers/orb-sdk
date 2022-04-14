import 'dart:math';

import 'package:flutter/material.dart';

import 'package:orb/design.dart';
import 'package:orb/event.dart';
import 'package:orb/event_stream.dart';
import 'package:orb/ui/avatar.dart';
import 'package:orb/ui/presence/user_name.dart';

class OrbUserAvatar extends StatelessWidget {
  final OrbEventStream eventStream;
  final String? userId;

  const OrbUserAvatar({
    required this.eventStream,
    required this.userId,
    Key? key,
  }) : super(key: key);

  factory OrbUserAvatar.fromEvent({
    required OrbEventStream eventStream,
    required OrbEvent event,
  }) {
    return OrbUserAvatar(
      eventStream: eventStream,
      userId: event.data['user_id'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = eventStream.userData[userId!];
    final avatar = userData?.avatar;
    final avatarImage = avatar?.image;
    final avatarCrop = avatar?.crop;

    if (avatarImage != null) {
      return SizedBox(
        width: OrbTheme.of(context).avatar.width,
        height: OrbTheme.of(context).avatar.height,
        child: _croppedImage(context, avatarImage, avatarCrop),
      );
    } else {
      final monogram =
          (avatar?.monogram ?? OrbUserName.getUserName(userData))[0];
      return Container(
        width: OrbTheme.of(context).avatar.width,
        height: OrbTheme.of(context).avatar.height,
        decoration: BoxDecoration(
          color: OrbTheme.of(context).palette.brandDark,
          boxShadow: [OrbTheme.of(context).outerShadow.tiny],
          borderRadius:
              BorderRadius.circular(OrbTheme.of(context).avatar.radius),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                monogram,
                style: OrbTheme.of(context).text.style.bold.copyWith(
                      color: OrbTheme.of(context).palette.blank,
                      fontSize: OrbTheme.of(context).text.size.medium.fontSize,
                    ),
              ),
              BotSemicircle(
                radius: OrbTheme.of(context).avatar.semicircleRadius,
                color: OrbTheme.of(context).palette.blank,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _croppedImage(BuildContext context, String url, OrbAvatarCrop? crop) {
    if (crop == OrbAvatarCrop.square) {
      return ClipRect(
        child: Align(
          alignment: Alignment.center,
          widthFactor: OrbTheme.of(context).avatar.width,
          heightFactor: OrbTheme.of(context).avatar.height,
          child: Image.network(url),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(OrbTheme.of(context).avatar.radius),
        child: Image.network(url),
      );
    }
  }

  static Widget placeholder(BuildContext context) {
    return SizedBox(
      width: OrbTheme.of(context).avatar.width,
      height: 0,
    );
  }

  static EdgeInsets defaultMargin(BuildContext context) =>
      OrbTheme.of(context).avatar.defaultMargin;

  static Widget avatarOrPlaceholder(
    BuildContext context, {
    required OrbUserAvatar? avatar,
  }) {
    return Container(
      margin: OrbUserAvatar.defaultMargin(context),
      child: avatar ?? OrbUserAvatar.placeholder(context),
    );
  }
}

class BotSemicircle extends StatelessWidget {
  final double radius;
  final Color color;

  const BotSemicircle({
    required this.radius,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SemicirclePainter(color: color),
      size: Size(radius, radius / 2),
    );
  }
}

class SemicirclePainter extends CustomPainter {
  final Color color;

  SemicirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, 0),
        width: size.width,
        height: size.height * 2,
      ),
      0,
      pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

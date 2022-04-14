import 'dart:math';

import 'package:flutter/material.dart';

import 'package:orb/design.dart';
import 'package:orb/event.dart';
import 'package:orb/ui/card/text.dart';
import 'package:orb/ui/presence/user_avatar.dart';

class OrbTypingIndicator extends OrbTextOther {
  const OrbTypingIndicator({
    required OrbEvent event,
    required OrbUserAvatar userAvatar,
    Key? key,
  }) : super(
          key: key,
          event: event,
          text: 'Typing',
          isSelfEvent: false,
          userAvatar: userAvatar,
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
        buildContainer(context),
      ],
    );
  }

  @override
  Widget buildContainer(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: OrbTheme.of(context).lengths.large),
      padding: buildPadding(context),
      decoration: buildBoxDecoration(context),
      child: buildText(context),
    );
  }

  @override
  Widget buildText(BuildContext context) {
    return _TypingIndicator();
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildCircle(context, 0.0),
        buildCircle(context, 0.3),
        buildCircle(context, 0.6),
      ],
    );
  }

  Widget buildCircle(BuildContext context, double delay) {
    return FadeTransition(
      child: Container(
        margin: const EdgeInsets.only(right: 2),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: OrbTheme.of(context).palette.support,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      opacity: _TypingIndicatorTween(begin: 0.4, end: 0.9, delay: delay)
          .animate(_animationController),
    );
  }
}

class _TypingIndicatorTween extends Tween<double> {
  final double? delay;

  _TypingIndicatorTween({double? begin, double? end, this.delay})
      : super(begin: begin, end: end);

  @override
  double lerp(double t) => super.lerp((sin((t - delay!) * 2 * pi) + 1) / 2);
}

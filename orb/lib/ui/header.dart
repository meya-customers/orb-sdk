import 'package:flutter/material.dart';

import 'package:orb/connection.dart';
import 'package:orb/ui/icon.dart';

class OrbHeader extends StatefulWidget {
  final OrbConnection connection;

  OrbHeader({Key key, this.connection}) : super(key: key);

  @override
  _OrbHeaderState createState() => _OrbHeaderState(connection: connection);
}

class _OrbHeaderState extends State<OrbHeader> {
  final OrbConnection connection;

  _OrbHeaderState({this.connection});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => buildCloseButton(context));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }

  void buildCloseButton(BuildContext context) {
    if (connection.enableCloseButton != null && !connection.enableCloseButton)
      return;

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 5,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => connection.closeUi(),
            child: Container(
              width: 30,
              height: 30,
              decoration: new BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: OrbIcon(OrbIcons.close),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(entry);
  }
}

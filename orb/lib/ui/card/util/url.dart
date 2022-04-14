import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class OrbUrl {
  final String url;

  OrbUrl(this.url);

  Future<void> tryLaunch(BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not open '$url'"),
          duration: const Duration(milliseconds: 2000),
        ),
      );
    }
  }
}

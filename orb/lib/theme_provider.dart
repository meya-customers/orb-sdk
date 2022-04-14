import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:orb/config.dart';
import 'package:orb/design.dart';

class OrbThemeProvider extends StatelessWidget {
  final Widget child;

  const OrbThemeProvider({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrbThemeInherited(
      theme: OrbTheme(OrbConfig.of(context).theme),
      child: child,
    );
  }
}

class OrbThemeInherited extends InheritedWidget {
  final OrbTheme theme;

  const OrbThemeInherited({
    required this.theme,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('theme', theme, showName: false));
  }

  @override
  bool updateShouldNotify(OrbThemeInherited oldWidget) =>
      theme != oldWidget.theme;
}

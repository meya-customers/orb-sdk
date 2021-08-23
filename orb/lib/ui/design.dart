import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:orb/config.dart';
import 'package:orb/ui/color.dart';

class OrbThemeData {
  final OrbThemePalette palette;
  final OrbThemeLengths lengths;
  final OrbThemeOuterShadow outerShadow;
  final OrbThemeInnerBorder innerBorder;
  final OrbThemeBorderRadius borderRadius;
  final OrbThemeText text;
  final OrbThemeAvatar avatar;

  OrbThemeData._({
    @required this.palette,
    @required this.lengths,
    @required this.outerShadow,
    @required this.innerBorder,
    @required this.borderRadius,
    @required this.text,
    @required this.avatar,
  });

  factory OrbThemeData({Color brandColor, double backgroundTranslucency}) {
    final palette = OrbThemePalette(
      brandColor: brandColor,
      backgroundTranslucency: backgroundTranslucency,
    );
    final lengths = OrbThemeLengths();
    final outerShadow = OrbThemeOuterShadow();
    final innerBorder = OrbThemeInnerBorder();
    final borderRadius = OrbThemeBorderRadius();
    final text = OrbThemeText();
    final avatar = OrbThemeAvatar();
    return OrbThemeData._(
      palette: palette,
      lengths: lengths,
      outerShadow: outerShadow,
      innerBorder: innerBorder,
      borderRadius: borderRadius,
      text: text,
      avatar: avatar,
    );
  }

  factory OrbThemeData.fromThemeConfigSpec({ThemeConfigSpec theme}) =>
      OrbThemeData(
        brandColor: HexColor.fromHex(theme.brandColor),
        backgroundTranslucency: theme.backgroundTranslucency,
      );

  ThemeData toMaterialThemeData() =>
      ThemeData(textTheme: GoogleFonts.interTextTheme());

  Widget builder(BuildContext context, Widget child) {
    return OrbTheme(
      data: this,
      child: child,
    );
  }
}

class OrbThemeLengths {
  double get none => 0;
  double get tiny => 4;
  double get small => 8;
  double get mediumSmall => 12;
  double get medium => 16;
  double get mediumLarge => 20;
  double get large => 24;
  double get huge => 32;
  double get hugeLarge => 48;
}

class OrbThemePalette {
  Color _brandColor;
  double _backgroundTranslucency;

  Color get blank => Color(0xFFFFFFFF);
  Color get blankTranslucent => blank.withOpacity(_backgroundTranslucency);
  Color get blankShadow => blank.withOpacity(0.44);
  Color get normal => Color(0xFF232323);
  Color get support => Color(0xFF4A4A4A);
  Color get neutral => Color(0xFFE6E9EF);
  Color get disabled => Color(0xFFEDEDED);
  Color get disabledDark => _darken(0.40, disabled);
  Color get outline => Color(0xFFB7B7B7);
  Color get brand => _brandColor;
  Color get brandTranslucent =>
      Color.lerp(blank, _brandColor, 0.2).withOpacity(_backgroundTranslucency);
  Color get brandShadow => Color.lerp(blank, _brandColor, 0.2).withOpacity(0.5);
  Color get brandNeutral => Color.lerp(blank, _brandColor, 0.095);
  Color get brandLight => _lighten(0.32, _brandColor);
  Color get brandDark => _darken(0.12, _brandColor);
  Color get error => Color(0xFFE02020);
  Color get errorShadow => Color(0x1AE02020);

  OrbThemePalette({Color brandColor, double backgroundTranslucency}) {
    _brandColor = brandColor ?? Color(0xFF4989EA);
    _backgroundTranslucency = backgroundTranslucency ?? 0.44;
  }

  Color _lighten(double amount, Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0, 1)).toColor();
  }

  Color _darken(double amount, Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0, 1)).toColor();
  }
}

class OrbThemeBorderRadius {
  Radius get none => Radius.zero;
  Radius get small => Radius.circular(12);
  Radius get medium => Radius.circular(22);
}

class OrbThemeInnerBorder {
  Border thin(Color color) => Border.all(width: 1, color: color);
  Border thick(Color color) => Border.all(width: 2, color: color);
  Border top(Color color) => Border(top: BorderSide(width: 1, color: color));
}

class OrbThemeOuterShadow {
  BoxShadow get tiny => BoxShadow(
        color: _shadow(0.03),
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: 0,
      );

  BoxShadow get small => BoxShadow(
        color: _shadow(0.12),
        offset: Offset(0, 2),
        blurRadius: 6,
        spreadRadius: 0,
      );

  BoxShadow get mediumDark => BoxShadow(
        color: _shadow(0.3),
        offset: Offset(0, 2),
        blurRadius: 12,
        spreadRadius: 0,
      );

  BoxShadow get large => BoxShadow(
        color: _shadow(0.1),
        offset: Offset(0, 2),
        blurRadius: 18,
        spreadRadius: 0,
      );

  Color _shadow(double opacity) {
    return Color(0xFF000000).withOpacity(opacity);
  }
}

class OrbThemeText {
  final OrbThemeTextFont font;
  final OrbThemeTextStyle style;
  final OrbThemeTextSize size;

  OrbThemeText._({
    @required this.font,
    @required this.style,
    @required this.size,
  });

  factory OrbThemeText() {
    final font = OrbThemeTextFont();
    final style = OrbThemeTextStyle();
    final size = OrbThemeTextSize();
    return OrbThemeText._(
      font: font,
      style: style,
      size: size,
    );
  }
}

class OrbThemeTextFont {
  TextStyle get normal => GoogleFonts.inter();
}

class OrbThemeTextStyle {
  TextStyle get normal => TextStyle(
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      );

  TextStyle get semibold => TextStyle(
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.none,
      );

  TextStyle get bold => TextStyle(
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.none,
      );

  TextStyle get italic => TextStyle(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      );
}

class OrbThemeTextSize {
  TextStyle get tiny => TextStyle(
        fontSize: 12,
        height: 18 / 12,
      );

  TextStyle get small => TextStyle(
        fontSize: 14,
        height: 20 / 14,
      );

  TextStyle get medium => TextStyle(
        fontSize: 16,
        height: 22 / 16,
      );

  TextStyle get large => TextStyle(
        fontSize: 24,
        height: 28 / 24,
      );

  TextStyle get huge => TextStyle(
        fontSize: 32,
        height: 36 / 32,
      );
}

class OrbThemeAvatar {
  double get width => 38;
  double get height => 38;
  double get radius => 19;
  double get semicircleRadius => 12;
  EdgeInsets get defaultMargin => EdgeInsets.only(
        top: 0,
        right: 10,
        bottom: 10,
        left: 5,
      );
}

class OrbTheme extends InheritedWidget {
  const OrbTheme({
    Key key,
    @required this.data,
    @required this.child,
  })  : assert(child != null),
        assert(data != null),
        super(key: key, child: child);

  final OrbThemeData data;
  final Widget child;

  static OrbThemeData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OrbTheme>().data;
  }

  Widget build(BuildContext context) {
    return child;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<OrbThemeData>('data', data, showName: false));
  }

  @override
  bool updateShouldNotify(OrbTheme old) => data != old.data;
}

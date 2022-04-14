import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:orb/theme_provider.dart';
import 'package:orb/ui/color.dart';

class OrbThemeConfigSpec {
  final String brandColor;
  final double backgroundTranslucency;

  const OrbThemeConfigSpec({
    required this.brandColor,
    required this.backgroundTranslucency,
  });

  const OrbThemeConfigSpec.init()
      : brandColor = '#4989EA',
        backgroundTranslucency = 0.44;

  OrbThemeConfigSpec copyWith({
    String? brandColor,
    double? backgroundTranslucency,
  }) =>
      OrbThemeConfigSpec(
        brandColor: brandColor ?? this.brandColor,
        backgroundTranslucency:
            backgroundTranslucency ?? this.backgroundTranslucency,
      );
}

class OrbTheme {
  final OrbThemePalette palette;
  final OrbThemeLengths lengths = OrbThemeLengths();
  final OrbThemeOuterShadow outerShadow = OrbThemeOuterShadow();
  final OrbThemeInnerBorder innerBorder = OrbThemeInnerBorder();
  final OrbThemeBorderRadius borderRadius = OrbThemeBorderRadius();
  final OrbThemeText text;
  final OrbThemeAvatar avatar = OrbThemeAvatar();
  final OrbThemeSize size = OrbThemeSize();
  final MarkdownStyleSheet markdownStyleSheet;

  OrbTheme(OrbThemeConfigSpec config)
      : this._(
          palette: OrbThemePalette(
            brandColor: HexColor.fromHex(config.brandColor)!,
            backgroundTranslucency: config.backgroundTranslucency,
          ),
          text: OrbThemeText(),
        );

  OrbTheme._({required this.palette, required this.text})
      : markdownStyleSheet = _createMarkdownStyleSheet(palette, text);

  ThemeData toMaterialThemeData() =>
      ThemeData(textTheme: GoogleFonts.interTextTheme());

  static OrbTheme of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<OrbThemeInherited>()!
        .theme;
  }

  Widget builder(BuildContext context, Widget? child) {
    return OrbThemeInherited(
      theme: this,
      child: child!,
    );
  }

  static MarkdownStyleSheet _createMarkdownStyleSheet(
    OrbThemePalette palette,
    OrbThemeText text,
  ) {
    final normal = text.font.normal
        .merge(text.style.normal)
        .merge(text.size.medium)
        .copyWith(color: palette.normal);
    return MarkdownStyleSheet(
      a: normal.copyWith(color: palette.brand),
      p: normal,
      code: normal.copyWith(fontFamily: 'courier'),
      h1: normal.merge(text.size.large),
      h2: normal.merge(text.size.mediumLarge),
      h3: normal.merge(text.size.medium),
      h4: normal.merge(text.size.small),
      h5: normal.merge(text.size.tiny),
      h6: normal.merge(text.size.superTiny),
      em: normal.merge(text.style.italic),
      strong: normal.merge(text.style.bold),
      del: normal.merge(text.style.lineThrough),
      blockquote: normal.merge(text.size.small),
      img: normal.merge(text.size.small),
      checkbox: normal.merge(text.size.small).copyWith(color: palette.brand),
      blockSpacing: 12.0,
      listIndent: 24.0,
      listBullet: normal.merge(text.size.small),
      listBulletPadding: const EdgeInsets.only(right: 4),
      tableHead: const TextStyle(fontWeight: FontWeight.w600),
      tableBody: normal.merge(text.size.small),
      tableHeadAlign: TextAlign.center,
      tableBorder: TableBorder.all(
        color: palette.brandNeutral,
        width: 1,
      ),
      tableColumnWidth: const FlexColumnWidth(),
      tableCellsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      tableCellsDecoration: const BoxDecoration(),
      blockquotePadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 18,
      ),
      blockquoteDecoration: BoxDecoration(
        color: palette.blank,
        border: Border(
          left: BorderSide(
            color: palette.disabled,
            width: 4.0,
          ),
        ),
      ),
      codeblockPadding: const EdgeInsets.all(8.0),
      codeblockDecoration: BoxDecoration(
        color: palette.blank,
        borderRadius: BorderRadius.circular(2.0),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 5.0,
            color: palette.normal,
          ),
        ),
      ),
      h1Align: WrapAlignment.start,
      h2Align: WrapAlignment.start,
      h3Align: WrapAlignment.start,
      h4Align: WrapAlignment.start,
      h5Align: WrapAlignment.start,
      h6Align: WrapAlignment.start,
      orderedListAlign: WrapAlignment.start,
      unorderedListAlign: WrapAlignment.start,
      blockquoteAlign: WrapAlignment.start,
      codeblockAlign: WrapAlignment.start,
      textAlign: WrapAlignment.start,
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
  final Color _brandColor;
  final double _backgroundTranslucency;

  Color get blank => const Color(0xFFFFFFFF);

  Color get blankTranslucent => blank.withOpacity(_backgroundTranslucency);

  Color get blankShadow => blank.withOpacity(0.44);

  Color get normal => const Color(0xFF232323);

  Color get support => const Color(0xFF4A4A4A);

  Color get disabled => const Color(0xFFEDEDED);

  Color get disabledDark => _darken(0.40, disabled);

  Color get outline => const Color(0xFFB7B7B7);

  Color get brand => _brandColor;

  Color get brandTranslucent =>
      Color.lerp(blank, _brandColor, 0.2)!.withOpacity(_backgroundTranslucency);

  Color get brandShadow =>
      Color.lerp(blank, _brandColor, 0.2)!.withOpacity(0.5);

  Color get brandNeutral => Color.lerp(blank, _brandColor, 0.095)!;

  Color get brandLight => _lighten(0.32, _brandColor);

  Color get brandDark => _darken(0.12, _brandColor);

  Color get error => const Color(0xFFE02020);

  Color get errorShadow => const Color(0x1AE02020);

  OrbThemePalette({
    required Color brandColor,
    required double backgroundTranslucency,
  })  : _brandColor = brandColor,
        _backgroundTranslucency = backgroundTranslucency;

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

  Radius get small => const Radius.circular(12);

  Radius get medium => const Radius.circular(22);
}

class OrbThemeInnerBorder {
  Border thin(Color color) => Border.all(width: 1, color: color);

  Border thick(Color color) => Border.all(width: 2, color: color);

  Border top(Color color) => Border(top: BorderSide(width: 1, color: color));
}

class OrbThemeOuterShadow {
  BoxShadow get tiny => BoxShadow(
        color: _shadow(0.03),
        offset: const Offset(0, 2),
        blurRadius: 4,
        spreadRadius: 0,
      );

  BoxShadow get small => BoxShadow(
        color: _shadow(0.12),
        offset: const Offset(0, 2),
        blurRadius: 6,
        spreadRadius: 0,
      );

  BoxShadow get mediumDark => BoxShadow(
        color: _shadow(0.3),
        offset: const Offset(0, 2),
        blurRadius: 12,
        spreadRadius: 0,
      );

  BoxShadow get large => BoxShadow(
        color: _shadow(0.1),
        offset: const Offset(0, 2),
        blurRadius: 18,
        spreadRadius: 0,
      );

  Color _shadow(double opacity) {
    return const Color(0xFF000000).withOpacity(opacity);
  }
}

class OrbThemeText {
  final OrbThemeTextFont font;
  final OrbThemeTextStyle style;
  final OrbThemeTextSize size;

  OrbThemeText()
      : font = OrbThemeTextFont(),
        style = OrbThemeTextStyle(),
        size = OrbThemeTextSize();
}

class OrbThemeTextFont {
  TextStyle get normal => GoogleFonts.inter();
}

class OrbThemeTextStyle {
  TextStyle get normal => const TextStyle(
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      );

  TextStyle get semibold => const TextStyle(
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.none,
      );

  TextStyle get bold => const TextStyle(
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.none,
      );

  TextStyle get italic => const TextStyle(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      );

  TextStyle get lineThrough => const TextStyle(
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.lineThrough,
      );
}

class OrbThemeTextSize {
  TextStyle get superTiny => const TextStyle(
        fontSize: 10,
        height: 16 / 10,
      );

  TextStyle get tiny => const TextStyle(
        fontSize: 12,
        height: 18 / 12,
      );

  TextStyle get small => const TextStyle(
        fontSize: 14,
        height: 20 / 14,
      );

  TextStyle get medium => const TextStyle(
        fontSize: 16,
        height: 24 / 16,
      );

  TextStyle get mediumLarge => const TextStyle(
        fontSize: 20,
        height: 28 / 20,
      );

  TextStyle get large => const TextStyle(
        fontSize: 24,
        height: 32 / 24,
      );

  TextStyle get huge => const TextStyle(
        fontSize: 32,
        height: 40 / 32,
      );
}

class OrbThemeAvatar {
  double get width => 38;

  double get height => 38;

  double get radius => 19;

  double get semicircleRadius => 12;

  EdgeInsets get defaultMargin => const EdgeInsets.only(
        top: 0,
        right: 10,
        bottom: 10,
        left: 5,
      );
}

class OrbThemeSize {
  final OrbThemeIconSize icon = OrbThemeIconSize();
}

class OrbThemeIconSize {
  double get small => 16;

  double get medium => 24;

  double get large => 32;

  double get huge => 48;
}

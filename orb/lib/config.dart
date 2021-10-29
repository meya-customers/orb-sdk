import 'package:flutter/foundation.dart';

import 'package:orb/ui/design.dart';

class OrbConfig extends ChangeNotifier {
  OrbThemeData orbThemeData;
  ThemeConfigSpec theme;
  ComposerConfigSpec composer;
  SplashConfigSpec splash;

  OrbConfig._({
    required this.orbThemeData,
    required this.theme,
    required this.composer,
    required this.splash,
  });

  factory OrbConfig({
    required ThemeConfigSpec theme,
    required ComposerConfigSpec composer,
    required SplashConfigSpec splash,
    OrbThemeData? orbThemeData,
  }) {
    return OrbConfig._(
      orbThemeData:
          orbThemeData ?? OrbThemeData.fromThemeConfigSpec(theme: theme),
      theme: theme,
      composer: composer,
      splash: splash,
    );
  }

  factory OrbConfig.init() => OrbConfig(
        theme: ThemeConfigSpec(brandColor: '#4989EA'),
        composer: ComposerConfigSpec(
          placeholderText: 'Type a message',
          collapsePlaceholderText: 'Have something else to say?',
          fileButtonText: 'File',
          fileSendText: 'Send ',
          imageButtonText: 'Photo',
          cameraButtonText: 'Camera',
          galleryButtonText: 'Gallery',
        ),
        splash: SplashConfigSpec(readyText: 'Ready to start'),
      );

  void update({
    required ThemeConfigSpec theme,
    required ComposerConfigSpec composer,
    required SplashConfigSpec splash,
  }) {
    theme = theme.copyWith(
      brandColor: theme.brandColor,
      backgroundTranslucency: theme.backgroundTranslucency,
    );
    composer = composer.copyWith(
      placeholderText: composer.placeholderText,
      collapsePlaceholderText: composer.collapsePlaceholderText,
      fileButtonText: composer.fileButtonText,
      fileSendText: composer.fileSendText,
      imageButtonText: composer.imageButtonText,
      cameraButtonText: composer.cameraButtonText,
      galleryButtonText: composer.galleryButtonText,
    );
    splash = splash.copyWith(readyText: splash.readyText);
    orbThemeData = OrbThemeData.fromThemeConfigSpec(theme: theme);
    notifyListeners();
  }
}

class ThemeConfigSpec {
  final String? brandColor;
  final double? backgroundTranslucency;

  ThemeConfigSpec({
    this.brandColor,
    this.backgroundTranslucency,
  });

  ThemeConfigSpec copyWith({
    String? brandColor,
    double? backgroundTranslucency,
  }) =>
      ThemeConfigSpec(
        brandColor: brandColor ?? this.brandColor,
        backgroundTranslucency:
            backgroundTranslucency ?? this.backgroundTranslucency,
      );
}

class ComposerConfigSpec {
  final String? placeholderText;
  final String? collapsePlaceholderText;
  final String? fileButtonText;
  final String? fileSendText;
  final String? imageButtonText;
  final String? cameraButtonText;
  final String? galleryButtonText;

  ComposerConfigSpec({
    this.placeholderText,
    this.collapsePlaceholderText,
    this.fileButtonText,
    this.fileSendText,
    this.imageButtonText,
    this.cameraButtonText,
    this.galleryButtonText,
  });

  ComposerConfigSpec copyWith({
    String? placeholderText,
    String? collapsePlaceholderText,
    String? fileButtonText,
    String? fileSendText,
    String? imageButtonText,
    String? cameraButtonText,
    String? galleryButtonText,
  }) =>
      ComposerConfigSpec(
        placeholderText: placeholderText ?? this.placeholderText,
        collapsePlaceholderText:
            collapsePlaceholderText ?? this.collapsePlaceholderText,
        fileButtonText: fileButtonText ?? this.fileButtonText,
        fileSendText: fileSendText ?? this.fileSendText,
        imageButtonText: imageButtonText ?? this.imageButtonText,
        cameraButtonText: cameraButtonText ?? this.cameraButtonText,
        galleryButtonText: galleryButtonText ?? this.galleryButtonText,
      );
}

class SplashConfigSpec {
  final String? readyText;

  SplashConfigSpec({this.readyText});

  SplashConfigSpec copyWith({String? readyText}) =>
      SplashConfigSpec(readyText: readyText ?? this.readyText);
}

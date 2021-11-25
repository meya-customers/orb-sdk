import 'package:flutter/foundation.dart';

import 'package:orb/ui/design.dart';

class OrbConfig extends ChangeNotifier {
  OrbThemeData orbThemeData;
  ThemeConfigSpec theme;
  ComposerConfigSpec composer;
  SplashConfigSpec splash;
  MediaUploadConfigSpec mediaUpload;

  OrbConfig._({
    required OrbThemeData? orbThemeData,
    required this.theme,
    required this.composer,
    required this.splash,
    required this.mediaUpload,
  }) : orbThemeData =
            orbThemeData ?? OrbThemeData.fromThemeConfigSpec(theme: theme);

  factory OrbConfig.init({
    OrbThemeData? orbThemeData,
    ThemeConfigSpec? theme,
    ComposerConfigSpec? composer,
    SplashConfigSpec? splash,
    MediaUploadConfigSpec? mediaUpload,
  }) =>
      OrbConfig._(
        orbThemeData: orbThemeData,
        theme: theme ?? ThemeConfigSpec(brandColor: '#4989EA'),
        composer: composer ??
            ComposerConfigSpec(
              placeholderText: 'Type a message',
              collapsePlaceholderText: 'Have something else to say?',
              fileButtonText: 'File',
              fileSendText: 'Send ',
              imageButtonText: 'Photo',
              cameraButtonText: 'Camera',
              galleryButtonText: 'Gallery',
            ),
        splash: splash ?? SplashConfigSpec(readyText: 'Ready to start'),
        mediaUpload: mediaUpload ?? MediaUploadConfigSpec(),
      );

  void update({
    ThemeConfigSpec? theme,
    ComposerConfigSpec? composer,
    SplashConfigSpec? splash,
    MediaUploadConfigSpec? mediaUpload,
  }) {
    if (theme != null) {
      this.theme = theme.copyWith(
        brandColor: theme.brandColor,
        backgroundTranslucency: theme.backgroundTranslucency,
      );
    }
    if (composer != null) {
      this.composer = composer.copyWith(
        placeholderText: composer.placeholderText,
        collapsePlaceholderText: composer.collapsePlaceholderText,
        fileButtonText: composer.fileButtonText,
        fileSendText: composer.fileSendText,
        imageButtonText: composer.imageButtonText,
        cameraButtonText: composer.cameraButtonText,
        galleryButtonText: composer.galleryButtonText,
      );
    }
    if (splash != null) {
      this.splash = splash.copyWith(readyText: splash.readyText);
    }
    if (mediaUpload != null) {
      this.mediaUpload = mediaUpload.copyWith(
          all: mediaUpload.all,
          image: mediaUpload.image,
          file: mediaUpload.file);
    }
    orbThemeData = OrbThemeData.fromThemeConfigSpec(theme: this.theme);
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

class MediaUploadConfigSpec {
  final bool? all;
  final bool? file;
  final bool? image;

  MediaUploadConfigSpec({this.all, this.file, this.image});

  MediaUploadConfigSpec copyWith({bool? all, bool? file, bool? image}) =>
      MediaUploadConfigSpec(
          all: all ?? this.all,
          file: file ?? this.file,
          image: image ?? this.image);
}

class MediaUploadConfigResult {
  final bool any;
  final bool file;
  final bool image;

  MediaUploadConfigResult._(
      {required this.any, required this.file, required this.image});

  factory MediaUploadConfigResult.resolve(MediaUploadConfigSpec mediaUpload) {
    final image = mediaUpload.image ?? mediaUpload.all ?? true;
    final file = mediaUpload.file ?? mediaUpload.all ?? true;
    final any = image || file;
    return MediaUploadConfigResult._(any: any, file: file, image: image);
  }
}

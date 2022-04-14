import 'package:flutter/widgets.dart';

import 'package:orb/config_provider.dart';
import 'package:orb/design.dart';
import 'package:orb/event.dart';

class OrbUiConfigSpec {
  final bool visible;

  const OrbUiConfigSpec({
    required this.visible,
  });

  const OrbUiConfigSpec.init() : visible = false;

  OrbUiConfigSpec copyWith({
    bool? visible,
  }) =>
      OrbUiConfigSpec(
        visible: visible ?? this.visible,
      );
}

class OrbComposerConfigSpec {
  final OrbComposerFocus? focus;
  final String? placeholder;
  final String? collapsePlaceholder;
  final OrbComposerVisibility? visibility;
  final String placeholderText;
  final String collapsePlaceholderText;
  final String fileButtonText;
  final String fileSendText;
  final String imageButtonText;
  final String cameraButtonText;
  final String galleryButtonText;

  const OrbComposerConfigSpec({
    required this.focus,
    required this.placeholder,
    required this.collapsePlaceholder,
    required this.visibility,
    required this.placeholderText,
    required this.collapsePlaceholderText,
    required this.fileButtonText,
    required this.fileSendText,
    required this.imageButtonText,
    required this.cameraButtonText,
    required this.galleryButtonText,
  });

  const OrbComposerConfigSpec.init()
      : focus = null,
        placeholder = null,
        collapsePlaceholder = null,
        visibility = null,
        placeholderText = 'Type a message',
        collapsePlaceholderText = 'Have something else to say?',
        fileButtonText = 'File',
        fileSendText = 'Send ',
        imageButtonText = 'Photo',
        cameraButtonText = 'Camera',
        galleryButtonText = 'Gallery';

  OrbComposerConfigSpec copyWith({
    OrbComposerFocus? focus,
    String? placeholder,
    String? collapsePlaceholder,
    OrbComposerVisibility? visibility,
    String? placeholderText,
    String? collapsePlaceholderText,
    String? fileButtonText,
    String? fileSendText,
    String? imageButtonText,
    String? cameraButtonText,
    String? galleryButtonText,
  }) =>
      OrbComposerConfigSpec(
        focus: focus ?? this.focus,
        placeholder: placeholder ?? this.placeholder,
        collapsePlaceholder: collapsePlaceholder ?? this.collapsePlaceholder,
        visibility: visibility ?? this.visibility,
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

class OrbHeaderConfigSpec {
  final List<dynamic> buttons;
  final OrbHeaderTitleEventSpec title;
  final OrbHeaderProgressEventSpec progress;
  final List<dynamic> milestones;
  final List<dynamic> extraButtons;

  const OrbHeaderConfigSpec({
    required this.buttons,
    required this.title,
    required this.progress,
    required this.milestones,
    required this.extraButtons,
  });

  const OrbHeaderConfigSpec.init()
      : buttons = const [],
        title = const OrbHeaderTitleEventSpec(),
        progress = const OrbHeaderProgressEventSpec(),
        milestones = const [],
        extraButtons = const [];

  OrbHeaderConfigSpec copyWith({
    List<dynamic>? buttons,
    OrbHeaderTitleEventSpec? title,
    OrbHeaderProgressEventSpec? progress,
    List<dynamic>? milestones,
    List<dynamic>? extraButtons,
  }) =>
      OrbHeaderConfigSpec(
        buttons: buttons ?? this.buttons,
        title: title ?? this.title,
        progress: progress ?? this.progress,
        milestones: milestones ?? this.milestones,
        extraButtons: extraButtons ?? this.extraButtons,
      );
}

class OrbMenuConfigSpec {
  final String closeText;
  final String backText;

  const OrbMenuConfigSpec({required this.closeText, required this.backText});

  const OrbMenuConfigSpec.init()
      : closeText = 'Close',
        backText = 'Back';

  OrbMenuConfigSpec copyWith({String? closeText, String? backText}) =>
      OrbMenuConfigSpec(
        closeText: closeText ?? this.closeText,
        backText: backText ?? this.backText,
      );
}

class OrbSplashConfigSpec {
  final String readyText;

  const OrbSplashConfigSpec({required this.readyText});

  const OrbSplashConfigSpec.init() : readyText = 'Loading, please wait...';

  OrbSplashConfigSpec copyWith({String? readyText}) =>
      OrbSplashConfigSpec(readyText: readyText ?? this.readyText);
}

class OrbMediaUploadConfigSpec {
  final bool? all;
  final bool? file;
  final bool? image;

  const OrbMediaUploadConfigSpec({
    required this.all,
    required this.file,
    required this.image,
  });

  const OrbMediaUploadConfigSpec.init()
      : all = null,
        file = null,
        image = null;

  OrbMediaUploadConfigSpec copyWith({bool? all, bool? file, bool? image}) =>
      OrbMediaUploadConfigSpec(
        all: all ?? this.all,
        file: file ?? this.file,
        image: image ?? this.image,
      );
}

class OrbMediaUploadConfigResult {
  final bool any;
  final bool file;
  final bool image;

  const OrbMediaUploadConfigResult._({
    required this.any,
    required this.file,
    required this.image,
  });

  factory OrbMediaUploadConfigResult.resolve(
    OrbMediaUploadConfigSpec mediaUpload,
  ) {
    final image = mediaUpload.image ?? mediaUpload.all ?? true;
    final file = mediaUpload.file ?? mediaUpload.all ?? true;
    final any = image || file;
    return OrbMediaUploadConfigResult._(any: any, file: file, image: image);
  }
}

class OrbConfig {
  final OrbThemeConfigSpec theme;
  final OrbUiConfigSpec ui;
  final OrbComposerConfigSpec composer;
  final OrbHeaderConfigSpec header;
  final OrbMenuConfigSpec menu;
  final OrbSplashConfigSpec splash;
  final OrbMediaUploadConfigSpec mediaUpload;

  const OrbConfig({
    required this.theme,
    required this.ui,
    required this.composer,
    required this.header,
    required this.menu,
    required this.splash,
    required this.mediaUpload,
  });

  const OrbConfig.init()
      : theme = const OrbThemeConfigSpec.init(),
        ui = const OrbUiConfigSpec.init(),
        composer = const OrbComposerConfigSpec.init(),
        header = const OrbHeaderConfigSpec.init(),
        menu = const OrbMenuConfigSpec.init(),
        splash = const OrbSplashConfigSpec.init(),
        mediaUpload = const OrbMediaUploadConfigSpec.init();

  OrbConfig copyWith({
    OrbThemeConfigSpec? theme,
    OrbUiConfigSpec? ui,
    OrbComposerConfigSpec? composer,
    OrbHeaderConfigSpec? header,
    OrbMenuConfigSpec? menu,
    OrbSplashConfigSpec? splash,
    OrbMediaUploadConfigSpec? mediaUpload,
  }) =>
      OrbConfig(
        theme: theme ?? this.theme,
        ui: ui ?? this.ui,
        composer: composer ?? this.composer,
        header: header ?? this.header,
        menu: menu ?? this.menu,
        splash: splash ?? this.splash,
        mediaUpload: mediaUpload ?? this.mediaUpload,
      );

  static OrbConfig of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<OrbConfigInherited>()!
        .config;
  }
}

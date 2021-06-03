import 'package:meta/meta.dart';

enum OrbAvatarCrop { circle, square }

extension OrbAvatarCropExtension on OrbAvatarCrop {
  static OrbAvatarCrop fromString(String crop) =>
      {
        'circle': OrbAvatarCrop.circle,
        'square': OrbAvatarCrop.square,
      }[crop] ??
      OrbAvatarCrop.circle;
}

class OrbAvatar {
  final String image;
  final OrbAvatarCrop crop;
  final String monogram;

  OrbAvatar({
    @required this.image,
    @required this.crop,
    @required this.monogram,
  });

  factory OrbAvatar.fromMap(Map<dynamic, dynamic> map) {
    if (map == null) return null;
    return OrbAvatar(
      image: map['image'],
      crop: OrbAvatarCropExtension.fromString(map['crop']),
      monogram: map['monogram'],
    );
  }
}

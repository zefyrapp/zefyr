import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

class EditProfileRequest {
  const EditProfileRequest({
    required this.name,
    required this.nickname,
    required this.bio,
    this.avatar,
  });
  factory EditProfileRequest.fromMap(Map<String, dynamic> map) =>
      EditProfileRequest(
        name: map['full_name'] as String,
        nickname: map['nickname'] as String,
        bio: map['bio'] as String,
        avatar: map['avatar'] as File?,
      );

  factory EditProfileRequest.fromJson(String source) =>
      EditProfileRequest.fromMap(json.decode(source) as Map<String, dynamic>);
  final String name;
  final String nickname;
  final String bio;
  final File? avatar;
  EditProfileRequest copyWith({
    String? name,
    String? nickname,
    String? bio,
    File? avatar,
  }) => EditProfileRequest(
    name: name ?? this.name,
    nickname: nickname ?? this.nickname,
    bio: bio ?? this.bio,
    avatar: avatar ?? this.avatar,
  );

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'full_name': name,
      'bio': bio,
      'nickname': nickname,
    };

    // Добавляем файл аватара
    if (avatar != null) {
      map['avatar'] = MultipartFile.fromFileSync(
        avatar!.path,
        filename: avatar!.path.split('/').last, // Берем имя файла из пути
      );
    }

    return map;
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'EditProfileRequest(name: $name, nickname: $nickname, bio: $bio, avatar: $avatar)';

  @override
  bool operator ==(covariant EditProfileRequest other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.nickname == nickname &&
        other.bio == bio &&
        other.avatar == avatar;
  }

  @override
  int get hashCode =>
      name.hashCode ^ nickname.hashCode ^ bio.hashCode ^ avatar.hashCode;
}

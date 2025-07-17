// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class EditProfileRequest {
  const EditProfileRequest({
    required this.name,
    required this.nickname,
    required this.bio,
  });
  final String name;
  final String nickname;
  final String bio;

  EditProfileRequest copyWith({String? name, String? nickname, String? bio}) =>
      EditProfileRequest(
        name: name ?? this.name,
        nickname: nickname ?? this.nickname,
        bio: bio ?? this.bio,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'full_name': name,
    'nickname': nickname,
    'bio': bio,
  };

  factory EditProfileRequest.fromMap(Map<String, dynamic> map) =>
      EditProfileRequest(
        name: map['name'] as String,
        nickname: map['nickname'] as String,
        bio: map['bio'] as String,
      );

  String toJson() => json.encode(toMap());

  factory EditProfileRequest.fromJson(String source) =>
      EditProfileRequest.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'EditProfileRequest(name: $name, nickname: $nickname, bio: $bio)';

  @override
  bool operator ==(covariant EditProfileRequest other) {
    if (identical(this, other)) return true;

    return other.name == name && other.nickname == nickname && other.bio == bio;
  }

  @override
  int get hashCode => name.hashCode ^ nickname.hashCode ^ bio.hashCode;
}

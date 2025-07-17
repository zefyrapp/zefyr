import 'dart:convert';
import 'package:zefyr/features/profile/data/models/profile_model.dart';

class ProfileResponse {
  const ProfileResponse({
    required this.profile,
    required this.success,
    this.message,
  });
  factory ProfileResponse.fromJson(String source) =>
      ProfileResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  factory ProfileResponse.fromMap(Map<String, dynamic> map) => ProfileResponse(
    profile: ProfileModel.fromMap(map['data'] as Map<String, dynamic>),
    success: map['success'] as bool? ?? true,
    message: map['message'] as String?,
  );

  final ProfileModel profile;
  final bool success;
  final String? message;

  Map<String, dynamic> toMap() => {
    'profile': profile.toMap(),
    'success': success,
    'message': message,
  };

  String toJson() => json.encode(toMap());
}

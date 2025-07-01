import 'dart:convert';

import 'package:zefyr/features/auth/data/models/user_model.dart';

class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  factory AuthResponse.fromMap(Map<String, dynamic> map) => AuthResponse(
    accessToken: map['access_token'] as String,
    refreshToken: map['refresh_token'] as String,
    user: UserModel.fromJson(map['user'] as Map<String, dynamic>),
  );

  factory AuthResponse.fromJson(String source) =>
      AuthResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  final String accessToken;
  final String refreshToken;
  final UserModel? user;

  AuthResponse copyWith({
    String? accessToken,
    String? refreshToken,
    UserModel? user,
  }) => AuthResponse(
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    user: user ?? this.user,
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'user': user?.toJson(),
  };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'AuthResponse(accessToken: $accessToken, refreshToken: $refreshToken, user: $user)';

  @override
  bool operator ==(covariant AuthResponse other) {
    if (identical(this, other)) return true;

    return other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.user == user;
  }

  @override
  int get hashCode =>
      accessToken.hashCode ^ refreshToken.hashCode ^ user.hashCode;
}

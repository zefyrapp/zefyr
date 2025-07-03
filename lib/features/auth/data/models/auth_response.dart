import 'dart:convert';

import 'package:zefyr/core/database/database.dart';
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
    user: map['user'] != null
        ? UserModel.fromJson(map['user'] as Map<String, dynamic>)
        : null,
  );

  factory AuthResponse.fromJson(String source) =>
      AuthResponse.fromMap(json.decode(source) as Map<String, dynamic>);
  factory AuthResponse.fromDrift({
    required User userRow,
    required AuthToken tokenRow,
  }) => AuthResponse(
    accessToken: tokenRow.accessToken,
    refreshToken: tokenRow.refreshToken,
    user: UserModel.fromDrift(userRow),
  );

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

  // /// Проверяет, истек ли токен
  // bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  // /// Проверяет, скоро ли истечет токен (за 5 минут до истечения)
  // bool get isExpiringSoon {
  //   if (expiresAt == null) return false;
  //   final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
  //   return fiveMinutesFromNow.isAfter(expiresAt!);
  // }

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

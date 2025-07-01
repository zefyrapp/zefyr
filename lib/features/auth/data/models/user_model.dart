import 'package:zefyr/core/database/database.dart';
import 'package:zefyr/features/auth/domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required this.isActive,
    super.name,
    super.avatar,
    this.lastActive,
  });
  factory UserModel.fromDrift(User row) => UserModel(
    id: row.id.toString(),
    email: row.email,

    isActive: row.isActive ?? false,
    lastActive: row.lastActive,
  );
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    email: json['email'] as String,
    name: json['name'] as String?,
    avatar: json['avatar'] as String?,
    isActive: json['is_active'] as bool? ?? false,
    lastActive: json['last_active'] != null
        ? DateTime.parse(json['last_active'] as String)
        : null,
  );
  final bool isActive;
  final DateTime? lastActive;
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,

    'is_active': isActive,
    'last_active': lastActive?.toIso8601String(),
  };
}

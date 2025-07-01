import 'package:zefyr/core/database/database.dart';
import 'package:zefyr/features/auth/domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    email: json['email'] as String,
    name: json['name'] as String,
    avatar: json['avatar'] as String?,
  );
  factory UserModel.fromDrift(User row) => UserModel(
    id: row.id.toString(),
    email: row.email,
    name: row.name ?? '',
    // остальные поля
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'avatar': avatar,
  };
}

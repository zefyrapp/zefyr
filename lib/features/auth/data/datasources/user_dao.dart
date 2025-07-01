import 'package:drift/drift.dart';
import 'package:zefyr/core/database/database.dart';
import 'package:zefyr/features/auth/data/models/auth_response.dart';
import 'package:zefyr/features/auth/data/models/user_model.dart';

class UserDao {
  const UserDao(this.db);
  final AppDatabase db;

  Future<void> insertOrUpdateUser(AuthResponse user) async {
    await db.into(db.users).insertOnConflictUpdate(user.toCompanion());
  }

  Future<AuthResponse?> getUser() async {
    final row = await db.select(db.users).getSingleOrNull();
    return row == null ? null : AuthResponse.fromDrift(row);
  }

  Future<void> clearUser() async {
    await db.delete(db.users).go();
  }
}

// Маппинг UserModel <-> Drift Companion
extension UserModelDrift on UserModel {
  UsersCompanion toCompanion() => UsersCompanion(
    id: Value(int.tryParse(id) ?? 0),
    email: Value(email),
    name: Value(name),
    // остальные поля
  );

  static UserModel fromDrift(User row) => UserModel(
    id: row.id.toString(),
    email: row.email,
    name: row.name ?? '',
    // остальные поля
  );
}

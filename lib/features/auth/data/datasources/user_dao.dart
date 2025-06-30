import 'package:drift/drift.dart';
import 'package:zifyr/core/database/database.dart';
import 'package:zifyr/features/auth/data/models/user_model.dart';

class UserDao {
  const UserDao(this.db);
  final AppDatabase db;

  Future<void> insertOrUpdateUser(UserModel user) async {
    await db.into(db.users).insertOnConflictUpdate(user.toCompanion());
  }

  Future<UserModel?> getUser() async {
    final row = await db.select(db.users).getSingleOrNull();
    return row == null ? null : UserModel.fromDrift(row);
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

import 'package:drift/drift.dart';
import 'package:zefyr/core/database/database.dart';
import 'package:zefyr/features/auth/data/models/auth_response.dart';
import 'package:zefyr/features/auth/data/models/user_model.dart';

class UserDao {
  const UserDao(this.db);
  final AppDatabase db;

  // Сохраняет/обновляет данные аутентификации (пользователь + токены)
  Future<void> insertOrUpdateUser(AuthResponse authResponse) async {
    await db.transaction(() async {
      // Сначала сохраняем/обновляем пользователя
      final user = authResponse.user;
      if (user != null) {
        await db.into(db.users).insertOnConflictUpdate(user.toUsersCompanion());

        // Получаем ID пользователя
        final userId = int.tryParse(user.id) ?? 0;

        // Затем сохраняем/обновляем токены
        await db
            .into(db.authTokens)
            .insertOnConflictUpdate(
              AuthTokensCompanion(
                userId: Value(userId),
                accessToken: Value(authResponse.accessToken),
                refreshToken: Value(authResponse.refreshToken),
              ),
            );
      }
    });
  }

  /// Получает полные данные аутентификации
  Future<AuthResponse?> getUser() async {
    final query = db.select(db.users).join([
      leftOuterJoin(db.authTokens, db.authTokens.userId.equalsExp(db.users.id)),
    ]);

    final result = await query.getSingleOrNull();
    if (result == null) return null;

    final userRow = result.readTable(db.users);
    final tokenRow = result.readTableOrNull(db.authTokens);

    if (tokenRow == null) return null;

    return AuthResponse(
      accessToken: tokenRow.accessToken,
      refreshToken: tokenRow.refreshToken,
      user: UserModel.fromDrift(userRow),
    );
  }

  /// Получает только данные пользователя без токенов
  Future<UserModel?> getUserOnly() async {
    final row = await db.select(db.users).getSingleOrNull();
    return row == null ? null : UserModel.fromDrift(row);
  }

  /// Получает только данные пользователя без токенов
  /// Стрим, отслеживающий изменения пользователя без токенов
  Stream<UserModel?> watchUserOnly() => db
        .select(db.users)
        .watchSingleOrNull()
        .map((row) => row == null ? null : UserModel.fromDrift(row));

  /// Получает только токены без данных пользователя
  Future<AuthToken?> getTokensOnly() async =>
      db.select(db.authTokens).getSingleOrNull();

  /// Обновляет только токены (полезно при refresh)
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? expiresAt,
  }) async {
    await (db.update(db.authTokens)..where((tbl) => tbl.id.isNotNull())).write(
      AuthTokensCompanion(
        accessToken: Value(accessToken),
        refreshToken: Value(refreshToken),
      ),
    );
  }

  /// Очищает все данные пользователя и токены
  Future<void> clearUser() async {
    await db.transaction(() async {
      await db.delete(db.authTokens).go();
      await db.delete(db.users).go();
    });
  }

  /// Очищает только токены, оставляя данные пользователя
  Future<void> clearTokens() async {
    await db.delete(db.authTokens).go();
  }
}

// Маппинг UserModel <-> Drift Companion
// Расширения для маппинга
extension UserModelDrift on UserModel {
  UsersCompanion toUsersCompanion() => UsersCompanion(
    id: Value(int.tryParse(id) ?? 0),
    email: Value(email),
    lastActive: Value(lastActive),
  );
}

extension AuthResponseDrift on AuthResponse {
  AuthTokensCompanion toAuthTokensCompanion(int userId) => AuthTokensCompanion(
    userId: Value(userId),
    accessToken: Value(accessToken),
    refreshToken: Value(refreshToken),
  );
}

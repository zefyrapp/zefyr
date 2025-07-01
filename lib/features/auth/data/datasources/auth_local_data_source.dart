import 'package:zefyr/features/auth/data/datasources/user_dao.dart';
import 'package:zefyr/features/auth/data/models/auth_response.dart';
import 'package:zefyr/features/auth/data/models/user_model.dart';
import 'package:zefyr/features/auth/domain/entities/user.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(AuthResponse user);
  Future<void> clearCache();
  Future<AuthResponse?> getCachedUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this.userDao);
  final UserDao userDao;

  @override
  Future<void> cacheUser(AuthResponse user) => userDao.insertOrUpdateUser(user);

  @override
  Future<void> clearCache() => userDao.clearUser();

  @override
  Future<AuthResponse?> getCachedUser() async {
    final user = await userDao.getUser();
    return user;
  }
}

import 'package:zifyr/features/auth/data/datasources/user_dao.dart';
import 'package:zifyr/features/auth/data/models/user_model.dart';
import 'package:zifyr/features/auth/domain/entities/user.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<void> clearCache();
  Future<UserEntity?> getCachedUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this.userDao);
  final UserDao userDao;

  @override
  Future<void> cacheUser(UserModel user) => userDao.insertOrUpdateUser(user);

  @override
  Future<void> clearCache() => userDao.clearUser();

  @override
  Future<UserEntity?> getCachedUser() async {
    final user = await userDao.getUser();
    return user;
  }
}

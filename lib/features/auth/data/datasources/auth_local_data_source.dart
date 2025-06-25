
import 'package:zifyr/features/auth/data/models/user_model.dart';
import 'package:zifyr/features/auth/domain/entities/user.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<void> clearCache();
  Future<User?> getCachedUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl();

  @override
  Future<void> cacheUser(UserModel user) {
    // TODO: implement cacheUser
    throw UnimplementedError();
  }

  @override
  Future<void> clearCache() {
    // TODO: implement clearCache
    throw UnimplementedError();
  }

  @override
  Future<User?> getCachedUser() {
    // TODO: implement getCachedUser
    throw UnimplementedError();
  }
}

import 'package:zefyr/features/auth/data/datasources/user_dao.dart';
import 'package:zefyr/features/auth/data/models/auth_response.dart';
import 'package:zefyr/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(AuthResponse authResponse);
  Future<void> clearCache();
  Future<AuthResponse?> getCachedUser();
  Future<UserModel?> getCachedUserOnly();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<bool> isAuthenticated();
  Future<void> updateTokens(AuthResponse authResponse);
  Stream<UserModel?> watchUserOnly();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this.userDao);
  final UserDao userDao;

  @override
  Future<void> cacheUser(AuthResponse authResponse) =>
      userDao.insertOrUpdateUser(authResponse);

  @override
  Future<void> clearCache() => userDao.clearUser();

  @override
  Future<AuthResponse?> getCachedUser() async => userDao.getUser();

  @override
  Future<UserModel?> getCachedUserOnly() async => userDao.getUserOnly();

  @override
  Future<String?> getAccessToken() async {
    final authResponse = await getCachedUser();
    return authResponse?.accessToken;
  }

  @override
  Future<String?> getRefreshToken() async {
    final authResponse = await getCachedUser();
    return authResponse?.refreshToken;
  }

  @override
  Future<bool> isAuthenticated() async {
    final authResponse = await getCachedUser();
    if (authResponse == null) return false;
    //return !authResponse.isExpired;

    return authResponse.user != null;
  }

  @override
  Future<void> updateTokens(AuthResponse authResponse) async {
    await userDao.updateTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );
  }

  @override
  Stream<UserModel?> watchUserOnly() => userDao.watchUserOnly();
}

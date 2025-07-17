import 'package:zefyr/features/auth/data/datasources/user_dao.dart';
import 'package:zefyr/features/auth/data/models/auth_response.dart';

/// Сервис для управления токенами аутентификации
class TokenManager {
  TokenManager(this._userDao);

  final UserDao _userDao;

  /// Сохраняет токены и данные пользователя
  Future<void> saveAuthData(AuthResponse authResponse) async {
    await _userDao.insertOrUpdateUser(authResponse);
  }

  /// Получает сохраненные данные аутентификации
  Future<AuthResponse?> getAuthData() async => _userDao.getUser();

  /// Обновляет только токены (используется при refresh)
  Future<void> updateTokens(AuthResponse newAuthResponse) async {
    await _userDao.updateTokens(
      accessToken: newAuthResponse.accessToken,
      refreshToken: newAuthResponse.refreshToken,
    );
  }

  // /// Проверяет, есть ли действующий токен
  // Future<bool> hasValidToken() async {
  //   final authData = await getAuthData();
  //   if (authData == null) return false;

  //   return !authData.isExpired;
  // }

  // /// Проверяет, нужно ли обновить токен
  // Future<bool> shouldRefreshToken() async {
  //   final authData = await getAuthData();
  //   if (authData == null) return false;

  //   return authData.isExpiringSoon;
  // }

  /// Получает текущий access token
  Future<String?> getAccessToken() async {
    final tokens = await _userDao.getTokensOnly();
    return tokens?.accessToken;
  }

  /// Получает текущий refresh token
  Future<String?> getRefreshToken() async {
    final tokens = await _userDao.getTokensOnly();
    return tokens?.refreshToken;
  }

  /// Очищает все данные аутентификации
  Future<void> clearAuthData() async {
    await _userDao.clearUser();
  }

  /// Очищает только токены, оставляя данные пользователя
  Future<void> clearTokens() async {
    await _userDao.clearTokens();
  }

  // /// Проверяет, аутентифицирован ли пользователь
  // Future<bool> isAuthenticated() async => hasValidToken();
}

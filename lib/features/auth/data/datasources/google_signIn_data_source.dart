import 'dart:async';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

const List<String> _scopes = <String>[
  'https://www.googleapis.com/auth/userinfo.profile',
  'https://www.googleapis.com/auth/userinfo.email',
  'openid',
];

abstract class GoogleSignInDataSource {
  Future<GoogleSignInAccount?> signIn();
  Future<void> signOut();
  GoogleSignInAccount? get currentUser;
  bool get isAuthorized;
}

class GoogleSignInDataSourceImpl implements GoogleSignInDataSource {
  GoogleSignInDataSourceImpl();

  late final GoogleSignIn _signIn = GoogleSignIn.instance;
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  bool _initialized = false;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSubscription;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    await _signIn.initialize(
      clientId: dotenv.get('GoogleClientID'),
      serverClientId: dotenv.get('GoogleClientSecret'),
    );

    // Подписываемся на события аутентификации
    _authSubscription = _signIn.authenticationEvents.listen(
      _handleAuthenticationEvent,
    )..onError(_handleAuthenticationError);

    // Попытка легкой аутентификации при инициализации
    await _signIn.attemptLightweightAuthentication();

    _initialized = true;
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    // Проверяем существующую авторизацию
    final GoogleSignInClientAuthorization? authorization = await user
        ?.authorizationClient
        .authorizationForScopes(_scopes);

    _currentUser = user;
    _isAuthorized = authorization != null;

    if (user != null && authorization != null) {
      log('User authenticated and authorized: ${user.email}');
    }
  }

  Future<void> _handleAuthenticationError(Object error) async {
    _currentUser = null;
    _isAuthorized = false;
    final errorMessage = error is GoogleSignInException
        ? 'GoogleSignInException ${error.code}: ${error.description}'
        : 'Unknown error: $error';
    log('Authentication error: $errorMessage');
  }

  @override
  Future<GoogleSignInAccount?> signIn() async {
    try {
      await _ensureInitialized();

      final account = await _signIn.authenticate();

      // Проверяем авторизацию для требуемых скоупов
      final authorization = await account.authorizationClient
          .authorizationForScopes(_scopes);

      if (authorization == null) {
        // Если нет авторизации, запрашиваем её
        await account.authorizationClient.authorizeScopes(_scopes);
      }

      return account;
    } catch (e) {
      log('Google sign-in error: $e');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _ensureInitialized();
    // Используем disconnect для полного выхода, как в примере
    await _signIn.disconnect();
    _currentUser = null;
    _isAuthorized = false;
  }

  @override
  GoogleSignInAccount? get currentUser => _currentUser;

  @override
  bool get isAuthorized => _isAuthorized;

  /// Запрос авторизации для дополнительных скоупов
  Future<bool> authorizeScopes(List<String> scopes) async {
    try {
      await _ensureInitialized();
      final user = _currentUser;
      if (user == null) return false;

      await user.authorizationClient.authorizeScopes(scopes);
      return true;
    } catch (e) {
      log('Authorization error: $e');
      return false;
    }
  }

  /// Получение заголовков авторизации для API запросов
  Future<Map<String, String>?> getAuthorizationHeaders() async {
    await _ensureInitialized();
    final user = _currentUser;
    if (user == null || !_isAuthorized) return null;

    return user.authorizationClient.authorizationHeaders(_scopes);
  }

  /// Получение server auth code
  Future<String?> getServerAuthCode() async {
    try {
      await _ensureInitialized();
      final user = _currentUser;
      if (user == null) return null;

      final serverAuth = await user.authorizationClient.authorizeServer(
        _scopes,
      );
      return serverAuth?.serverAuthCode;
    } catch (e) {
      log('Server auth code error: $e');
      return null;
    }
  }

  /// Освобождение ресурсов
  void dispose() {
    _authSubscription?.cancel();
  }
}

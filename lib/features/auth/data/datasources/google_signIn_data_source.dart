import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Скоупы можно вынести сюда, если они константны для всего приложения
const List<String> _defaultScopes = <String>['email', 'profile', 'openid'];

abstract class GoogleSignInDataSource {
  Future<void> init();
  Future<GoogleSignInAccount?> signIn();
  Future<void> signOut();
  Future<GoogleSignInAuthentication> getAuthentication();
  void dispose();

  GoogleSignInAccount? get currentUser;
  bool get isAuthorized;
}

class GoogleSignInDataSourceImpl implements GoogleSignInDataSource {
  // Используем GoogleSignIn.instance, это синглтон
  final GoogleSignIn _signIn = GoogleSignIn.instance;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSubscription;

  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;

  @override
  GoogleSignInAccount? get currentUser => _currentUser;
  @override
  bool get isAuthorized => _isAuthorized;

  /// Инициализация. Должна быть вызвана ОДИН РАЗ.
  @override
  Future<void> init() async {
    // Предотвращаем повторную инициализацию
    if (_authSubscription != null) return;

    try {
      await _signIn.initialize(
        clientId: dotenv.get('GoogleClientID'),
        serverClientId: dotenv.get('GoogleClientSecret'),
      );

      _authSubscription = _signIn.authenticationEvents.listen(
        _handleAuthenticationEvent,
        onError: _handleAuthenticationError,
      );

      // Попытка "тихого" входа при старте
      //  await _signIn.attemptLightweightAuthentication();
    } catch (e) {
      log('GoogleSignIn initialization error: $e');
    }
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    _currentUser = user;

    if (user != null) {
      // Проверяем, есть ли у нас уже права на нужные скоупы
      final authorization = await user.authorizationClient
          .authorizationForScopes(_defaultScopes);
      _isAuthorized = authorization != null;
      log('User authenticated: ${user.email}, isAuthorized: $_isAuthorized');
    } else {
      _isAuthorized = false;
      log('User signed out.');
    }
  }

  void _handleAuthenticationError(Object error) {
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
      // Инициируем стандартный флоу входа
      final user = await _signIn.authenticate();
      return user;
    } on GoogleSignInException catch (e) {
      log('Google sign-in error: Code ${e.code}, ${e.description}');
      // Возвращаем null, если пользователь отменил вход
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      // Перебрасываем остальные ошибки
      rethrow;
    } catch (e) {
      log('An unexpected error occurred during sign-in: $e');
      rethrow;
    }
  }

  @override
  Future<GoogleSignInAuthentication> getAuthentication() async {
    if (_currentUser == null) {
      throw Exception('User is not signed in. Cannot get authentication.');
    }
    return _currentUser!.authentication;
  }

  @override
  Future<void> signOut() async {
    await _signIn.disconnect();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
  }
}

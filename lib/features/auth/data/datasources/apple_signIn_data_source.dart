import 'dart:async';
import 'dart:developer';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Скоупы для Apple Sign In
const List<AppleIDAuthorizationScopes> _defaultScopes =
    <AppleIDAuthorizationScopes>[
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ];

abstract class AppleSignInDataSource {
  Future<bool> isAvailable();
  Future<AuthorizationCredentialAppleID?> signIn();
  Future<AuthorizationCredentialAppleID?> getCredentialState(
    String userIdentifier,
  );
  String? get currentUserIdentifier;
  bool get isSignedIn;
}

class AppleSignInDataSourceImpl implements AppleSignInDataSource {
  String? _currentUserIdentifier;
  bool _isSignedIn = false;

  @override
  String? get currentUserIdentifier => _currentUserIdentifier;
  @override
  bool get isSignedIn => _isSignedIn;

  /// Проверяет, доступен ли Apple Sign In на устройстве
  @override
  Future<bool> isAvailable() async {
    try {
      return await SignInWithApple.isAvailable();
    } catch (e) {
      log('Error checking Apple Sign In availability: $e');
      return false;
    }
  }

  /// Инициирует процесс входа через Apple
  @override
  Future<AuthorizationCredentialAppleID?> signIn() async {
    try {
      // Проверяем доступность Apple Sign In
      final isAvailable = await this.isAvailable();
      if (!isAvailable) {
        throw Exception('Apple Sign In is not available on this device');
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: _defaultScopes,
      );

      _currentUserIdentifier = credential.userIdentifier;
      _isSignedIn = true;

      log('Apple Sign In successful. User ID: ${credential.userIdentifier}');
      log('Email: ${credential.email}');
      log('Given Name: ${credential.givenName}');
      log('Family Name: ${credential.familyName}');

      return credential;
    } on SignInWithAppleAuthorizationException catch (e) {
      log('Apple Sign In authorization error: ${e.code} - ${e.message}');

      // Обрабатываем различные коды ошибок
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          log('User canceled Apple Sign In');
          return null;
        case AuthorizationErrorCode.failed:
          log('Apple Sign In failed');
          break;
        case AuthorizationErrorCode.invalidResponse:
          log('Invalid response from Apple Sign In');
          break;
        case AuthorizationErrorCode.notHandled:
          log('Apple Sign In not handled');
          break;
        case AuthorizationErrorCode.unknown:
          log('Unknown Apple Sign In error');
          break;
        case AuthorizationErrorCode.notInteractive:
          // TODO: Handle this case.
          throw UnimplementedError();
        case AuthorizationErrorCode.credentialExport:
          // TODO: Handle this case.
          throw UnimplementedError();
        case AuthorizationErrorCode.credentialImport:
          // TODO: Handle this case.
          throw UnimplementedError();
        case AuthorizationErrorCode.matchedExcludedCredential:
          // TODO: Handle this case.
          throw UnimplementedError();
      }

      // Возвращаем null для отмены, перебрасываем остальные ошибки
      if (e.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      rethrow;
    } catch (e) {
      log('Unexpected error during Apple Sign In: $e');
      _currentUserIdentifier = null;
      _isSignedIn = false;
      rethrow;
    }
  }

  /// Получает состояние учетных данных для указанного пользователя
  @override
  Future<AuthorizationCredentialAppleID?> getCredentialState(
    String userIdentifier,
  ) async {
    try {
      final credentialState = await SignInWithApple.getCredentialState(
        userIdentifier,
      );

      switch (credentialState) {
        case CredentialState.authorized:
          log(
            'Apple Sign In credentials are authorized for user: $userIdentifier',
          );
          _currentUserIdentifier = userIdentifier;
          _isSignedIn = true;
          break;
        case CredentialState.revoked:
          log(
            'Apple Sign In credentials are revoked for user: $userIdentifier',
          );
          _currentUserIdentifier = null;
          _isSignedIn = false;
          break;
        case CredentialState.notFound:
          log('Apple Sign In credentials not found for user: $userIdentifier');
          _currentUserIdentifier = null;
          _isSignedIn = false;
          break;
      }

      return null; // getCredentialState не возвращает полные данные пользователя
    } catch (e) {
      log('Error getting credential state: $e');
      _currentUserIdentifier = null;
      _isSignedIn = false;
      return null;
    }
  }

  /// Выход из Apple Sign In (локальное состояние)
  Future<void> signOut() async {
    _currentUserIdentifier = null;
    _isSignedIn = false;
    log('User signed out from Apple Sign In');
  }
}

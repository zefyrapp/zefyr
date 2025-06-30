import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

const List<String> _scopes = <String>[
  'email',
  'profile',
  'openid',
  // Добавьте дополнительные scope, если нужно
];

abstract class GoogleSignInDataSource {
  Future<GoogleSignInAccount?> signIn();
  Future<void> signOut();
  // Future<String?> getIdToken();
}

class GoogleSignInDataSourceImpl implements GoogleSignInDataSource {
  GoogleSignInDataSourceImpl();
  static final GoogleSignIn _signIn = GoogleSignIn.instance;
  GoogleSignInAccount? _currentUser;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _signIn.initialize(
      clientId: dotenv.get('GoogleClientID'),
      serverClientId: dotenv.get('GoogleClientSecret'),
    );
    // Можно подписаться на события, если нужно
    // _googleSignIn.authenticationEvents.listen(...);
    await _signIn.attemptLightweightAuthentication();
    _initialized = true;
  }

  @override
  Future<GoogleSignInAccount?> signIn() async {
    try {
      await _ensureInitialized();
      await _signIn.signOut(); // всегда чистим предыдущую сессию
      final account = await _signIn.authenticate(scopeHint: _scopes);
      _currentUser = account;
      return account;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _ensureInitialized();
    await _signIn.disconnect();
    _currentUser = null;
  }

  // @override
  // Future<String?> getIdToken() async {
  //   await _ensureInitialized();
  //   final user = _currentUser ?? await _signIn.signInSilently();
  //   if (user == null) return null;
  //   final auth = await user.authentication;
  //   return auth.idToken;
  // }
}

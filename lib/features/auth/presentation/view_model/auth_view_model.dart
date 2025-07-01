import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyr/core/usecases/usecases.dart';
import 'package:zefyr/features/auth/presentation/view_model/auth_state.dart';
import 'package:zefyr/features/auth/usecases/login_user.dart';
import 'package:zefyr/features/auth/usecases/login_with_google.dart';
import 'package:zefyr/features/auth/usecases/logout_user.dart';
import 'package:zefyr/features/auth/usecases/register_user.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel({
    required LoginUser loginUser,
    required LogoutUser logoutUser,
    required RegisterUser registerUser,
    required LoginWithGoogle loginWithGoogle,
  }) : _loginUser = loginUser,
       _logoutUser = logoutUser,
       _registerUser = registerUser,
       _loginWithGoogle = loginWithGoogle,
       super(const AuthInitial());
  final LoginUser _loginUser;
  final LogoutUser _logoutUser;
  final RegisterUser _registerUser;
  final LoginWithGoogle _loginWithGoogle;

  Future<void> login(String email, String password) async {
    state = const AuthLoading();

    final result = await _loginUser(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<void> register(
    String email,
    String password,
    String dateOfBirth,
    String? name,
  ) async {
    state = const AuthLoading();

    final result = await _registerUser(
      RegisterParams(
        email: email,
        password: password,
        dateOfBirth: dateOfBirth,
        name: name,
      ),
    );

    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<void> logout() async {
    state = const AuthLoading();

    final result = await _logoutUser(NoParams());

    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = const AuthUnauthenticated(),
    );
  }

  Future<void> loginWithGoogle() async {
    state = const AuthLoading();
    final result = await _loginWithGoogle(NoParams());
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }
}

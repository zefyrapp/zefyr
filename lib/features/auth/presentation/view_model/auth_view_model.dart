import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifyr/core/usecases/usecases.dart';
import 'package:zifyr/features/auth/presentation/view_model/auth_state.dart';
import 'package:zifyr/features/auth/usecases/login_user.dart';
import 'package:zifyr/features/auth/usecases/logout_user.dart';
import 'package:zifyr/features/auth/usecases/register_user.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel({
    required LoginUser loginUser,
    required LogoutUser logoutUser,
    required RegisterUser registerUser,
  }) : _loginUser = loginUser,
       _logoutUser = logoutUser,
       _registerUser = registerUser,
       super(const AuthInitial());
  final LoginUser _loginUser;
  final LogoutUser _logoutUser;
  final RegisterUser _registerUser;

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

  Future<void> register(String email, String password, String name) async {
    state = const AuthLoading();

    final result = await _registerUser(
      RegisterParams(email: email, password: password, name: name),
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
}

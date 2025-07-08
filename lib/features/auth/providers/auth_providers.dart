import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zefyr/core/database/database.dart';
import 'package:zefyr/core/network/dio_client.dart';
import 'package:zefyr/core/services/token_manager.dart';
import 'package:zefyr/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:zefyr/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:zefyr/features/auth/data/datasources/google_signIn_data_source.dart';
import 'package:zefyr/features/auth/data/datasources/user_dao.dart';
import 'package:zefyr/features/auth/data/models/user_model.dart';
import 'package:zefyr/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zefyr/features/auth/domain/repositories/auth_repository.dart';
import 'package:zefyr/features/auth/presentation/view_model/auth_state.dart';
import 'package:zefyr/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:zefyr/features/auth/usecases/check_email.dart';
import 'package:zefyr/features/auth/usecases/login_user.dart';
import 'package:zefyr/features/auth/usecases/login_with_google.dart';
import 'package:zefyr/features/auth/usecases/logout_user.dart';
import 'package:zefyr/features/auth/usecases/register_user.dart';

part 'auth_providers.g.dart';

// DataSources
@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) =>
    AuthRemoteDataSourceImpl(client: ref.watch(dioClientProvider));

@riverpod
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}

@riverpod
UserDao userDao(Ref ref) => UserDao(ref.watch(appDatabaseProvider));

@riverpod
TokenManager tokenManager(Ref ref) => TokenManager(ref.watch(userDaoProvider));
@riverpod
AuthLocalDataSource authLocalDataSource(Ref ref) =>
    AuthLocalDataSourceImpl(ref.watch(userDaoProvider));

@riverpod
GoogleSignInDataSource googleSignInDataSource(Ref ref) =>
    GoogleSignInDataSourceImpl();

// Repository
@riverpod
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  localDataSource: ref.watch(authLocalDataSourceProvider),
  googleSignInDataSource: ref.watch(googleSignInDataSourceProvider),
);

// Use Cases
@riverpod
LoginUser loginUser(Ref ref) => LoginUser(ref.watch(authRepositoryProvider));

@riverpod
LogoutUser logoutUser(Ref ref) => LogoutUser(ref.watch(authRepositoryProvider));

@riverpod
RegisterUser registerUser(Ref ref) =>
    RegisterUser(ref.watch(authRepositoryProvider));

@riverpod
LoginWithGoogle loginWithGoogle(Ref ref) =>
    LoginWithGoogle(ref.watch(authRepositoryProvider));

@riverpod
CheckEmail checkEmail(Ref ref) => CheckEmail(ref.watch(authRepositoryProvider));

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(
    loginUser: ref.read(loginUserProvider),
    logoutUser: ref.read(logoutUserProvider),
    registerUser: ref.read(registerUserProvider),
    loginWithGoogle: ref.read(loginWithGoogleProvider),
    checkEmail: ref.watch(checkEmailProvider),
  ),
);
@riverpod
Stream<UserModel?> authStateChanges(Ref ref) {
  final authDataSource = ref.watch(authLocalDataSourceProvider);
  return authDataSource.watchUserOnly();
}

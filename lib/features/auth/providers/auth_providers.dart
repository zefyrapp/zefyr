import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:zifyr/core/network/dio_client.dart';
import 'package:zifyr/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:zifyr/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:zifyr/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zifyr/features/auth/domain/repositories/auth_repository.dart';
import 'package:zifyr/features/auth/presentation/view_model/auth_state.dart';
import 'package:zifyr/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:zifyr/features/auth/usecases/login_user.dart';
import 'package:zifyr/features/auth/usecases/logout_user.dart';
import 'package:zifyr/features/auth/usecases/register_user.dart';

// Data Sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(client: ref.read(dioClientProvider)),
);

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => const AuthLocalDataSourceImpl(),
);

// Repository
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    localDataSource: ref.read(authLocalDataSourceProvider),
  ),
);

// Use Cases
final loginUserProvider = Provider<LoginUser>(
  (ref) => LoginUser(ref.read(authRepositoryProvider)),
);

final logoutUserProvider = Provider<LogoutUser>(
  (ref) => LogoutUser(ref.read(authRepositoryProvider)),
);

final registerUserProvider = Provider<RegisterUser>(
  (ref) => RegisterUser(ref.read(authRepositoryProvider)),
);

// View Model
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(
    loginUser: ref.read(loginUserProvider),
    logoutUser: ref.read(logoutUserProvider),
    registerUser: ref.read(registerUserProvider),
  ),
);

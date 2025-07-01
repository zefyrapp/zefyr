import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/features/auth/data/models/auth_response.dart';

abstract class AuthRepository {
  Future<Either<Failure, bool>> checkEmail({required String email});
  Future<Either<Failure, AuthResponse>> login(String email, String password);
  Future<Either<Failure, AuthResponse>> register(
    String email,
    String password,
    String dateOfBirth,
    String? name,
  );
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AuthResponse?>> getCurrentUser();
  Future<Either<Failure, AuthResponse>> loginWithGoogle();
}

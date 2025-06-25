import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zifyr/core/error/exceptions.dart';
import 'package:zifyr/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String name);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required this.client});
  final http.Client client;

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('https://api.example.com/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw const ServerException();
    }
  }

  @override
  Future<UserModel> register(String email, String password, String name) async {
    final response = await client.post(
      Uri.parse('https://api.example.com/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password, 'name': name}),
    );

    if (response.statusCode == 201) {
      return UserModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw const ServerException();
    }
  }

  @override
  Future<void> logout() async {
    // Реализация выхода из системы
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyr/core/error/exceptions.dart';
import 'package:zefyr/core/network/dio_client.dart';
import 'package:zefyr/features/auth/providers/auth_providers.dart';
import 'package:zefyr/features/home/domain/entities/stream_list_api_wrapper.dart';
import 'package:zefyr/features/live/data/models/stream_create_response.dart';

abstract class HomeStreamDataSource {
  Future<StreamListApiWrapper> getStreams({
    required int page,
    required int pageSize,
  });

  Future<StreamCreateResponse> getStreamToken({
    required String streamId,
    String? deviceId,
  });
}

class HomeStreamDataSourceImpl implements HomeStreamDataSource {
  const HomeStreamDataSourceImpl(this.client, this.ref);
  final DioClient client;
  final Ref ref;
  Future<T> _handle<T>(Future<T> Function() f) async {
    try {
      return f.call();
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Обработка исключений для конкретного контекста
  Exception _handleException(dynamic e) {
    if (e is AppException) {
      return e;
    }
    return ServerException('Auth service error: ${e.toString()}');
  }

  @override
  Future<StreamCreateResponse> getStreamToken({
    required String streamId,
    String? deviceId,
  }) async {
    final token = await ref.read(tokenManagerProvider).getAccessToken();
    if (token != null) client.setAuthToken(token);
    return (await client.getWithApiResponse<StreamCreateResponse>(
      '/api/streaming/streams/$streamId/token',
      queryParameters: {"device_id": deviceId},
      fromJson: StreamCreateResponse.fromMap,
    )).data!;
  }

  @override
  Future<StreamListApiWrapper> getStreams({
    required int page,
    required int pageSize,
  }) async {
    final token = await ref.read(tokenManagerProvider).getAccessToken();
    if (token != null) client.setAuthToken(token);
    return client.get<StreamListApiWrapper>(
      '/api/streaming/streams',
      queryParameters: {"page": page, "page_size": pageSize},
      fromJson: StreamListApiWrapper.fromMap,
    );
  }
}

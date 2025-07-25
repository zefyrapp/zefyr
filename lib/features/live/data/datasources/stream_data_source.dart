import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyr/core/error/exceptions.dart';
import 'package:zefyr/core/network/dio_client.dart';
import 'package:zefyr/features/live/data/models/stream_create_request.dart';
import 'package:zefyr/features/live/data/models/stream_create_response.dart';
import 'package:zefyr/features/live/domain/entities/stream_model.dart';

abstract class StreamDataSource {
  /// Создает новый стрим с заданным заголовком, описанием и URL превью.
  ///
  /// title - maxLength: 100, minLength: 1
  ///
  /// description - maxLength: 200
  Future<StreamCreateResponse> createStream({
    required StreamCreateRequest request,
  });

  /// Останавливает стрим с заданным идентификатором.
  Future<void> stopStream(String streamId);
}

class StreamDataSourceImpl implements StreamDataSource {
  const StreamDataSourceImpl(this.client, this.ref);
  final DioClient client;
  final Ref ref;

  @override
  Future<StreamCreateResponse> createStream({
    required StreamCreateRequest request,
  }) async => _handle<StreamCreateResponse>(
    () async => (await client.postWithApiResponse<StreamCreateResponse>(
      '/api/streaming/streams/create/',
      data: {
        'title': request.title,
        'description': request.description,
        'preview_url': request.previewUrl,
      },
      fromJson: StreamCreateResponse.fromMap,
    )).data!,
  );

  @override
  Future<void> stopStream(String streamId) async =>  _handle<StreamModel>(
      () async => (await client.postWithApiResponse<StreamModel>(
        '/api/streaming/streams/$streamId/end/',
        fromJson: StreamModel.fromMap,
      )).data!,
    );

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
}

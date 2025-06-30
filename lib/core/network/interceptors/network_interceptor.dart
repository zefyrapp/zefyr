import 'package:dio/dio.dart';
import 'package:zefyr/core/network/network_info.dart';

/// Интерцептор для проверки сетевого соединения
class NetworkInterceptor extends Interceptor {
  const NetworkInterceptor(this.networkInfo);
  final NetworkInfo networkInfo;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!await networkInfo.isConnected) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'Нет подключения к интернету',
        ),
      );
    }
    handler.next(options);
  }
}

import 'package:dio/dio.dart';
import 'package:zefyr/core/network/dio_client.dart';

/// Интерцептор для повтора запросов
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  final int maxRetries;
  final Duration retryDelay;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final extra = err.requestOptions.extra;
    final double retries = double.tryParse(extra['retries'].toString()) ?? 0;

    if (retries < maxRetries && _shouldRetry(err)) {
      extra['retries'] = retries + 1;

      await Future.delayed(retryDelay * (retries + 1));

      try {
        final response = await err.requestOptions
            .copyWith(extra: extra)
            .request();
        return handler.resolve(response);
      } catch (e) {}
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) =>
      err.type == DioExceptionType.connectionTimeout ||
      err.type == DioExceptionType.receiveTimeout ||
      err.type == DioExceptionType.sendTimeout ||
      (err.response?.statusCode != null && err.response!.statusCode! >= 500);
}

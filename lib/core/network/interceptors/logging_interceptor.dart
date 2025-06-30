import 'dart:developer';

import 'package:dio/dio.dart';

/// Интерцептор для логирования запросов (только в debug режиме)
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
    log('Headers: ${options.headers}');
    if (options.data != null) {
      log('Data: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      log('Query Parameters: ${options.queryParameters}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    log(
      '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    log('Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log(
      '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    log('Message: ${err.message}');
    if (err.response?.data != null) {
      log('Error Data: ${err.response?.data}');
    }
    handler.next(err);
  }
}

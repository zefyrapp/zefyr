import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:zefyr/core/network/models/api_response.dart';

/// Универсальный парсер ответов от сервера.

/// Декодирование JSON-объекта
Map<String, dynamic> _decodeJsonObject(String jsonString) =>
    jsonDecode(jsonString) as Map<String, dynamic>;

/// Декодирование JSON-массива
List<dynamic> _decodeJsonList(String jsonString) =>
    jsonDecode(jsonString) as List<dynamic>;

/// Парсинг одного объекта через ApiResponse
ApiResponse<T> _parseApiResponse<T>(ParseApiParams<T> params) =>
    ApiResponse<T>.fromJson(params.json, fromJsonT: params.fromJson);

/// Парсинг списка через ApiListResponse
ApiListResponse<T> _parseApiListResponse<T>(ParseApiListParams<T> params) =>
    ApiListResponse<T>.fromJson(params.json, fromJsonT: params.fromJson);

/// Парсинг простого объекта (без обертки ApiResponse)
T _parseSimpleObject<T>(ParseSimpleParams<T> params) =>
    params.fromJson(params.json);

/// Парсинг простого списка (без обертки ApiResponse)
List<T> _parseSimpleList<T>(ParseSimpleListParams<T> params) =>
    params.list.whereType<Map<String, dynamic>>().map(params.fromJson).toList();

/// Параметры для парсинга ApiResponse
class ParseApiParams<T> {
  const ParseApiParams(this.json, this.fromJson);
  final Map<String, dynamic> json;
  final T Function(Map<String, dynamic>) fromJson;
}

/// Параметры для парсинга ApiListResponse
class ParseApiListParams<T> {
  const ParseApiListParams(this.json, this.fromJson);
  final Map<String, dynamic> json;
  final T Function(Map<String, dynamic>) fromJson;
}

/// Параметры для парсинга простого объекта
class ParseSimpleParams<T> {
  const ParseSimpleParams(this.json, this.fromJson);
  final Map<String, dynamic> json;
  final T Function(Map<String, dynamic>) fromJson;
}

/// Параметры для парсинга простого списка
class ParseSimpleListParams<T> {
  const ParseSimpleListParams(this.list, this.fromJson);
  final List<dynamic> list;
  final T Function(Map<String, dynamic>) fromJson;
}

/// =================================================================
/// УНИВЕРСАЛЬНЫЙ ПАРСЕР
/// =================================================================
class ResponseParser {
  /// Универсальный метод парсинга ответа с поддержкой ApiResponse структуры.
  ///
  /// Автоматически определяет структуру данных и парсит соответствующим образом.
  /// Поддерживает как обычные данные, так и обернутые в ApiResponse.
  Future<T> parseResponse<T>(
    Response<dynamic> response, {
    Function? fromJson,
    bool useApiResponseWrapper = true, // Новый параметр
  }) async {
    final dynamic data = response.data;

    // Если парсер не предоставлен, возвращаем сырые данные
    if (fromJson == null) {
      if (data is T) {
        return data;
      }
      return data as T;
    }

    // Определяем, является ли ответ структурой ApiResponse
    final bool isApiResponseStructure =
        data is Map<String, dynamic> &&
        data.containsKey('success') &&
        data.containsKey('message');

    // --- ПАРСИНГ С ИСПОЛЬЗОВАНИЕМ ApiResponse СТРУКТУРЫ ---
    if (useApiResponseWrapper && isApiResponseStructure) {
      return _parseWithApiResponseWrapper<T>(data, fromJson);
    }

    // --- ПАРСИНГ БЕЗ ApiResponse ОБЕРТКИ (классический подход) ---
    return _parseWithoutWrapper<T>(data, fromJson);
  }

  /// Парсинг с использованием ApiResponse обертки
  Future<T> _parseWithApiResponseWrapper<T>(
    Map<String, dynamic> data,
    Function fromJson,
  ) async {
    // Определяем тип T и парсим соответственно
    if (T.toString().startsWith('ApiResponse<')) {
      // T это ApiResponse<SomeModel>
      final result = await _parseApiResponseInCompute<dynamic>(data, fromJson);
      return result as T;
    } else if (T.toString().startsWith('ApiListResponse<')) {
      // T это ApiListResponse<SomeModel>
      final result = await _parseApiListResponseInCompute<dynamic>(
        data,
        fromJson,
      );
      return result as T;
    } else {
      // T это обычная модель, оборачиваем в ApiResponse
      final apiResponse = await _parseApiResponseInCompute<T>(data, fromJson);
      return apiResponse as T;
    }
  }

  /// Парсинг без обертки (классический подход)
  Future<T> _parseWithoutWrapper<T>(dynamic data, Function fromJson) async {
    // 1. Если данные - это СПИСОК
    if (data is List) {
      final List<dynamic> result = await _parseSimpleListInCompute(
        data,
        fromJson,
      );
      return result as T;
    }

    // 2. Если данные - это ОБЪЕКТ
    if (data is Map<String, dynamic>) {
      final dynamic result = await _parseSimpleObjectInCompute(data, fromJson);
      return result as T;
    }

    // 3. Если данные - это СТРОКА
    if (data is String) {
      final trimmedData = data.trim();
      // JSON-массив
      if (trimmedData.startsWith('[') && trimmedData.endsWith(']')) {
        final List<dynamic> listData = await _decodeListInCompute(trimmedData);
        final List<dynamic> result = await _parseSimpleListInCompute(
          listData,
          fromJson,
        );
        return result as T;
      }
      // JSON-объект
      if (trimmedData.startsWith('{') && trimmedData.endsWith('}')) {
        final Map<String, dynamic> jsonData = await _decodeObjectInCompute(
          trimmedData,
        );
        final dynamic result = await _parseSimpleObjectInCompute(
          jsonData,
          fromJson,
        );
        return result as T;
      }
    }

    throw FormatException(
      'Не удалось распознать структуру данных для парсинга. Тип данных: ${data.runtimeType}',
    );
  }

  // --- Методы для работы с ApiResponse ---

  Future<ApiResponse<T>> _parseApiResponseInCompute<T>(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (data.length > 50 && !kIsWeb) {
      return compute(_parseApiResponse<T>, ParseApiParams<T>(data, fromJson));
    }
    return _parseApiResponse<T>(ParseApiParams<T>(data, fromJson));
  }

  Future<ApiListResponse<T>> _parseApiListResponseInCompute<T>(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (data.length > 50 && !kIsWeb) {
      return compute(
        _parseApiListResponse<T>,
        ParseApiListParams<T>(data, fromJson),
      );
    }
    return _parseApiListResponse<T>(ParseApiListParams<T>(data, fromJson));
  }

  // --- Существующие методы (обновленные) ---

  Future<Map<String, dynamic>> _decodeObjectInCompute(String data) async {
    if (data.length > 2048 && !kIsWeb) {
      return compute(_decodeJsonObject, data);
    }
    return _decodeJsonObject(data);
  }

  Future<List<dynamic>> _decodeListInCompute(String data) async {
    if (data.length > 2048 && !kIsWeb) {
      return compute(_decodeJsonList, data);
    }
    return _decodeJsonList(data);
  }

  Future<T> _parseSimpleObjectInCompute<T>(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (data.length > 50 && !kIsWeb) {
      return compute(
        _parseSimpleObject<T>,
        ParseSimpleParams<T>(data, fromJson),
      );
    }
    return _parseSimpleObject<T>(ParseSimpleParams<T>(data, fromJson));
  }

  Future<List<T>> _parseSimpleListInCompute<T>(
    List<dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (data.length > 100 && !kIsWeb) {
      return compute(
        _parseSimpleList<T>,
        ParseSimpleListParams<T>(data, fromJson),
      );
    }
    return _parseSimpleList<T>(ParseSimpleListParams<T>(data, fromJson));
  }
}

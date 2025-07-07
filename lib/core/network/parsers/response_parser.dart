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
  final T Function(Map<String, dynamic>)? fromJson;
}

/// Параметры для парсинга ApiListResponse
class ParseApiListParams<T> {
  const ParseApiListParams(this.json, this.fromJson);
  final Map<String, dynamic> json;
  final T Function(Map<String, dynamic>)? fromJson;
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
    T Function(Map<String, dynamic>)? fromJson,
    bool useApiResponseWrapper = true,
  }) async {
    final dynamic data = response.data;

    // Если парсер не предоставлен и тип T - это примитив или dynamic
    if (fromJson == null) {
      if (data is T) {
        return data;
      }
      // Попытка приведения типа для примитивных типов
      try {
        return data as T;
      } catch (e) {
        throw FormatException(
          'Не удалось привести данные к типу $T без fromJson функции. '
          'Данные: ${data.runtimeType}',
        );
      }
    }

    // Определяем, является ли ответ структурой ApiResponse
    final bool isApiResponseStructure = _isApiResponseStructure(data);

    // --- ПАРСИНГ С ИСПОЛЬЗОВАНИЕМ ApiResponse СТРУКТУРЫ ---
    if (useApiResponseWrapper && isApiResponseStructure) {
      return _parseWithApiResponseWrapper<T>(
        data as Map<String, dynamic>,
        fromJson,
      );
    }

    // --- ПАРСИНГ БЕЗ ApiResponse ОБЕРТКИ (классический подход) ---
    return _parseWithoutWrapper<T>(data, fromJson);
  }

  /// Проверяет, является ли структура данных ApiResponse
  bool _isApiResponseStructure(dynamic data) =>
      data is Map<String, dynamic> &&
      data.containsKey('success') &&
      data.containsKey('message');

  /// Парсинг с использованием ApiResponse обертки
  Future<T> _parseWithApiResponseWrapper<T>(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    // Определяем тип T через runtimeType строки
    final typeString = T.toString();

    // Если T это уже ApiResponse<SomeModel>
    if (typeString.startsWith('ApiResponse<')) {
      // fromJson уже настроен для создания ApiResponse<T>
      if (fromJson != null) {
        final result = fromJson(data);
        return result;
      } else {
        // Создаем ApiResponse без типизированных данных
        final result = ApiResponse<dynamic>.fromJson(data);
        return result as T;
      }
    }
    // Если T это ApiListResponse<SomeModel>
    else if (typeString.startsWith('ApiListResponse<')) {
      // fromJson уже настроен для создания ApiListResponse<T>
      if (fromJson != null) {
        final result = fromJson(data);
        return result;
      } else {
        // Создаем ApiListResponse без типизированных данных
        final result = ApiListResponse<dynamic>.fromJson(data);
        return result as T;
      }
    }
    // T это обычная модель, но ответ обернут в ApiResponse
    else {
      // Проверяем, содержит ли ответ массив в data
      final apiData = data['data'];
      if (apiData is List) {
        // Это список, парсим как ApiListResponse и возвращаем данные
        final listResponse = await _parseApiListResponseInCompute<T>(
          data,
          fromJson,
        );
        // Возвращаем только данные из ApiListResponse
        return listResponse.data as T;
      } else {
        // Это объект, парсим как ApiResponse и возвращаем данные
        final apiResponse = await _parseApiResponseInCompute<T>(data, fromJson);
        // Возвращаем только данные из ApiResponse
        return apiResponse.data as T;
      }
    }
  }

  /// Парсинг без обертки (классический подход)
  Future<T> _parseWithoutWrapper<T>(
    dynamic data,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    // 1. Если данные - это СПИСОК
    if (data is List) {
      if (fromJson == null) {
        return data as T;
      }
      final List<T> result = await _parseSimpleListInCompute<T>(data, fromJson);
      return result as T;
    }

    // 2. Если данные - это ОБЪЕКТ
    if (data is Map<String, dynamic>) {
      if (fromJson == null) {
        return data as T;
      }
      final T result = await _parseSimpleObjectInCompute<T>(data, fromJson);
      return result;
    }

    // 3. Если данные - это СТРОКА (JSON)
    if (data is String) {
      final trimmedData = data.trim();

      // JSON-массив
      if (trimmedData.startsWith('[') && trimmedData.endsWith(']')) {
        final List<dynamic> listData = await _decodeListInCompute(trimmedData);
        if (fromJson == null) {
          return listData as T;
        }
        final List<T> result = await _parseSimpleListInCompute<T>(
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
        if (fromJson == null) {
          return jsonData as T;
        }
        final T result = await _parseSimpleObjectInCompute<T>(
          jsonData,
          fromJson,
        );
        return result;
      }

      throw FormatException('Строка не является валидным JSON: $trimmedData');
    }

    throw FormatException(
      'Не удалось распознать структуру данных для парсинга. '
      'Тип данных: ${data.runtimeType}, значение: $data',
    );
  }

  // --- Методы для работы с ApiResponse ---

  Future<ApiResponse<T>> _parseApiResponseInCompute<T>(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    final params = ParseApiParams<T>(data, fromJson);

    if (data.length > 50 && !kIsWeb) {
      return compute(_parseApiResponse<T>, params);
    }
    return _parseApiResponse<T>(params);
  }

  Future<ApiListResponse<T>> _parseApiListResponseInCompute<T>(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    final params = ParseApiListParams<T>(data, fromJson);

    if (data.length > 50 && !kIsWeb) {
      return compute(_parseApiListResponse<T>, params);
    }
    return _parseApiListResponse<T>(params);
  }

  // --- Методы для работы с простыми объектами ---

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
    final params = ParseSimpleParams<T>(data, fromJson);

    if (data.length > 50 && !kIsWeb) {
      return compute(_parseSimpleObject<T>, params);
    }
    return _parseSimpleObject<T>(params);
  }

  Future<List<T>> _parseSimpleListInCompute<T>(
    List<dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final params = ParseSimpleListParams<T>(data, fromJson);

    if (data.length > 100 && !kIsWeb) {
      return compute(_parseSimpleList<T>, params);
    }
    return _parseSimpleList<T>(params);
  }
}

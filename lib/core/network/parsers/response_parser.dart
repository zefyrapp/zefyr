import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Универсальный парсер ответов от сервера.

/// Декодирование JSON-объекта
Map<String, dynamic> _decodeJsonObject(String jsonString) =>
    jsonDecode(jsonString) as Map<String, dynamic>;

/// Декодирование JSON-массива
List<dynamic> _decodeJsonList(String jsonString) =>
    jsonDecode(jsonString) as List<dynamic>;

/// Парсинг одного объекта. Возвращает dynamic, так как конкретный тип неизвестен.
dynamic _parseObject(ParseParams params) => params.fromJson(params.json);

/// Парсинг списка объектов. Возвращает List<dynamic>.
List<dynamic> _parseList(ParseListParams params) => params.list
    .map((json) => params.fromJson(json as Map<String, dynamic>))
    .toList();

/// Параметры для парсинга объекта
class ParseParams {
  const ParseParams(this.json, this.fromJson);
  final Map<String, dynamic> json;
  final Function fromJson;
}

/// Параметры для парсинга списка
class ParseListParams {
  const ParseListParams(this.list, this.fromJson);
  final List<dynamic> list;
  final Function fromJson;
}

/// =================================================================
/// УНИВЕРСАЛЬНЫЙ ПАРСЕР
/// =================================================================
class ResponseParser {
  /// Универсальный метод парсинга ответа.
  ///
  /// Он автоматически определяет, как парсить данные (как объект или список),
  /// основываясь на их структуре.
  ///

  Future<T> parseResponse<T>(
    Response<dynamic> response, {
    // Тип `fromJson` теперь Function, так как T может быть и User, и List<User>.
    // Это всегда функция для создания одного элемента.
    Function? fromJson,
  }) async {
    final dynamic data = response.data;

    // Если парсер не предоставлен, просто возвращаем данные, приводя к типу T.
    // Это полезно, если нужны сырые данные (List<dynamic> или Map<String, dynamic>).
    if (fromJson == null) {
      if (data is T) {
        return data;
      }
      // Попытка приведения может вызвать ошибку, но это ожидаемое поведение
      // если типы не совпадают.
      return data as T;
    }

    // --- ОСНОВНАЯ ЛОГИКА ОПРЕДЕЛЕНИЯ ТИПА ---

    // 1. Если данные - это СПИСОК
    if (data is List) {
      final List<dynamic> result = await _parseListInCompute(data, fromJson);
      // Мы ожидаем, что вызывающий код запросил T как List<Model>
      return result as T;
    }

    // 2. Если данные - это ОБЪЕКТ
    if (data is Map<String, dynamic>) {
      final dynamic result = await _parseObjectInCompute(data, fromJson);
      // Мы ожидаем, что вызывающий код запросил T как Model
      return result as T;
    }

    // 3. Если данные - это СТРОКА
    if (data is String) {
      final trimmedData = data.trim();
      // Если строка выглядит как JSON-массив
      if (trimmedData.startsWith('[') && trimmedData.endsWith(']')) {
        final List<dynamic> listData = await _decodeListInCompute(trimmedData);
        final List<dynamic> result = await _parseListInCompute(
          listData,
          fromJson,
        );
        return result as T;
      }
      // Если строка выглядит как JSON-объект
      if (trimmedData.startsWith('{') && trimmedData.endsWith('}')) {
        final Map<String, dynamic> jsonData = await _decodeObjectInCompute(
          trimmedData,
        );
        final dynamic result = await _parseObjectInCompute(jsonData, fromJson);
        return result as T;
      }
    }

    // Если ни один из сценариев не подошел
    throw FormatException(
      'Не удалось распознать структуру данных для парсинга. Тип данных: ${data.runtimeType}',
    );
  }

  // --- Внутренние хелперы для вызова compute ---

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

  Future<dynamic> _parseObjectInCompute(
    Map<String, dynamic> data,
    Function fromJson,
  ) => compute(_parseObject, ParseParams(data, fromJson));

  Future<List<dynamic>> _parseListInCompute(
    List<dynamic> data,
    Function fromJson,
  ) async {
    if (data.length > 100 && !kIsWeb) {
      return compute(_parseList, ParseListParams(data, fromJson));
    }
    return _parseList(ParseListParams(data, fromJson));
  }
}

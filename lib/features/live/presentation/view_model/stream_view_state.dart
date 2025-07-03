import 'package:zefyr/features/live/data/models/stream_create_response.dart';

abstract class StreamViewState {
  const StreamViewState();

  /// Преобразует состояние в строку для отображения в UI
  String toDisplayString();

  /// Проверяет, является ли состояние ошибкой
  bool get isError;

  /// Проверяет, является ли состояние успешным
  bool get isSuccess;

  /// Проверяет, является ли состояние загрузкой
  bool get isLoading;
}

class StreamStateInitial extends StreamViewState {
  const StreamStateInitial();

  @override
  String toDisplayString() => 'StreamStateInitial';

  @override
  bool get isError => false;

  @override
  bool get isSuccess => false;

  @override
  bool get isLoading => false;
}

class StreamStateLoading extends StreamViewState {
  const StreamStateLoading();

  @override
  String toDisplayString() => 'StreamStateLoading';

  @override
  bool get isError => false;

  @override
  bool get isSuccess => false;

  @override
  bool get isLoading => true;
}

class StreamStateError extends StreamViewState {
  const StreamStateError(this.message);
  final String message;

  @override
  String toDisplayString() => 'StreamStateError: $message';

  @override
  bool get isError => true;

  @override
  bool get isSuccess => false;

  @override
  bool get isLoading => false;
}

class StreamStateSuccess extends StreamViewState {
  const StreamStateSuccess(this.stream);
  final StreamCreateResponse stream;

  @override
  String toDisplayString() => 'StreamStateSuccess';

  @override
  bool get isError => false;

  @override
  bool get isSuccess => true;

  @override
  bool get isLoading => false;
}

class StreamStateStopped extends StreamViewState {
  const StreamStateStopped();

  @override
  String toDisplayString() => 'StreamStateStopped';

  @override
  bool get isError => false;

  @override
  bool get isSuccess => false;

  @override
  bool get isLoading => false;
}

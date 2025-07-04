import 'package:zefyr/features/live/data/models/stream_create_response.dart';

enum StreamStatus { preparing, ready, live, ended, error }

class StreamStatusState {
  const StreamStatusState({
    required this.status,
    this.streamResponse,
    this.errorMessage,
  });

  final StreamStatus status;
  final StreamCreateResponse? streamResponse;
  final String? errorMessage;

  bool get isPreparing => status == StreamStatus.preparing;
  bool get isReady => status == StreamStatus.ready;
  bool get isLive => status == StreamStatus.live;
  bool get hasEnded => status == StreamStatus.ended;
  bool get hasError => status == StreamStatus.error;

  StreamStatusState copyWith({
    StreamStatus? status,
    StreamCreateResponse? streamResponse,
    String? errorMessage,
  }) => StreamStatusState(
    status: status ?? this.status,
    streamResponse: streamResponse ?? this.streamResponse,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

abstract class StreamStatusService {
  StreamStatusState getInitialState();
  StreamStatusState prepareStream(StreamCreateResponse streamResponse);
  StreamStatusState startStream();
  StreamStatusState endStream();
  StreamStatusState setError(String errorMessage);
}

class StreamStatusServiceImpl implements StreamStatusService {
  @override
  StreamStatusState getInitialState() =>
      const StreamStatusState(status: StreamStatus.preparing);

  @override
  StreamStatusState prepareStream(StreamCreateResponse streamResponse) =>
      StreamStatusState(
        status: StreamStatus.ready,
        streamResponse: streamResponse,
      );

  @override
  StreamStatusState startStream() =>
      const StreamStatusState(status: StreamStatus.live);

  @override
  StreamStatusState endStream() =>
      const StreamStatusState(status: StreamStatus.ended);

  @override
  StreamStatusState setError(String errorMessage) =>
      StreamStatusState(status: StreamStatus.error, errorMessage: errorMessage);
}

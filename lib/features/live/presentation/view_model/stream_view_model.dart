import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyr/features/live/data/models/stream_create_request.dart';
import 'package:zefyr/features/live/presentation/view_model/stream_view_state.dart';
import 'package:zefyr/features/live/usecases/create_stream.dart';
import 'package:zefyr/features/live/usecases/end_stream.dart';

class StreamViewModel extends StateNotifier<StreamViewState> {
  StreamViewModel({
    required CreateStream createStream,
    required EndStream endStream,
  }) : _createStream = createStream,
       _endStream = endStream,
       super(const StreamStateInitial());

  final CreateStream _createStream;
  final EndStream _endStream;

  Future<void> createNewStream(StreamCreateRequest request) async {
    state = const StreamStateLoading();
    final result = await _createStream.executeUseCase(request);
    result.fold(
      (failure) => state = StreamStateError(failure.message),
      (response) => state = StreamStateSuccess(response),
    );
  }

  Future<void> stopCurrentStream(String streamId) async {
    state = const StreamStateLoading();
    final result = await _endStream.executeUseCase(streamId);
    result.fold(
      (failure) => state = StreamStateError(failure.message),
      (_) => state = const StreamStateStopped(),
    );
  }
}

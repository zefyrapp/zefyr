import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyr/features/live/data/models/stream_create_response.dart';
import 'package:zefyr/features/live/data/services/camera_service.dart';
import 'package:zefyr/features/live/data/services/stream_status_service.dart';

class OnAirState {
  const OnAirState({
    required this.cameraState,
    required this.streamState,
    required this.canGoLive,
  });

  final CameraState cameraState;
  final StreamStatusState streamState;
  final bool canGoLive;

  OnAirState copyWith({
    CameraState? cameraState,
    StreamStatusState? streamState,
    bool? canGoLive,
  }) => OnAirState(
    cameraState: cameraState ?? this.cameraState,
    streamState: streamState ?? this.streamState,
    canGoLive: canGoLive ?? this.canGoLive,
  );
}

class OnAirViewModel extends StateNotifier<OnAirState> {
  OnAirViewModel({
    required CameraService cameraService,
    required StreamStatusService streamStatusService,
  }) : _cameraService = cameraService,
       _streamStatusService = streamStatusService,
       super(
         const OnAirState(
           cameraState: CameraState(status: CameraStatus.initializing),
           streamState: StreamStatusState(status: StreamStatus.preparing),
           canGoLive: false,
         ),
       );

  final CameraService _cameraService;
  final StreamStatusService _streamStatusService;

  Future<void> initializeCamera() async {
    state = state.copyWith(
      cameraState: const CameraState(status: CameraStatus.initializing),
    );

    final cameraState = await _cameraService.initializeCamera();

    state = state.copyWith(
      cameraState: cameraState,
      canGoLive: cameraState.isReady && state.streamState.isReady,
    );
  }

  void setStreamResponse(StreamCreateResponse streamResponse) {
    final streamState = _streamStatusService.prepareStream(streamResponse);
    state = state.copyWith(
      streamState: streamState,
      canGoLive: state.cameraState.isReady && streamState.isReady,
    );
  }

  Future<void> startStreaming() async {
    if (!state.canGoLive) return;

    final streamState = _streamStatusService.startStream();
    state = state.copyWith(streamState: streamState, canGoLive: false);

    // Здесь можно добавить логику начала стрима
    // например, начать передачу видео на сервер
    log('Стрим начат с токеном: ${state.streamState.streamResponse?.token}');
    log('URL для стрима: ${state.streamState.streamResponse?.url}');
  }

  Future<void> endStreaming() async {
    final streamState = _streamStatusService.endStream();
    state = state.copyWith(streamState: streamState, canGoLive: false);
  }

  Future<void> retryInitialization() async => initializeCamera();

  Future<void> openAppSettings() async => _cameraService.openAppSettings();

  Future<void> disposeCamera() async =>
      _cameraService.disposeCamera(state.cameraState.controller);
  @override
  void dispose() {
    _cameraService.disposeCamera(state.cameraState.controller);
    super.dispose();
  }
}

import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyr/features/live/data/models/stream_create_response.dart';
import 'package:zefyr/features/live/data/services/livekit_service.dart';

class LocalParticipantState {
  const LocalParticipantState({
    required this.liveKitState,
    this.streamResponse,
    this.isCameraEnabled = true,
    this.isMicrophoneEnabled = true,
    this.isStreaming = false,
  });

  final LiveKitState liveKitState;
  final StreamCreateResponse? streamResponse;
  final bool isCameraEnabled;
  final bool isMicrophoneEnabled;
  final bool isStreaming;

  bool get isConnected => liveKitState.isConnected;
  bool get isConnecting => liveKitState.isConnecting;
  bool get hasError => liveKitState.hasError;
  bool get canStartStream => isConnected && !isStreaming;
  bool get canStopStream => isConnected && isStreaming;

  LocalParticipantState copyWith({
    LiveKitState? liveKitState,
    StreamCreateResponse? streamResponse,
    bool? isCameraEnabled,
    bool? isMicrophoneEnabled,
    bool? isStreaming,
  }) => LocalParticipantState(
    liveKitState: liveKitState ?? this.liveKitState,
    streamResponse: streamResponse ?? this.streamResponse,
    isCameraEnabled: isCameraEnabled ?? this.isCameraEnabled,
    isMicrophoneEnabled: isMicrophoneEnabled ?? this.isMicrophoneEnabled,
    isStreaming: isStreaming ?? this.isStreaming,
  );
}

class LocalParticipantViewModel extends StateNotifier<LocalParticipantState> {
  LocalParticipantViewModel({
    required LiveKitService liveKitService,
    required StreamCreateResponse streamResponse,
  }) : _liveKitService = liveKitService,
       super(
         LocalParticipantState(
           liveKitState: const LiveKitState(
             status: LiveKitConnectionStatus.disconnected,
           ),
           streamResponse: streamResponse,
         ),
       ) {
    // Подписываемся на изменения состояния LiveKit
    _liveKitService.stateStream.listen((liveKitState) {
      state = state.copyWith(liveKitState: liveKitState);
    });
  }

  final LiveKitService _liveKitService;

  Future<void> connectAndStartStream() async {
    if (state.streamResponse == null) {
     log('Ошибка: StreamCreateResponse не найден');
      return;
    }

    try {
      // Подключаемся к LiveKit как издатель (стример)
      final liveKitState = await _liveKitService.connectAsPublisher(
        state.streamResponse!.url,
        state.streamResponse!.token,
      );

      if (liveKitState.isConnected) {
        state = state.copyWith(liveKitState: liveKitState, isStreaming: true);
       log('Стрим успешно начат');
      }
    } catch (e) {
     log('Ошибка начала стрима: $e');
    }
  }

  Future<void> stopStream() async {
    try {
      await _liveKitService.disconnect();
      state = state.copyWith(
        isStreaming: false,
        liveKitState: const LiveKitState(
          status: LiveKitConnectionStatus.disconnected,
        ),
      );
     log('Стрим остановлен');
    } catch (e) {
     log('Ошибка остановки стрима: $e');
    }
  }

  Future<void> toggleCamera() async {
    try {
      final newState = state.isCameraEnabled
          ? await _liveKitService.disableCamera()
          : await _liveKitService.enableCamera();

      state = state.copyWith(
        liveKitState: newState,
        isCameraEnabled: !state.isCameraEnabled,
      );
    } catch (e) {
     log('Ошибка переключения камеры: $e');
    }
  }

  Future<void> toggleMicrophone() async {
    try {
      final newState = state.isMicrophoneEnabled
          ? await _liveKitService.disableMicrophone()
          : await _liveKitService.enableMicrophone();

      state = state.copyWith(
        liveKitState: newState,
        isMicrophoneEnabled: !state.isMicrophoneEnabled,
      );
    } catch (e) {
     log('Ошибка переключения микрофона: $e');
    }
  }

  Future<void> switchCamera() async {
    try {
      final newState = await _liveKitService.switchCamera();
      state = state.copyWith(liveKitState: newState);
    } catch (e) {
     log('Ошибка переключения камеры: $e');
    }
  }

  @override
  void dispose() {
    _liveKitService.disconnect();
    super.dispose();
  }
}

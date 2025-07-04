import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:zefyr/features/live/data/services/livekit_service.dart';

class RemoteParticipantState {
  const RemoteParticipantState({
    required this.liveKitState,
    this.streamUrl,
    this.streamToken,
    this.isAudioEnabled = true,
    this.selectedRemoteParticipant,
  });

  final LiveKitState liveKitState;
  final String? streamUrl;
  final String? streamToken;
  final bool isAudioEnabled;
  final RemoteParticipant? selectedRemoteParticipant;

  bool get isConnected => liveKitState.isConnected;
  bool get isConnecting => liveKitState.isConnecting;
  bool get hasError => liveKitState.hasError;
  bool get hasRemoteParticipants =>
      liveKitState.remoteParticipants?.isNotEmpty ?? false;

  List<RemoteParticipant> get remoteParticipants =>
      liveKitState.remoteParticipants ?? [];

  // Получаем основного стримера (первого участника с видеотреком)
  RemoteParticipant? get primaryStreamer {
    if (remoteParticipants.isEmpty) return null;

    for (final participant in remoteParticipants) {
      if (participant.videoTrackPublications.isNotEmpty) {
        return participant;
      }
    }
    return remoteParticipants.first;
  }

  RemoteParticipantState copyWith({
    LiveKitState? liveKitState,
    String? streamUrl,
    String? streamToken,
    bool? isAudioEnabled,
    RemoteParticipant? selectedRemoteParticipant,
  }) => RemoteParticipantState(
    liveKitState: liveKitState ?? this.liveKitState,
    streamUrl: streamUrl ?? this.streamUrl,
    streamToken: streamToken ?? this.streamToken,
    isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
    selectedRemoteParticipant:
        selectedRemoteParticipant ?? this.selectedRemoteParticipant,
  );
}

class RemoteParticipantViewModel extends StateNotifier<RemoteParticipantState> {
  RemoteParticipantViewModel({
    required LiveKitService liveKitService,
    required String streamUrl,
    required String streamToken,
  }) : _liveKitService = liveKitService,
       super(
         RemoteParticipantState(
           liveKitState: const LiveKitState(
             status: LiveKitConnectionStatus.disconnected,
           ),
           streamUrl: streamUrl,
           streamToken: streamToken,
         ),
       ) {
    // Подписываемся на изменения состояния LiveKit
    _liveKitService.stateStream.listen((liveKitState) {
      state = state.copyWith(liveKitState: liveKitState);
    });
  }

  final LiveKitService _liveKitService;

  Future<void> connectAsViewer() async {
    if (state.streamUrl == null || state.streamToken == null) {
      print('Ошибка: URL или токен стрима не найдены');
      return;
    }

    try {
      // Подключаемся к LiveKit как зритель
      final liveKitState = await _liveKitService.connectAsViewer(
        state.streamUrl!,
        state.streamToken!,
      );

      state = state.copyWith(liveKitState: liveKitState);

      if (liveKitState.isConnected) {
        print('Успешно подключились к стриму как зритель');
      }
    } catch (e) {
      print('Ошибка подключения к стриму: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      await _liveKitService.disconnect();
      state = state.copyWith(
        liveKitState: const LiveKitState(
          status: LiveKitConnectionStatus.disconnected,
        ),
      );
      print('Отключились от стрима');
    } catch (e) {
      print('Ошибка отключения от стрима: $e');
    }
  }

  void toggleAudio() {
    state = state.copyWith(isAudioEnabled: !state.isAudioEnabled);

    // Здесь можно добавить логику для отключения/включения звука
    // Например, изменение громкости аудиотреков
    for (final participant in state.remoteParticipants) {
      for (final publication in participant.audioTrackPublications) {
        if (publication.track != null) {
          publication.track!.enable();
        }
      }
    }
  }

  void selectParticipant(RemoteParticipant participant) {
    state = state.copyWith(selectedRemoteParticipant: participant);
  }

  @override
  void dispose() {
    _liveKitService.disconnect();
    super.dispose();
  }
}

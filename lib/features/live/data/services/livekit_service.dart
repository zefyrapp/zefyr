import 'dart:async';

import 'package:livekit_client/livekit_client.dart';
import 'package:flutter/foundation.dart';

enum LiveKitConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class LiveKitState {
  const LiveKitState({
    required this.status,
    this.room,
    this.localParticipant,
    this.remoteParticipants,
    this.localVideoTrack,
    this.localAudioTrack,
    this.errorMessage,
  });

  final LiveKitConnectionStatus status;
  final Room? room;
  final LocalParticipant? localParticipant;
  final List<RemoteParticipant>? remoteParticipants;
  final LocalVideoTrack? localVideoTrack;
  final LocalAudioTrack? localAudioTrack;
  final String? errorMessage;

  bool get isConnected => status == LiveKitConnectionStatus.connected;
  bool get isConnecting => status == LiveKitConnectionStatus.connecting;
  bool get hasError => status == LiveKitConnectionStatus.error;
  bool get isDisconnected => status == LiveKitConnectionStatus.disconnected;

  LiveKitState copyWith({
    LiveKitConnectionStatus? status,
    Room? room,
    LocalParticipant? localParticipant,
    List<RemoteParticipant>? remoteParticipants,
    LocalVideoTrack? localVideoTrack,
    LocalAudioTrack? localAudioTrack,
    String? errorMessage,
  }) => LiveKitState(
    status: status ?? this.status,
    room: room ?? this.room,
    localParticipant: localParticipant ?? this.localParticipant,
    remoteParticipants: remoteParticipants ?? this.remoteParticipants,
    localVideoTrack: localVideoTrack ?? this.localVideoTrack,
    localAudioTrack: localAudioTrack ?? this.localAudioTrack,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

abstract class LiveKitService {
  Future<LiveKitState> connectAsPublisher(String url, String token);
  Future<LiveKitState> connectAsViewer(String url, String token);
  Future<void> disconnect();
  Future<LiveKitState> enableCamera();
  Future<LiveKitState> disableCamera();
  Future<LiveKitState> enableMicrophone();
  Future<LiveKitState> disableMicrophone();
  Future<LiveKitState> switchCamera();
  Stream<LiveKitState> get stateStream;
}

class LiveKitServiceImpl implements LiveKitService {
  Room? _room;
  LocalVideoTrack? _localVideoTrack;
  LocalAudioTrack? _localAudioTrack;
  CameraCaptureOptions? _captureOptions;
  EventsListener<RoomEvent>? _listener;
  LiveKitState _currentState = const LiveKitState(
    status: LiveKitConnectionStatus.disconnected,
  );

  final _stateController = StreamController<LiveKitState>.broadcast();

  @override
  Stream<LiveKitState> get stateStream => _stateController.stream;

  void _updateState(LiveKitState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  @override
  Future<LiveKitState> connectAsPublisher(String url, String token) async {
    try {
      _updateState(
        _currentState.copyWith(status: LiveKitConnectionStatus.connecting),
      );

      // Создаем комнату
      _room = Room();

      // Настраиваем слушатели событий
      _setupRoomListeners();

      // Подключаемся к комнате
      await _room!.connect(url, token);

      // Включаем камеру и микрофон для стримера
      await _enableCameraAndMicrophone();

      final newState = _currentState.copyWith(
        status: LiveKitConnectionStatus.connected,
        room: _room,
        localParticipant: _room!.localParticipant,
        remoteParticipants: _room!.remoteParticipants.values.toList(),
        localVideoTrack: _localVideoTrack,
        localAudioTrack: _localAudioTrack,
      );

      _updateState(newState);
      return newState;
    } catch (e) {
      final errorState = _currentState.copyWith(
        status: LiveKitConnectionStatus.error,
        errorMessage: 'Ошибка подключения стримера: $e',
      );
      _updateState(errorState);
      return errorState;
    }
  }

  @override
  Future<LiveKitState> connectAsViewer(String url, String token) async {
    try {
      _updateState(
        _currentState.copyWith(status: LiveKitConnectionStatus.connecting),
      );

      // Создаем комнату
      _room = Room();

      // Настраиваем слушатели событий
      _setupRoomListeners();

      // Подключаемся к комнате как зритель
      await _room!.connect(url, token);

      final newState = _currentState.copyWith(
        status: LiveKitConnectionStatus.connected,
        room: _room,
        localParticipant: _room!.localParticipant,
        remoteParticipants: _room!.remoteParticipants.values.toList(),
      );

      _updateState(newState);
      return newState;
    } catch (e) {
      final errorState = _currentState.copyWith(
        status: LiveKitConnectionStatus.error,
        errorMessage: 'Ошибка подключения зрителя: $e',
      );
      _updateState(errorState);
      return errorState;
    }
  }

  Future<void> _enableCameraAndMicrophone() async {
    try {
      // Включаем камеру
      _captureOptions = const CameraCaptureOptions(
        params: VideoParameters(
          dimensions: VideoDimensions(1280, 720),
          encoding: VideoEncoding(maxBitrate: 3000000, maxFramerate: 30),
        ),
      );

      _localVideoTrack = await LocalVideoTrack.createCameraTrack(
        _captureOptions!,
      );
      await _room!.localParticipant!.publishVideoTrack(_localVideoTrack!);

      // Включаем микрофон
      _localAudioTrack = await LocalAudioTrack.create();
      await _room!.localParticipant!.publishAudioTrack(_localAudioTrack!);
    } catch (e) {
      debugPrint('Ошибка включения камеры/микрофона: $e');
      rethrow;
    }
  }

  void _setupRoomListeners() {
    _room!.addListener(() {
      _updateState(
        _currentState.copyWith(
          remoteParticipants: _room!.remoteParticipants.values.toList(),
        ),
      );
    });

    // Настраиваем слушатель событий
    _listener = _room!.createListener();

    _listener!
      ..on<RoomConnectedEvent>(_onRoomConnected)
      ..on<RoomDisconnectedEvent>(_onRoomDisconnected)
      ..on<ParticipantConnectedEvent>(_onParticipantConnected)
      ..on<ParticipantDisconnectedEvent>(_onParticipantDisconnected)
      ..on<TrackSubscribedEvent>(_onTrackSubscribed)
      ..on<TrackUnsubscribedEvent>(_onTrackUnsubscribed)
      ..on<LocalTrackPublishedEvent>(_onLocalTrackPublished)
      ..on<RoomRecordingStatusChanged>(_onRecordingStatusChanged);
  }

  void _onRoomConnected(RoomConnectedEvent event) async {
    print('Подключились к комнате');
  }

  void _onRoomDisconnected(RoomDisconnectedEvent event) {
    print('Отключились от комнаты');
  }

  void _onParticipantConnected(ParticipantConnectedEvent event) {
    print('Участник подключился: ${event.participant.identity}');
  }

  void _onParticipantDisconnected(ParticipantDisconnectedEvent event) {
    print('Участник отключился: ${event.participant.identity}');
  }

  void _onTrackSubscribed(TrackSubscribedEvent event) {
    print('Подписались на трек: ${event.track.sid}');
  }

  void _onTrackUnsubscribed(TrackUnsubscribedEvent event) {
    print('Отписались от трека: ${event.track.sid}');
  }

  void _onLocalTrackPublished(LocalTrackPublishedEvent event) {
    print('Локальный трек опубликован: ${event.publication.sid}');
  }

  void _onRecordingStatusChanged(RoomRecordingStatusChanged event) {
    print('Статус записи изменился: ${event.activeRecording}');
  }

  @override
  Future<void> disconnect() async {
    try {
      await _localVideoTrack?.stop();
      await _localAudioTrack?.stop();

      await _localVideoTrack?.dispose();
      await _localAudioTrack?.dispose();

      await _room?.disconnect();

      await _room?.dispose();
      _room = null;
      _localVideoTrack = null;
      _localAudioTrack = null;
      await _listener?.dispose();
      _updateState(
        const LiveKitState(status: LiveKitConnectionStatus.disconnected),
      );
    } catch (e) {
      debugPrint('Ошибка отключения: $e');
    }
  }

  @override
  Future<LiveKitState> enableCamera() async {
    try {
      if (_localVideoTrack == null) {
        _localVideoTrack = await LocalVideoTrack.createCameraTrack(
          _captureOptions!,
        );
        await _room!.localParticipant!.publishVideoTrack(_localVideoTrack!);
      } else {
        await _localVideoTrack!.enable();
      }

      final newState = _currentState.copyWith(
        localVideoTrack: _localVideoTrack,
      );
      _updateState(newState);
      return newState;
    } catch (e) {
      final errorState = _currentState.copyWith(
        status: LiveKitConnectionStatus.error,
        errorMessage: 'Ошибка включения камеры: $e',
      );
      _updateState(errorState);
      return errorState;
    }
  }

  @override
  Future<LiveKitState> disableCamera() async {
    try {
      await _localVideoTrack?.disable();

      final newState = _currentState.copyWith(
        localVideoTrack: _localVideoTrack,
      );
      _updateState(newState);
      return newState;
    } catch (e) {
      final errorState = _currentState.copyWith(
        status: LiveKitConnectionStatus.error,
        errorMessage: 'Ошибка выключения камеры: $e',
      );
      _updateState(errorState);
      return errorState;
    }
  }

  @override
  Future<LiveKitState> enableMicrophone() async {
    try {
      if (_localAudioTrack == null) {
        _localAudioTrack = await LocalAudioTrack.create();
        await _room!.localParticipant!.publishAudioTrack(_localAudioTrack!);
      } else {
        await _localAudioTrack!.enable();
      }

      final newState = _currentState.copyWith(
        localAudioTrack: _localAudioTrack,
      );
      _updateState(newState);
      return newState;
    } catch (e) {
      final errorState = _currentState.copyWith(
        status: LiveKitConnectionStatus.error,
        errorMessage: 'Ошибка включения микрофона: $e',
      );
      _updateState(errorState);
      return errorState;
    }
  }

  @override
  Future<LiveKitState> disableMicrophone() async {
    try {
      await _localAudioTrack?.disable();

      final newState = _currentState.copyWith(
        localAudioTrack: _localAudioTrack,
      );
      _updateState(newState);
      return newState;
    } catch (e) {
      final errorState = _currentState.copyWith(
        status: LiveKitConnectionStatus.error,
        errorMessage: 'Ошибка выключения микрофона: $e',
      );
      _updateState(errorState);
      return errorState;
    }
  }

  @override
  Future<LiveKitState> switchCamera() async {
    try {
      final track = _currentState
          .localParticipant
          ?.videoTrackPublications
          .firstOrNull
          ?.track;
      if (track == null) return _currentState;
      final newPosition = _captureOptions?.cameraPosition.switched();
      if (newPosition == null) return _currentState;
      await track.setCameraPosition(newPosition);

      final newState = _currentState.copyWith(
        localVideoTrack: _localVideoTrack,
      );
      _updateState(newState);
      return newState;
    } catch (e) {
      final errorState = _currentState.copyWith(
        status: LiveKitConnectionStatus.error,
        errorMessage: 'Ошибка переключения камеры: $e',
      );
      _updateState(errorState);
      return errorState;
    }
  }

  void dispose() {
    _stateController.close();
  }
}

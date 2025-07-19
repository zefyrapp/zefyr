import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';

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
  bool _isDisconnecting = false;
  LiveKitState _currentState = const LiveKitState(
    status: LiveKitConnectionStatus.disconnected,
  );

  final _stateController = StreamController<LiveKitState>.broadcast();

  @override
  Stream<LiveKitState> get stateStream => _stateController.stream;

  void _updateState(LiveKitState newState) {
    _currentState = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  @override
  Future<LiveKitState> connectAsPublisher(String url, String token) async {
    try {
      _updateState(
        _currentState.copyWith(status: LiveKitConnectionStatus.connecting),
      );

      // Clean up any existing connection first
      await _cleanupConnection();

      // Create new room
      _room = Room();

      // Setup listeners before connecting
      _setupRoomListeners();

      // Connect to room
      await _room!.connect(url, token);

      // Enable camera and microphone for streamer
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
      log('Error connecting as publisher: $e');
      final errorState = _currentState.copyWith(
        status: LiveKitConnectionStatus.error,
        errorMessage: 'Connection failed: ${e.toString()}',
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

      // Clean up any existing connection first
      await _cleanupConnection();

      // Create new room
      _room = Room();

      // Setup listeners before connecting
      _setupRoomListeners();

      // Connect to room as viewer
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
      log('Error connecting as viewer: $e');
      final errorState = _currentState.copyWith(
        status: LiveKitConnectionStatus.error,
        errorMessage: 'Connection failed: ${e.toString()}',
      );
      _updateState(errorState);
      return errorState;
    }
  }

  Future<void> _enableCameraAndMicrophone() async {
    try {
      // Initialize capture options
      _captureOptions = const CameraCaptureOptions(
        params: VideoParameters(
          dimensions: VideoDimensions(1280, 720),
          encoding: VideoEncoding(maxBitrate: 2000000, maxFramerate: 30),
        ),
      );

      // Enable camera with retry logic
      await _enableCameraWithRetry();

      // Enable microphone
      _localAudioTrack = await LocalAudioTrack.create();
      await _room!.localParticipant!.publishAudioTrack(_localAudioTrack!);

      log('Camera and microphone enabled successfully');
    } catch (e) {
      log('Error enabling camera/microphone: $e');
      rethrow;
    }
  }

  Future<void> _enableCameraWithRetry({int maxRetries = 3}) async {
    int retryCount = 0;
    Exception? lastException;

    while (retryCount < maxRetries) {
      try {
        // Stop any existing video track
        if (_localVideoTrack != null) {
          await _localVideoTrack!.stop();
          await _localVideoTrack!.dispose();
          _localVideoTrack = null;
          // Add small delay to ensure camera is released
          await Future.delayed(const Duration(milliseconds: 500));
        }

        _localVideoTrack = await LocalVideoTrack.createCameraTrack(
          _captureOptions,
        );
        await _room!.localParticipant!.publishVideoTrack(_localVideoTrack!);

        log('Camera enabled successfully on attempt ${retryCount + 1}');
        return;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        retryCount++;
        log('Camera enable attempt $retryCount failed: $e');

        if (retryCount < maxRetries) {
          // Wait before retrying, with exponential backoff
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
        }
      }
    }

    if (lastException != null) {
      throw lastException;
    }
  }

  Future<void> _cleanupConnection() async {
    if (_isDisconnecting) return;
    _isDisconnecting = true;

    try {
      // Stop tracks first
      if (_localVideoTrack != null) {
        await _localVideoTrack!.stop();
        await _localVideoTrack!.dispose();
        _localVideoTrack = null;
      }

      if (_localAudioTrack != null) {
        await _localAudioTrack!.stop();
        await _localAudioTrack!.dispose();
        _localAudioTrack = null;
      }

      // Dispose listener
      if (_listener != null) {
        await _listener!.dispose();
        _listener = null;
      }

      // Disconnect and dispose room
      if (_room != null) {
        await _room!.disconnect();
        await _room!.dispose();
        _room = null;
      }

      // Small delay to ensure cleanup is complete
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      log('Error during cleanup: $e');
    } finally {
      _isDisconnecting = false;
    }
  }

  void _setupRoomListeners() {
    if (_room == null) return;

    _room!.addListener(() {
      if (!_isDisconnecting) {
        _updateState(
          _currentState.copyWith(
            remoteParticipants: _room!.remoteParticipants.values.toList(),
          ),
        );
      }
    });

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

  Future<void> _onRoomConnected(RoomConnectedEvent event) async {
    log('Connected to room successfully');
  }

  void _onRoomDisconnected(RoomDisconnectedEvent event) {
    log('Disconnected from room: ${event.reason}');
    if (!_isDisconnecting) {
      _updateState(
        _currentState.copyWith(
          status: LiveKitConnectionStatus.disconnected,
          errorMessage: 'Disconnected: ${event.reason}',
        ),
      );
    }
  }

  void _onParticipantConnected(ParticipantConnectedEvent event) {
    log('Participant connected: ${event.participant.identity}');
    _updateState(
      _currentState.copyWith(
        remoteParticipants: _room!.remoteParticipants.values.toList(),
      ),
    );
  }

  void _onParticipantDisconnected(ParticipantDisconnectedEvent event) {
    log('Participant disconnected: ${event.participant.identity}');
    _updateState(
      _currentState.copyWith(
        remoteParticipants: _room!.remoteParticipants.values.toList(),
      ),
    );
  }

  void _onTrackSubscribed(TrackSubscribedEvent event) {
    log('Subscribed to track: ${event.track.sid}');
  }

  void _onTrackUnsubscribed(TrackUnsubscribedEvent event) {
    log('Unsubscribed from track: ${event.track.sid}');
  }

  void _onLocalTrackPublished(LocalTrackPublishedEvent event) {
    log('Local track published: ${event.publication.sid}');
  }

  void _onRecordingStatusChanged(RoomRecordingStatusChanged event) {
    log('Recording status changed: ${event.activeRecording}');
  }

  @override
  Future<void> disconnect() async {
    try {
      await _cleanupConnection();
      _updateState(
        const LiveKitState(status: LiveKitConnectionStatus.disconnected),
      );
      log('Disconnected successfully');
    } catch (e) {
      log('Error during disconnect: $e');
    }
  }

  @override
  Future<LiveKitState> enableCamera() async {
    try {
      if (_room == null) {
        throw Exception('Room is not connected');
      }

      if (_localVideoTrack == null) {
        await _enableCameraWithRetry();
      } else {
        await _localVideoTrack!.enable();
      }

      final newState = _currentState.copyWith(
        localVideoTrack: _localVideoTrack,
      );
      _updateState(newState);
      return newState;
    } catch (e) {
      log('Error enabling camera: $e');
      final errorState = _currentState.copyWith(
        status: LiveKitConnectionStatus.error,
        errorMessage: 'Failed to enable camera: ${e.toString()}',
      );
      _updateState(errorState);
      return errorState;
    }
  }

  @override
  Future<LiveKitState> disableCamera() async {
    try {
      if (_localVideoTrack != null) {
        await _localVideoTrack!.disable();
      }

      final newState = _currentState.copyWith(
        localVideoTrack: _localVideoTrack,
      );
      _updateState(newState);
      return newState;
    } catch (e) {
      log('Error disabling camera: $e');
      final errorState = _currentState.copyWith(
        status: LiveKitConnectionStatus.error,
        errorMessage: 'Failed to disable camera: ${e.toString()}',
      );
      _updateState(errorState);
      return errorState;
    }
  }

  @override
  Future<LiveKitState> enableMicrophone() async {
    try {
      if (_room == null) {
        throw Exception('Room is not connected');
      }

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
      log('Error enabling microphone: $e');
      final errorState = _currentState.copyWith(
        status: LiveKitConnectionStatus.error,
        errorMessage: 'Failed to enable microphone: ${e.toString()}',
      );
      _updateState(errorState);
      return errorState;
    }
  }

  @override
  Future<LiveKitState> disableMicrophone() async {
    try {
      if (_localAudioTrack != null) {
        await _localAudioTrack!.disable();
      }

      final newState = _currentState.copyWith(
        localAudioTrack: _localAudioTrack,
      );
      _updateState(newState);
      return newState;
    } catch (e) {
      log('Error disabling microphone: $e');
      final errorState = _currentState.copyWith(
        status: LiveKitConnectionStatus.error,
        errorMessage: 'Failed to disable microphone: ${e.toString()}',
      );
      _updateState(errorState);
      return errorState;
    }
  }

  @override
  Future<LiveKitState> switchCamera() async {
    try {
      if (_room == null || _localVideoTrack == null) {
        throw Exception('Camera not available');
      }

      // Get current camera position and switch it
      final currentPosition =
          _captureOptions?.cameraPosition ?? CameraPosition.front;
      final newPosition = currentPosition == CameraPosition.front
          ? CameraPosition.back
          : CameraPosition.front;

      // Update capture options
      _captureOptions = _captureOptions?.copyWith(cameraPosition: newPosition);

      // Switch the camera
      await _localVideoTrack!.setCameraPosition(newPosition);

      final newState = _currentState.copyWith(
        localVideoTrack: _localVideoTrack,
      );
      _updateState(newState);
      return newState;
    } catch (e) {
      log('Error switching camera: $e');

      // If switching fails, try to recreate the video track
      try {
        await _enableCameraWithRetry();
        final newState = _currentState.copyWith(
          localVideoTrack: _localVideoTrack,
        );
        _updateState(newState);
        return newState;
      } catch (recreateError) {
        log('Error recreating camera after switch failure: $recreateError');
        final errorState = _currentState.copyWith(
          status: LiveKitConnectionStatus.error,
          errorMessage: 'Failed to switch camera: ${e.toString()}',
        );
        _updateState(errorState);
        return errorState;
      }
    }
  }

  void dispose() {
    disconnect();
    _stateController.close();
  }
}

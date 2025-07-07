import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:zefyr/common/extensions/invert_color.dart';
import 'package:zefyr/core/utils/icons/app_asset_icon.dart';
import 'package:zefyr/core/utils/icons/app_icons_icons.dart';
import 'package:zefyr/features/live/presentation/view_model/remote_participant_view_model.dart';
import 'package:zefyr/features/live/providers/livekit_providers.dart';
import 'package:zefyr/features/home/providers/home_stream_providers.dart';
import 'package:zefyr/features/live/providers/stream_providers.dart';

class RemoteParticipantView extends ConsumerStatefulWidget {
  const RemoteParticipantView({super.key});

  @override
  ConsumerState<RemoteParticipantView> createState() =>
      _RemoteParticipantViewState();
}

class _RemoteParticipantViewState extends ConsumerState<RemoteParticipantView> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectToStream();
    });
  }

  void _connectToStream() {
    final homeStreamState = ref.read(homeStreamViewModelProvider);

    if (homeStreamState.streamUrl != null &&
        homeStreamState.streamToken != null) {
      // Создаем провайдер для RemoteParticipantViewModel с токеном и URL
      ref
          .read(
            remoteParticipantViewModelProvider(
              RemoteParticipantViewModelParams(
                streamUrl: homeStreamState.streamUrl!,
                streamToken: homeStreamState.streamToken!,
              ),
            ).notifier,
          )
          .connectAsViewer();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeStreamState = ref.watch(homeStreamViewModelProvider);

    if (homeStreamState.streamUrl == null ||
        homeStreamState.streamToken == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Stream data not available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final state = ref.watch(
      remoteParticipantViewModelProvider(
        RemoteParticipantViewModelParams(
          streamUrl: homeStreamState.streamUrl!,
          streamToken: homeStreamState.streamToken!,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Основной видео контент
          _buildVideoContent(state),

          // Индикатор загрузки при подключении
          if (state.isConnecting)
            const ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Connecting to stream...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // Ошибка подключения
          if (state.hasError)
            ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Connection Error',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.liveKitState.errorMessage ?? 'Unknown error',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(
                              remoteParticipantViewModelProvider(
                                RemoteParticipantViewModelParams(
                                  streamUrl: homeStreamState.streamUrl!,
                                  streamToken: homeStreamState.streamToken!,
                                ),
                              ).notifier,
                            )
                            .connectAsViewer();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),

          // Виджеты в шапке
          _buildTopBar(context, state),

          // Виджет с информацией о стримере
          _buildStreamerInfo(state),

          // Виджет для написания сообщения
          _buildChatPanel(),
        ],
      ),
    );
  }

  Widget _buildVideoContent(RemoteParticipantState state) {
    if (!state.isConnected) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.videocam_off, size: 100, color: Colors.grey),
        ),
      );
    }

    // Ищем основного стримера с видеотреком
    final primaryStreamer = state.primaryStreamer;
    if (primaryStreamer == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 100, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Waiting for streamer...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Получаем видеотрек стримера
    final videoTrack = primaryStreamer.videoTrackPublications.isNotEmpty
        ? primaryStreamer.videoTrackPublications.first.track
        : null;

    if (videoTrack != null) {
      return SizedBox.expand(
        child: VideoTrackRenderer(videoTrack, fit: VideoViewFit.cover),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 100, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No video available',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    RemoteParticipantState state,
  ) => SafeArea(
    child: Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Индикатор Live
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Статус подключения
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: state.isConnected ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Кнопка звука
                    InkWell(
                      onTap: () {
                        ref
                            .read(
                              remoteParticipantViewModelProvider(
                                RemoteParticipantViewModelParams(
                                  streamUrl: state.streamUrl!,
                                  streamToken: state.streamToken!,
                                ),
                              ).notifier,
                            )
                            .toggleAudio();
                      },
                      child: Icon(
                        state.isAudioEnabled
                            ? Icons.volume_up
                            : Icons.volume_off,
                        color: Colors.white.invertColor(),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Кнопка закрытия
                    InkWell(
                      onTap: () {
                        ref
                            .read(
                              remoteParticipantViewModelProvider(
                                RemoteParticipantViewModelParams(
                                  streamUrl: state.streamUrl!,
                                  streamToken: state.streamToken!,
                                ),
                              ).notifier,
                            )
                            .disconnect();
                        context.pop();
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.white.invertColor(),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Информация о зрителях и донатах
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.remove_red_eye_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      state.remoteParticipants.length.toString(),
                      style: TextStyle(
                        color: Colors.white.invertColor(),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        // Поделиться стримом
                      },
                      child: Icon(
                        AppIcons.share,
                        color: Colors.white.invertColor(),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Image.asset(AppAssetIcon.money, height: 18, width: 18),
                        const SizedBox(width: 4),
                        Text(
                          '100',
                          style: TextStyle(
                            color: Colors.white.invertColor(),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildStreamerInfo(RemoteParticipantState state) {
    final primaryStreamer = state.primaryStreamer;

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 64 + 18,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              // Аватар стримера
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://placebeard.it/640/480',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[600],
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Информация о стримере
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      primaryStreamer?.identity ?? 'Unknown Streamer',
                      style: TextStyle(
                        color: Colors.white.invertColor(),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      state.isConnected ? 'Live streaming' : 'Offline',
                      style: TextStyle(
                        color: Colors.white.invertColor().withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatPanel() => Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.8)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xff1E1E1E),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: TextField(
                    controller: _messageController,
                    cursorHeight: 14,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      isCollapsed: true,
                      constraints: BoxConstraints(minHeight: 40),
                      hintText: 'Say something...',
                      hintStyle: TextStyle(
                        color: Color(0xffADAEBC),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      suffixIcon: Icon(
                        Icons.emoji_emotions_outlined,
                        size: 16,
                        color: Color(0xff9CA3AF),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: _sendMessage,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DecoratedBox(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFB18CFE),
                ),
                child: IconButton(
                  style: const ButtonStyle(
                    fixedSize: WidgetStatePropertyAll(Size(40, 40)),
                  ),
                  icon: const Icon(Icons.send, size: 16, color: Colors.white),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    // Здесь можно добавить логику отправки сообщения через LiveKit
    // Например, отправка data message

    _messageController.clear();
  }
}

// Класс для параметров провайдера
class RemoteParticipantViewModelParams {
  const RemoteParticipantViewModelParams({
    required this.streamUrl,
    required this.streamToken,
  });

  final String streamUrl;
  final String streamToken;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RemoteParticipantViewModelParams &&
        other.streamUrl == streamUrl &&
        other.streamToken == streamToken;
  }

  @override
  int get hashCode => streamUrl.hashCode ^ streamToken.hashCode;
}

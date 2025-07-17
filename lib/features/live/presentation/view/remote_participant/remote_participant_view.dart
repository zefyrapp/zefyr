
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:zefyr/common/extensions/invert_color.dart';
import 'package:zefyr/core/utils/icons/app_icons_icons.dart';
import 'package:zefyr/features/home/providers/home_stream_providers.dart';
import 'package:zefyr/features/live/presentation/view_model/remote_participant_view_model.dart';
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
    final remotePod = ref.read(
      remoteParticipantViewModelProvider(
        RemoteParticipantViewModelParams(
          streamUrl: homeStreamState.streamUrl!,
          streamToken: homeStreamState.streamToken!,
        ),
      ).notifier,
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
                      onPressed: remotePod.connectAsViewer,

                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),

          // Виджеты в шапке
          _buildTopBar(context, state),

          _buildAnimatedBottomWidget(state, remotePod),
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

  Widget _buildTopBar(BuildContext context, RemoteParticipantState state) =>
      SafeArea(
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
                      child: const Icon(
                        Icons.arrow_back_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons.remove_red_eye_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          state.remoteParticipants.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 11),
                        InkWell(
                          onTap: () {
                            // Поделиться стримом
                          },
                          child: const Icon(
                            AppIcons.share,
                            color: Colors.white,
                            size: 16,
                          ),
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
  Widget _buildAnimatedBottomWidget(
    RemoteParticipantState state,
    RemoteParticipantViewModel remotePod,
  ) => Align(
    alignment: Alignment.bottomCenter,
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
            child: FadeTransition(opacity: animation, child: child),
          ),
      child: state.isChat
          ? _buildChatPanel()
          : _buildStreamerInfo(state, remotePod),
    ),
  );

  Widget _buildStreamerInfo(
    RemoteParticipantState state,
    RemoteParticipantViewModel remotePod,
  ) {
    final primaryStreamer = state.primaryStreamer;
    const backgroundColor = Colors.black;

    // Рассчитываем итоговый цвет кнопки с учетом прозрачности
    final buttonBackgroundColor = Colors.white.withValues(alpha: .45);
    final effectiveButtonColor = buttonBackgroundColor.withBackground(
      backgroundColor,
    );

    // Получаем контрастный цвет для иконки
    final iconColor = effectiveButtonColor.getContrastingColor();
    return SafeArea(
      key: const ValueKey('streamer_info'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          spacing: 6,
          children: [
            Material(
              color: buttonBackgroundColor,
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                onTap: remotePod.toggleChat,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 15,
                  ),
                  child: Icon(Icons.chat, color: iconColor),
                ),
              ),
            ),
            // Аватар стримера
            Material(
              color: buttonBackgroundColor,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 19.0,
                  top: 10,
                  bottom: 10,
                  right: 9,
                ),
                child: Row(
                  spacing: 12,
                  children: [
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
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
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
                    SizedBox(
                      width: 52,
                      child: Text(
                        primaryStreamer?.identity ?? 'Unknown Streamer',
                        maxLines: 1,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          height: 20 / 14,

                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      label: const Text(
                        'follow',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,

                          fontSize: 14,
                          height: 20 / 14,
                          color: Colors.white,
                        ),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Color(0xff9972F4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 17, vertical: 15),
                child: Icon(Icons.card_giftcard, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatPanel() => Container(
    key: const ValueKey('chat_panel'),
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
  );

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    //!TODO отправка сообщения через LiveKit либо через функционал отправки сообщения

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

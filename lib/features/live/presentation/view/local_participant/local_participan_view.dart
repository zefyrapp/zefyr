import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:zefyr/common/extensions/invert_color.dart';
import 'package:zefyr/core/utils/icons/app_asset_icon.dart';
import 'package:zefyr/core/utils/icons/app_icons_icons.dart';
import 'package:zefyr/features/live/presentation/view_model/local_participant_view_model.dart';
import 'package:zefyr/features/live/providers/livekit_providers.dart';

class LocalParticipanView extends ConsumerStatefulWidget {
  const LocalParticipanView({super.key});

  @override
  ConsumerState<LocalParticipanView> createState() =>
      _LocalParticipanViewState();
}

class _LocalParticipanViewState extends ConsumerState<LocalParticipanView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(localParticipantViewModel.notifier).connectAndStartStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(localParticipantViewModel);
    return Scaffold(
      body: Stack(
        children: [
          // Основной видео контент
          _buildVideoContent(state),

          /// Виджеты в шапке
          _buildToolBar(context, state),

          // /// Виджет с аватаром и текстком
          // _buildAvatarPanel(),

          /// Виджет с для написания сообщения
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildVideoContent(LocalParticipantState state) {
    if (state.liveKitState.localVideoTrack != null) {
      return SizedBox.expand(
        child: VideoTrackRenderer(
          state.liveKitState.localVideoTrack!,
          fit: VideoViewFit.cover,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.videocam_off, size: 100, color: Colors.grey),
      ),
    );
  }

  Widget _buildToolBar(BuildContext context, LocalParticipantState state) =>
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
                    Row(
                      children: [
                        Text(
                          'Live',
                          style: TextStyle(
                            color: Colors.white.invertColor(),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: context.pop,
                      child: Icon(
                        Icons.close,
                        color: Colors.white.invertColor(),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          spacing: 5,
                          children: [
                            const Icon(Icons.remove_red_eye_outlined, size: 18),
                            Text(
                              state.liveKitState.remoteParticipants?.length
                                      .toString() ??
                                  '0',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,

                                fontSize: 12,
                                height: 1,
                                color: Colors.white.invertColor(),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {},
                          child: Icon(
                            AppIcons.share,
                            color: Colors.white.invertColor(),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Image.asset(AppAssetIcon.money, height: 18, width: 18),
                        Text(
                          '100',
                          style: TextStyle(
                            fontFamily: ' Inter',
                            fontWeight: FontWeight.w400,

                            fontSize: 12,
                            height: 1,

                            color: Colors.white.invertColor(),
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

  // Widget _buildAvatarPanel() => Positioned(
  //   bottom: View.of(context).viewInsets.bottom + 64 + 32,
  //   child: SafeArea(
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //       child: Row(
  //         children: [
  //           Container(
  //             width: 34,
  //             height: 34,
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               border: Border.all(color: Colors.green, width: 2),
  //             ),
  //             child: ClipOval(
  //               child: Image.network(
  //                 'https://placebeard.it/640/480',
  //                 width: 32,
  //                 height: 32,
  //                 fit: BoxFit.cover,
  //                 errorBuilder: (context, error, stackTrace) => Container(
  //                   color: Colors.grey[600],
  //                   child: const Icon(
  //                     Icons.person,
  //                     color: Colors.white,
  //                     size: 20,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           Text(
  //             'Вы ведете прямую трансляцию',
  //             style: TextStyle(
  //               fontFamily: 'Poppins',
  //               fontWeight: FontWeight.w400,
  //               fontSize: 12,
  //               height: 16 / 12,
  //               letterSpacing: 0,
  //               color: Colors.white.invertColor(),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   ),
  // );

  Widget _buildBottomPanel() => Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
            child: Row(
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
                Text(
                  'Вы ведете прямую трансляцию',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 16 / 12,
                    letterSpacing: 0,
                    color: Colors.white.invertColor(),
                  ),
                ),
              ],
            ),
          ),
          Container(
            // height: 64,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
            ),
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
                          cursorHeight: 14,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            isCollapsed: true,
                            constraints: const BoxConstraints(minHeight: 40),
                            hintText: 'Say something...',
                            hintStyle: const TextStyle(
                              color: Color(0xffADAEBC),
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.emoji_emotions_outlined,
                                size: 16,
                                color: Color(0xff9CA3AF),
                              ),
                              onPressed: () {
                                // open emoji picker
                              },
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(
                          0xFFB18CFE,
                        ), // сиреневый цвет как на картинке
                      ),
                      child: IconButton(
                        style: const ButtonStyle(
                          fixedSize: WidgetStatePropertyAll(Size(40, 40)),
                        ),
                        icon: const Icon(
                          Icons.send,
                          size: 16,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // send message
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

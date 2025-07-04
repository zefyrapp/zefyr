import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';

class LocalParticipanView extends StatelessWidget {
  const LocalParticipanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ClipRRect(
            child: VideoTrackRenderer(
              participantTrack.videoTrack!,
              fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zefyr/features/live/data/services/livekit_service.dart';
import 'package:zefyr/features/live/presentation/view_model/local_participant_view_model.dart';
import 'package:zefyr/features/live/presentation/view_model/stream_view_state.dart';
import 'package:zefyr/features/live/providers/stream_providers.dart';

part 'livekit_providers.g.dart';

// LiveKit
@riverpod
LiveKitService liveKitService(Ref ref) => LiveKitServiceImpl();

final localParticipantViewModel =
    AutoDisposeStateNotifierProvider<
      LocalParticipantViewModel,
      LocalParticipantState
    >((ref) {
      // Получаем streamResponse из основного провайдера
      final streamState = ref.read(streamViewModelProvider);
      final streamResponse = streamState is StreamStateSuccess
          ? streamState.stream
          : null;

      return LocalParticipantViewModel(
        liveKitService: ref.read(liveKitServiceProvider),
        streamResponse: streamResponse!,
      );
    });

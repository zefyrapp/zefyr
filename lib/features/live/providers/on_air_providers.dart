import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zefyr/features/live/data/services/camera_service.dart';
import 'package:zefyr/features/live/data/services/stream_status_service.dart';
import 'package:zefyr/features/live/presentation/view_model/on_air_view_model.dart';

part 'on_air_providers.g.dart';

// Services
@riverpod
CameraService cameraService(Ref ref) => CameraServiceImpl();

@riverpod
StreamStatusService streamStatusService(Ref ref) => StreamStatusServiceImpl();

// ViewModel
final onAirViewModelProvider =
    AutoDisposeStateNotifierProvider<OnAirViewModel, OnAirState>((ref) {
      ref.onDispose(() {});
      return OnAirViewModel(
        cameraService: ref.watch(cameraServiceProvider),
        streamStatusService: ref.watch(streamStatusServiceProvider),
      );
    });

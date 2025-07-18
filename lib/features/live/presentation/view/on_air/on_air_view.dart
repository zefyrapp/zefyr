import 'dart:async';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zefyr/common/extensions/context_theme.dart';
import 'package:zefyr/common/extensions/invert_color.dart';
import 'package:zefyr/features/auth/providers/auth_providers.dart';
import 'package:zefyr/features/live/data/models/stream_create_request.dart';
import 'package:zefyr/features/live/data/services/camera_service.dart';
import 'package:zefyr/features/live/presentation/view_model/on_air_view_model.dart';
import 'package:zefyr/features/live/presentation/view_model/stream_view_state.dart';
import 'package:zefyr/features/live/providers/on_air_providers.dart';
import 'package:zefyr/features/live/providers/stream_providers.dart';

class OnAirView extends ConsumerStatefulWidget {
  const OnAirView({super.key});

  @override
  ConsumerState<OnAirView> createState() => _OnAirViewState();
}

class _OnAirViewState extends ConsumerState<OnAirView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeOnAir();
    });
  }

  void _initializeOnAir() {
    // Инициализируем камеру
    ref.read(onAirViewModelProvider.notifier).initializeCamera();

    // Получаем информацию о стриме из основного провайдера
    final streamState = ref.read(streamViewModelProvider);
    if (streamState is StreamStateSuccess) {
      ref
          .read(onAirViewModelProvider.notifier)
          .setStreamResponse(streamState.stream);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final onAirPod = ref.read(onAirViewModelProvider);
    if (onAirPod.cameraState.controller == null ||
        !onAirPod.cameraState.controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      ref.read(onAirViewModelProvider.notifier).disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(onAirViewModelProvider.notifier).retryInitialization();
    }
  }

  @override
  void didUpdateWidget(covariant OnAirView oldWidget) {
    log('OnAirView didUpdateWidget $oldWidget');
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onAirState = ref.watch(onAirViewModelProvider);
    final streamState = ref.watch(streamViewModelProvider);
    ref.watch(streamFormProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Основной контент стрима
          _buildCameraPreview(onAirState.cameraState),

          // Верхняя панель с информацией о стриме
          _buildTopBar(context, streamState, onAirState),

          // Нижняя панель с кнопками управления
          _buildBottomPanel(context, onAirState),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(CameraState cameraState) {
    if (cameraState.isInitializing) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.purple),
              SizedBox(height: 16),
              Text(
                'Настройка камеры...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (cameraState.hasError ||
        cameraState.hasNoPermission ||
        cameraState.noCameraFound) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getErrorIcon(cameraState), color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                cameraState.errorMessage ?? 'Неизвестная ошибка',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (cameraState.hasNoPermission)
                ElevatedButton(
                  onPressed: () => ref
                      .read(onAirViewModelProvider.notifier)
                      .openAppSettings(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text(
                    'Открыть настройки',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (cameraState.isReady && cameraState.controller != null) {
      return SizedBox.expand(child: CameraPreview(cameraState.controller!));
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

  Widget _buildTopBar(
    BuildContext context,
    StreamViewState streamState,
    OnAirState onAirState,
  ) => SafeArea(
    child: Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white.invertColor()),
            onPressed: () => context.pushReplacement('/'),
          ),
          // const SizedBox(width: 8),
          // if (streamState is StreamStateSuccess) ...[
          //   Expanded(
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         Text(
          //           streamState.stream.stream?.title ?? '',
          //           style: const TextStyle(
          //             color: Colors.white,
          //             fontSize: 16,
          //             fontWeight: FontWeight.w600,
          //           ),
          //           overflow: TextOverflow.ellipsis,
          //         ),
          //         Text(
          //           streamState.stream.stream?.description ?? '',
          //           style: TextStyle(color: Colors.grey[400], fontSize: 14),
          //           overflow: TextOverflow.ellipsis,
          //         ),
          //       ],
          //     ),
          //   ),
          // ],
          // // Статус стрима
          // _buildStatusBadge(onAirState),
          IconButton(
            onPressed: () =>
                context.push('/onAir/streamSettings').then((value) async {
                  if (value == true) {
                    // final formState = ref.read(streamFormProvider);

                    // if (formState.canCreateStream) {
                    //   final request = formState.toRequest();
                    //   await ref
                    //       .read(streamViewModelProvider.notifier)
                    //       .createNewStream(request);
                    // }
                  }
                }),
            icon: Icon(Icons.settings, color: Colors.white.invertColor()),
          ),
        ],
      ),
    ),
  );

  Widget _buildStatusBadge(OnAirState onAirState) {
    String statusText;
    Color statusColor;

    if (onAirState.streamState.isLive) {
      statusText = 'LIVE';
      statusColor = Colors.red;
    } else if (onAirState.canGoLive) {
      statusText = 'ГОТОВ';
      statusColor = Colors.green;
    } else {
      statusText = 'НАСТРОЙКА';
      statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomPanel(
    BuildContext context,
    OnAirState onAirState,
  ) => SafeArea(
    child: Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Главная кнопка действия
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _getMainButtonAction(onAirState),
                style: context.customTheme.overlayApp.elevatedStyle.copyWith(
                  backgroundColor: WidgetStateColor.resolveWith((state) {
                    // if (!onAirState.canGoLive) return Colors.grey;
                    return const Color(0xff9972F4);
                  }),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getMainButtonIcon(onAirState),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getMainButtonText(onAirState),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        height: 1,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Кнопка повтора при ошибке
            if (onAirState.cameraState.hasError) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref
                    .read(onAirViewModelProvider.notifier)
                    .retryInitialization(),
                child: const Text(
                  'Повторить',
                  style: TextStyle(color: Colors.purple),
                ),
              ),
            ],

            // Кнопка завершения стрима
            if (onAirState.streamState.isLive) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _showEndStreamDialog(context),
                child: const Text(
                  'Завершить стрим',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  IconData _getErrorIcon(CameraState cameraState) {
    if (cameraState.hasNoPermission) return Icons.security;
    if (cameraState.noCameraFound) return Icons.videocam_off;
    return Icons.error_outline;
  }

  VoidCallback? _getMainButtonAction(OnAirState onAirState) {
    return () => _showGoLiveDialog(context);
    // if (onAirState.streamState.isLive) return null;
    // if (onAirState.canGoLive) return () => _showGoLiveDialog(context);
    // if (onAirState.cameraState.hasError) {
    //   return () =>
    //       ref.read(onAirViewModelProvider.notifier).retryInitialization();
    // }
    // return null;
  }

  IconData _getMainButtonIcon(OnAirState onAirState) {
    return Icons.videocam;
    // if (onAirState.streamState.isLive) return Icons.stop;
    // if (onAirState.canGoLive) return Icons.videocam;
    // return Icons.videocam_off;
  }

  String _getMainButtonText(OnAirState onAirState) {
    return 'Выйти в эфир';
    // if (onAirState.streamState.isLive) return 'В ЭФИРЕ';
    // if (onAirState.canGoLive) return 'Выйти в эфир';
    // if (onAirState.cameraState.hasError) return 'Повторить настройку';
    // return 'Настройка...';
  }

  void _showGoLiveDialog(BuildContext context) {
    final rootContext = context; // сохраняем валидный контекст
    final overlay = Overlay.of(rootContext);
    late OverlayEntry loaderOverlay;

    loaderOverlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withValues(alpha: 0.5),
          ),
          const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );

    showDialog(
      context: rootContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Выйти в эфир?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Вы готовы начать трансляцию?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              overlay.insert(loaderOverlay);

              try {
                final formState = ref.read(streamFormProvider);
                var request = formState.toRequest();

                if (request.title.isEmpty) {
                  final user = await ref.read(userDaoProvider).getUser();
                  final name = user?.user?.name;
                  request = StreamCreateRequest(
                    title: name != null && name.isNotEmpty
                        ? name
                        : "New Stream",
                    description: '',
                    previewUrl: '',
                  );
                }

                await ref
                    .read(streamViewModelProvider.notifier)
                    .createNewStream(request);

                loaderOverlay.remove();

                if (rootContext.mounted) {
                  rootContext.pushReplacement('/onAir/localParticipant');
                }
              } catch (e) {
                loaderOverlay.remove();
                if (rootContext.mounted) {
                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    const SnackBar(content: Text('Ошибка при создании стрима')),
                  );
                }
              }
            },
            child: const Text('Начать', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  void _showEndStreamDialog(BuildContext context) => showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text(
        'Завершить стрим?',
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        'Вы уверены, что хотите завершить трансляцию?',
        style: TextStyle(color: Colors.grey),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            ref.read(onAirViewModelProvider.notifier).endStreaming();
            Navigator.of(context).pop(); // Возвращаемся к предыдущему экрану
          },
          child: const Text('Завершить', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

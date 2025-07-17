import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zefyr/common/extensions/context_theme.dart';
import 'package:zefyr/common/extensions/media_query.dart';
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
  void dispose() {
    ref.read(onAirViewModelProvider.notifier).disposeCamera();
    super.dispose();
  }

  void _goBack() {
    // Диспозим камеру перед переходом
    ref.read(onAirViewModelProvider.notifier).disposeCamera();
    // Переходим на главную
    context.go('/');
  }

  void _openSettings() {
    // Открываем экран настроек стрима
    context.push('/live/settings').then((_) {
      // После возврата из настроек можно обновить состояние если нужно
    });
  }

  Future<void> _goLive() async {
    final formState = ref.read(streamFormProvider);

    if (formState.canCreateStream) {
      final request = formState.toRequest();
      await ref
          .read(streamViewModelProvider.notifier)
          .createNewStream(request)
          .whenComplete(() => context.push('/onAir/localParticipant'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final onAirState = ref.watch(onAirViewModelProvider);
    final streamState = ref.watch(streamViewModelProvider);

    // Слушаем изменения состояния стрима
    ref.listen<StreamViewState>(streamViewModelProvider, (previous, next) {
      if (next is StreamStateSuccess) {
        // Стрим успешно создан, можно показать уведомление или обновить UI
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Стрим создан успешно!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (next is StreamStateError) {
        // Показываем ошибку
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Основной контент стрима
          _buildCameraPreview(onAirState.cameraState),

          // Верхняя панель с кнопками
          _buildTopBar(context),

          // Нижняя панель с кнопками управления
          _buildBottomPanel(context, onAirState, streamState),
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

  Widget _buildTopBar(BuildContext context) => SafeArea(
    child: Container(
      width: context.width,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Кнопка назад
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goBack,
          ),

          // Кнопка настроек
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _openSettings,
          ),
        ],
      ),
    ),
  );

  Widget _buildBottomPanel(
    BuildContext context,
    OnAirState onAirState,
    StreamViewState streamState,
  ) => SafeArea(
    child: Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Главная кнопка "Выйти в эфир"
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _getMainButtonAction(onAirState, streamState),
                style: context.customTheme.overlayApp.elevatedStyle.copyWith(
                  backgroundColor: WidgetStateColor.resolveWith((state) {
                    if (!_canGoLive(onAirState, streamState))
                      return Colors.grey;
                    return const Color(0xff9972F4);
                  }),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (streamState.isLoading) ...[
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      Icon(
                        _getMainButtonIcon(onAirState),
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _getMainButtonText(onAirState, streamState),
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

            // Кнопка повтора при ошибке камеры
            if (onAirState.cameraState.hasError) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref
                    .read(onAirViewModelProvider.notifier)
                    .retryInitialization(),
                child: const Text(
                  'Повторить настройку камеры',
                  style: TextStyle(color: Colors.purple),
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

  bool _canGoLive(OnAirState onAirState, StreamViewState streamState) {
    final formState = ref.watch(streamFormProvider);
    return onAirState.cameraState.isReady &&
        formState.canCreateStream &&
        !streamState.isLoading;
  }

  VoidCallback? _getMainButtonAction(
    OnAirState onAirState,
    StreamViewState streamState,
  ) {
    if (streamState.isLoading) return null;

    if (onAirState.cameraState.hasError) {
      return () =>
          ref.read(onAirViewModelProvider.notifier).retryInitialization();
    }

    if (_canGoLive(onAirState, streamState)) {
      return _goLive;
    }

    return null;
  }

  IconData _getMainButtonIcon(OnAirState onAirState) {
    if (onAirState.cameraState.hasError) return Icons.refresh;
    return Icons.videocam;
  }

  String _getMainButtonText(
    OnAirState onAirState,
    StreamViewState streamState,
  ) {
    if (streamState.isLoading) return 'Создание стрима...';

    if (onAirState.cameraState.hasError) return 'Повторить настройку';

    if (onAirState.cameraState.isInitializing) return 'Настройка камеры...';

    final formState = ref.read(streamFormProvider);
    if (!formState.canCreateStream) return 'Настройте стрим';

    if (_canGoLive(onAirState, streamState)) return 'Выйти в эфир';

    return 'Подготовка...';
  }
}

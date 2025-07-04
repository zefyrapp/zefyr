import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zefyr/features/live/presentation/view_model/stream_view_state.dart';
import 'package:zefyr/features/live/providers/stream_providers.dart';

class OnAirView extends ConsumerStatefulWidget {
  const OnAirView({super.key});

  @override
  ConsumerState<OnAirView> createState() => _OnAirViewState();
}

class _OnAirViewState extends ConsumerState<OnAirView> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isPermissionGranted = false;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Запрашиваем разрешение на камеру
      final cameraPermission = await Permission.camera.request();
      final microphonePermission = await Permission.microphone.request();

      if (cameraPermission.isGranted && microphonePermission.isGranted) {
        setState(() {
          _isPermissionGranted = true;
        });

        // Получаем доступные камеры
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          // Используем переднюю камеру, если доступна
          final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          );

          // Инициализируем контроллер камеры
          _cameraController = CameraController(
            frontCamera,
            ResolutionPreset.medium,
            enableAudio: true,
          );

          await _cameraController!.initialize();

          setState(() {
            _isCameraInitialized = true;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Камера не найдена';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Необходимо разрешение на использование камеры и микрофона';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка инициализации камеры: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(streamViewModelProvider) as StreamStateSuccess;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Основной контент стрима
          _buildCameraPreview(),

          // Верхняя панель с информацией о стриме
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          model.stream.stream.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          model.stream.stream.description,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Статус LIVE или ГОТОВ
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _isCameraInitialized ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _isCameraInitialized ? 'ГОТОВ' : 'НАСТРОЙКА',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Нижняя панель с кнопкой "Выйти в эфир"
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Кнопка "Выйти в эфир"
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCameraInitialized
                            ? () {
                                _showGoLiveDialog(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCameraInitialized
                              ? Colors.purple
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isCameraInitialized
                                  ? Icons.videocam
                                  : Icons.videocam_off,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isCameraInitialized
                                  ? 'Выйти в эфир'
                                  : 'Настройка камеры...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Кнопка повтора инициализации при ошибке
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = '';
                          });
                          _initializeCamera();
                        },
                        child: const Text(
                          'Повторить',
                          style: TextStyle(color: Colors.purple),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isLoading) {
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

    if (_errorMessage.isNotEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (!_isPermissionGranted)
                ElevatedButton(
                  onPressed: () async {
                    await openAppSettings();
                  },
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

    if (_isCameraInitialized && _cameraController != null) {
      return SizedBox.expand(child: CameraPreview(_cameraController!));
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

  void _showGoLiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Здесь можно добавить логику начала стрима
              _startStreaming();
            },
            child: const Text('Начать', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  void _startStreaming() {
    // Здесь будет логика начала стрима
    // Например, начать запись или передачу видео на сервер
    print('Стрим начат!');
  }
}

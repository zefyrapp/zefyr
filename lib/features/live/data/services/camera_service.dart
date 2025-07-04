import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

enum CameraStatus { initializing, ready, error, noPermission, noCameraFound }

class CameraState {
  const CameraState({required this.status, this.controller, this.errorMessage});

  final CameraStatus status;
  final CameraController? controller;
  final String? errorMessage;

  bool get isReady => status == CameraStatus.ready && controller != null;
  bool get isInitializing => status == CameraStatus.initializing;
  bool get hasError => status == CameraStatus.error;
  bool get hasNoPermission => status == CameraStatus.noPermission;
  bool get noCameraFound => status == CameraStatus.noCameraFound;

  CameraState copyWith({
    CameraStatus? status,
    CameraController? controller,
    String? errorMessage,
  }) => CameraState(
    status: status ?? this.status,
    controller: controller ?? this.controller,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

abstract class CameraService {
  Future<CameraState> initializeCamera();
  Future<void> disposeCamera(CameraController? controller);
  Future<bool> requestPermissions();
  Future<void> openAppSettings();
}

class CameraServiceImpl implements CameraService {
  @override
  Future<CameraState> initializeCamera() async {
    try {
      // Проверяем разрешения
      final hasPermissions = await requestPermissions();
      if (!hasPermissions) {
        return const CameraState(
          status: CameraStatus.noPermission,
          errorMessage:
              'Необходимо разрешение на использование камеры и микрофона',
        );
      }

      // Получаем доступные камеры
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return const CameraState(
          status: CameraStatus.noCameraFound,
          errorMessage: 'Камера не найдена',
        );
      }

      // Выбираем переднюю камеру или первую доступную
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // Инициализируем контроллер
      final controller = CameraController(camera, ResolutionPreset.medium,);

      await controller.initialize();

      return CameraState(status: CameraStatus.ready, controller: controller);
    } catch (e) {
      return CameraState(
        status: CameraStatus.error,
        errorMessage: 'Ошибка инициализации камеры: $e',
      );
    }
  }

  @override
  Future<void> disposeCamera(CameraController? controller) async =>
      controller?.dispose();

  @override
  Future<bool> requestPermissions() async {
    final cameraPermission = await Permission.camera.request();
    final microphonePermission = await Permission.microphone.request();

    return cameraPermission.isGranted && microphonePermission.isGranted;
  }

  @override
  Future<void> openAppSettings() async => openAppSettings();
}

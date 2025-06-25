import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Абстрактный интерфейс для проверки сетевого соединения
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Future<List<ConnectivityResult>> get connectionType;
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
  Future<bool> hasInternetAccess();
}

/// Реализация NetworkInfo с использованием connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl(this.connectivity);
  final Connectivity connectivity;

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none) && result.isNotEmpty;
  }

  @override
  Future<List<ConnectivityResult>> get connectionType async =>
      connectivity.checkConnectivity();

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      connectivity.onConnectivityChanged;

  @override
  Future<bool> hasInternetAccess() async {
    try {
      final isConnected = await this.isConnected;
      if (!isConnected) return false;

      // Проверяем реальный доступ к интернету
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// Расширения для ConnectivityResult
extension ConnectivityResultExtension on ConnectivityResult {
  bool get isConnected => this != ConnectivityResult.none;

  bool get isWifi => this == ConnectivityResult.wifi;

  bool get isMobile => this == ConnectivityResult.mobile;

  bool get isEthernet => this == ConnectivityResult.ethernet;

  String get displayName => switch (this) {
    ConnectivityResult.wifi => 'WiFi',
    ConnectivityResult.mobile => 'Мобильная сеть',
    ConnectivityResult.ethernet => 'Ethernet',
    ConnectivityResult.none => 'Нет соединения',
    _ => 'Неизвестно',
  };
}

/// Расширения для List<ConnectivityResult>
extension ConnectivityResultListExtension on List<ConnectivityResult> {
  bool get isConnected => isNotEmpty && !contains(ConnectivityResult.none);

  bool get hasWifi => contains(ConnectivityResult.wifi);

  bool get hasMobile => contains(ConnectivityResult.mobile);

  bool get hasEthernet => contains(ConnectivityResult.ethernet);

  String get displayName {
    if (isEmpty || contains(ConnectivityResult.none)) {
      return 'Нет соединения';
    }

    final types = where(
      (result) => result != ConnectivityResult.none,
    ).map((result) => result.displayName).toList();

    return types.join(', ');
  }

  ConnectivityResult get primary {
    if (isEmpty) return ConnectivityResult.none;

    // Приоритет: WiFi > Ethernet > Mobile
    if (contains(ConnectivityResult.wifi)) return ConnectivityResult.wifi;
    if (contains(ConnectivityResult.ethernet)) {
      return ConnectivityResult.ethernet;
    }
    if (contains(ConnectivityResult.mobile)) return ConnectivityResult.mobile;

    return first;
  }
}

/// Утилиты для работы с сетью
class NetworkUtils {
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Проверяет доступность конкретного хоста
  static Future<bool> isHostReachable(
    String host, {
    Duration timeout = defaultTimeout,
  }) async {
    try {
      final result = await InternetAddress.lookup(host).timeout(timeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Получает информацию о текущем соединении
  static Future<Map<String, dynamic>> getConnectionInfo() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();

    return {
      'types': result.map((r) => r.displayName).toList(),
      'primary': result.primary.displayName,
      'isConnected': result.isConnected,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Ожидает восстановления соединения
  static Future<bool> waitForConnection({
    Duration timeout = const Duration(minutes: 2),
    Duration checkInterval = const Duration(seconds: 1),
  }) async {
    final networkInfo = NetworkInfoImpl(Connectivity());
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      if (await networkInfo.hasInternetAccess()) {
        return true;
      }
      await Future.delayed(checkInterval);
    }

    return false;
  }
}

import 'dart:math' show pow;
import 'dart:ui';

extension InvertColor on Color {
  Color invertColor() => Color.fromARGB(
    (a * 255.0).round() & 0xff,
    255 - (r * 255.0).round() & 0xff,
    255 - (g * 255.0).round() & 0xff,
    255 - (b * 255.0).round() & 0xff,
  );
}

extension AdaptiveColor on Color {
  /// Возвращает цвет с учетом прозрачности на заданном фоне
  Color withBackground(Color backgroundColor) {
    if (a == 1.0) return this;

    // Смешиваем цвет с фоном с учетом альфа-канала
    final alpha = a;
    final invAlpha = 1.0 - alpha;

    return Color.from(
      alpha: 1.0,
      red: r * alpha + backgroundColor.r * invAlpha,
      green: g * alpha + backgroundColor.g * invAlpha,
      blue: b * alpha + backgroundColor.b * invAlpha,
    );
  }

  /// Возвращает контрастный цвет (черный или белый) для лучшей читаемости
  Color getContrastingColor() {
    // Вычисляем относительную яркость цвета по формуле W3C
    final double luminance = _getLuminance();

    // Если яркость больше 0.5, возвращаем черный, иначе белый
    return luminance > 0.5 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }

  /// Возвращает адаптивный цвет из заданной пары
  Color getAdaptiveColor({
    Color lightColor = const Color(
      0xFF000000,
    ), // По умолчанию черный для светлого фона
    Color darkColor = const Color(
      0xFFFFFFFF,
    ), // По умолчанию белый для темного фона
  }) {
    final double luminance = _getLuminance();
    return luminance > 0.5 ? lightColor : darkColor;
  }

  /// Вычисляет относительную яркость цвета по стандарту W3C
  double _getLuminance() {
    // Нормализуем значения RGB к диапазону 0-1
    double r = this.r;
    double g = this.g;
    double b = this.b;

    // Применяем гамма-коррекцию
    r = _gammaCorrect(r);
    g = _gammaCorrect(g);
    b = _gammaCorrect(b);

    // Вычисляем относительную яркость
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Применяет гамма-коррекцию к значению цвета
  double _gammaCorrect(double value) {
    if (value <= 0.03928) {
      return value / 12.92;
    } else {
      return pow((value + 0.055) / 1.055, 2.4).toDouble();
    }
  }

  /// Проверяет, является ли цвет темным
  bool get isDark => _getLuminance() < 0.5;

  /// Проверяет, является ли цвет светлым
  bool get isLight => _getLuminance() >= 0.5;
}

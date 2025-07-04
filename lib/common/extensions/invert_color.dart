import 'dart:ui';

extension InvertColor on Color {
  Color invertColor() => Color.fromARGB(
    (a * 255.0).round() & 0xff,
    255 - (r * 255.0).round() & 0xff,
    255 - (g * 255.0).round() & 0xff,
    255 - (b * 255.0).round() & 0xff,
  );
}

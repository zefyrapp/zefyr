import 'package:flutter/material.dart';
import 'package:zifyr/common/themes/app_overlay.dart';
import 'package:zifyr/common/themes/custom_colors.dart';

class AppTheme {
  const AppTheme();

  static final darkTheme = ThemeData(useMaterial3: true).copyWith(
    extensions: <ThemeExtension<CustomColors>>{
      CustomColors(
        overlayApp: const OverlayApp(
          black: Colors.black,
          white: Colors.white,
          activeIcon: Color(0xff9972F4),
          inactiveIcon: Color(0xff9CA3AF),
          iconGradient: [Color(0xffDB2777), Color(0xff7C3AED)],
          indicatorColor: Color(0xff8B5CF6),
          badgeColor: Color(0xffDB2777),
        ),
      ),
    },
  );
}

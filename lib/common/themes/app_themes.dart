import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zefyr/common/themes/app_overlay.dart';
import 'package:zefyr/common/themes/custom_colors.dart';

class AppTheme {
  const AppTheme();

  static final darkTheme = ThemeData(useMaterial3: true).copyWith(
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    extensions: <ThemeExtension<CustomColors>>{
      CustomColors(
        overlayApp: OverlayApp(
          black: Colors.black,
          white: Colors.white,
          activeIcon: const Color(0xff9972F4),
          inactiveIcon: const Color(0xff9CA3AF),
          iconGradient: const [Color(0xffDB2777), Color(0xff7C3AED)],
          indicatorColor: const Color(0xff8B5CF6),
          badgeColor: const Color(0xffDB2777),
          backgroundColor: const Color(0xff111827),

          textFieldBackgroundColor: const Color(0xff1F2937),
          textFieldBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Color(0xff374151)),
          ),
          hintTextStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            height: 24 / 16,

            color: Color(0xffADAEBC),
          ),
          elevatedStyle: ButtonStyle(
            backgroundColor: const WidgetStatePropertyAll(Color(0xff9972F4)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                height: 1,
                color: Colors.white,
              ),
            ),
          ),
          elevatedTextStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 18,
            height: 1,
            color: Colors.white,
          ),
        ),
      ),
    },
  );
}

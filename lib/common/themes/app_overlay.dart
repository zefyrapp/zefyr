import 'package:flutter/material.dart';

class OverlayApp {
  const OverlayApp({
    required this.black,
    required this.white,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.iconGradient,
    required this.indicatorColor,
    required this.badgeColor,
    required this.backgroundColor,
    required this.textFieldBorder,
    required this.textFieldBackgroundColor,
    required this.hintTextStyle,
  });

  final Color black;
  final Color white;
  final Color activeIcon;
  final Color inactiveIcon;
  final List<Color> iconGradient;
  final Color indicatorColor;
  final Color badgeColor;
  final Color backgroundColor;
  final OutlineInputBorder textFieldBorder;
  final Color textFieldBackgroundColor;
  final TextStyle hintTextStyle;
  OverlayApp copyWith({
    Color? black,
    Color? white,
    Color? activeIcon,
    Color? inactiveIcon,
    List<Color>? iconGradient,
    Color? indicatorColor,
    Color? badgeColor,
    Color? backgroundColor,
    OutlineInputBorder? textFieldBorder,
    Color? textFieldBackgroundColor,
    TextStyle? hintTextStyle,
  }) => OverlayApp(
    black: black ?? this.black,
    white: white ?? this.white,
    activeIcon: activeIcon ?? this.activeIcon,
    inactiveIcon: inactiveIcon ?? this.inactiveIcon,
    iconGradient: iconGradient ?? this.iconGradient,
    indicatorColor: indicatorColor ?? this.indicatorColor,
    badgeColor: badgeColor ?? this.badgeColor,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    textFieldBorder: textFieldBorder ?? this.textFieldBorder,
    textFieldBackgroundColor:
        textFieldBackgroundColor ?? this.textFieldBackgroundColor,
    hintTextStyle: hintTextStyle ?? this.hintTextStyle,
  );
}

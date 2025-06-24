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
  });

  final Color black;
  final Color white;
  final Color activeIcon;
  final Color inactiveIcon;
  final List<Color> iconGradient;
  final Color indicatorColor;
  final Color badgeColor;

  OverlayApp copyWith({
    Color? black,
    Color? white,
    Color? activeIcon,
    Color? inactiveIcon,
    List<Color>? iconGradient,
    Color? indicatorColor,
    Color? badgeColor,
  }) => OverlayApp(
    black: black ?? this.black,
    white: white ?? this.white,
    activeIcon: activeIcon ?? this.activeIcon,
    inactiveIcon: inactiveIcon ?? this.inactiveIcon,
    iconGradient: iconGradient ?? this.iconGradient,
    indicatorColor: indicatorColor ?? this.indicatorColor,
    badgeColor: badgeColor ?? this.badgeColor,
  );
}

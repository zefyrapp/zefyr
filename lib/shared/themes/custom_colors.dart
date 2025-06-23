import 'package:flutter/material.dart';

import 'package:zifyr/shared/themes/app_overlay.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  CustomColors({required this.overlayApp});
  OverlayApp overlayApp;
  @override
  ThemeExtension<CustomColors> lerp(
    covariant ThemeExtension<CustomColors>? other,
    double t,
  ) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(overlayApp: overlayApp);
  }

  @override
  CustomColors copyWith({OverlayApp? overlayApp}) =>
      CustomColors(overlayApp: overlayApp ?? this.overlayApp);
}

import 'package:flutter/material.dart';
import 'package:zifyr/shared/themes/custom_colors.dart';

extension ThemeExtension on BuildContext {
  CustomColors get customTheme => Theme.of(this).extension<CustomColors>()!;
  ThemeData get theme => Theme.of(this);
}

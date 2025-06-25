import 'package:flutter/material.dart';
import 'package:zifyr/common/extensions/localization.dart';

enum AuthSignEnum {
  email,
  google,
  apple;

  Object get icon => switch (this) {
    email => Icons.email,
    google => 'assets/icons/google.svg',
    apple => Icons.apple,
  };

  String title(BuildContext context) {
    final local = context.localization;
    return switch (this) {
      email => local.continueWithEmail,
      google => local.continueWithGoogle,
      apple => local.continueWithApple,
    };
  }
}

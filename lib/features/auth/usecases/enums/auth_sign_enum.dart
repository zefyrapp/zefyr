import 'package:flutter/material.dart';
import 'package:zifyr/common/extensions/localization.dart';
import 'package:zifyr/features/auth/presentation/view_model/auth_flow_state.dart';
import 'package:zifyr/features/auth/presentation/view_model/auth_flow_view_model.dart';

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

  void onTap(AuthFlowViewModel authFlowViewModel) => switch (this) {
    email => authFlowViewModel.setFlowType(AuthFlowType.register),
    google => () {},
    apple => () {},
  };
}

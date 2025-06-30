import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyr/common/extensions/context_theme.dart';
import 'package:zefyr/features/auth/presentation/view/auth_view.dart';
import 'package:zefyr/features/auth/presentation/view/birth_date_view.dart';
import 'package:zefyr/features/auth/presentation/view/email_input_view.dart';
import 'package:zefyr/features/auth/presentation/view/email_login_view.dart';
import 'package:zefyr/features/auth/presentation/view/nickname_view.dart';
import 'package:zefyr/features/auth/presentation/view/password_input_view.dart';
import 'package:zefyr/features/auth/presentation/view_model/auth_flow_view_model.dart';

class AuthFlowView extends ConsumerWidget {
  const AuthFlowView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authFlowViewModel = ref.watch(authFlowViewModelProvider.notifier);
    final color = context.customTheme.overlayApp;
    return Scaffold(
      backgroundColor: color.backgroundColor,
      body: SafeArea(
        child: PageView(
          controller: authFlowViewModel.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            // Страница 0: Выбор типа авторизации
            AuthView(),

            // Страница 1: Ввод email
            EmailInputView(),

            // Страница 2: Выбор даты рождения (только для регистрации)
            BirthDateView(),

            // Страница 3: Ввод никнейма (только для регистрации)
            NicknameView(),

            /// Login
            // Страница 4: Ввод почты
            EmailLogin(),
            // Страница 5: Ввод пароля
            PasswordInputView(),
          ],
        ),
      ),
    );
  }
}

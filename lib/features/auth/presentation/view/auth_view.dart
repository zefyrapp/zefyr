import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zifyr/common/extensions/context_theme.dart';
import 'package:zifyr/common/extensions/localization.dart';
import 'package:zifyr/features/auth/usecases/enums/auth_sign_enum.dart';
import 'package:zifyr/features/auth/usecases/privacy_text.dart';

class AuthFlowView extends ConsumerWidget {
  const AuthFlowView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authFlowState = ref.watch(authFlowProvider);
    final authFlowViewModel = ref.read(authFlowProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: authFlowViewModel.pageController,
          physics: const NeverScrollableScrollPhysics(), // Отключаем свайп
          children: [
            // Страница 0: Выбор типа авторизации
            _InitialChoicePage(),

            // Страница 1: Ввод email
            _EmailInputPage(),

            // Страница 2: Ввод пароля
            _PasswordInputPage(),

            // Страница 3: Выбор даты рождения (только для регистрации)
            _BirthDatePage(),

            // Страница 4: Ввод никнейма (только для регистрации)
            _NicknamePage(),
          ],
        ),
      ),
    );
  }
}

class AuthView extends StatelessWidget {
  /// Страница авторизации
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.customTheme.overlayApp;
    final local = context.localization;
    return Scaffold(
      backgroundColor: color.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 194),
              Text(
                local.registerWithZefyr,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 30,
                  height: 38 / 30,
                  color: color.white,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: AuthSignEnum.values
                      .mapIndexed(
                        (i, el) => Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                          color: const Color(0xff374151),
                          clipBehavior: Clip.hardEdge,
                          child: ListTile(
                            onTap: () {},
                            leading: i == 1
                                ? SvgPicture.asset(
                                    el.icon as String,
                                    color: color.white,
                                    width: 16,
                                    height: 16,
                                  )
                                : Icon(
                                    el.icon as IconData,
                                    color: color.white,
                                    size: 16,
                                  ),
                            title: Text(
                              el.title(context),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                height: 1,
                                color: color.white,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const Spacer(),
              PrivacyText.buildStyledTermsText(context),

              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: local.alreadyHaveAccount,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 24 / 16,
                        color: Color(0xffc5c5c5),
                      ),
                    ),
                    TextSpan(
                      text: local.signIn,
                      recognizer: TapGestureRecognizer()..onTap = () {},
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 24 / 16,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

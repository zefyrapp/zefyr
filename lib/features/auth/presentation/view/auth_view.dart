import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zifyr/common/extensions/context_theme.dart';
import 'package:zifyr/common/extensions/localization.dart';
import 'package:collection/collection.dart';

class AuthView extends StatelessWidget {
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
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 14 / 12,
                    color: Color(0xffc5c5c5),
                  ),
                  children: [
                    const TextSpan(
                      text: 'Продолжая пользоваться аккаунтом, относящимся ',
                    ),
                    const TextSpan(
                      text: 'Условия использования ',
                      style: TextStyle(
                        color: Color(0xffffffff),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: 'к региону '),
                    const TextSpan(
                      text: 'Казахстан',
                      style: TextStyle(color: Color(0xffffffff)),
                    ),
                    const TextSpan(
                      text:
                          ', вы принимаете и подтверждаете, что ознакомились с документом « ',
                    ),
                    TextSpan(
                      text: 'Политику конфиденциальности',
                      recognizer: TapGestureRecognizer()..onTap = () {},
                      style: const TextStyle(
                        color: Color(0xffffffff),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: '».'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Уже есть аккаунт? ',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 24 / 16,
                        color: Color(0xffc5c5c5),
                      ),
                    ),
                    TextSpan(
                      text: 'Войти',
                      style: TextStyle(
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

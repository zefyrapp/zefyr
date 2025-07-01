import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zefyr/common/extensions/context_theme.dart';
import 'package:zefyr/common/extensions/localization.dart';
import 'package:zefyr/features/auth/presentation/view_model/auth_flow_state.dart';
import 'package:zefyr/features/auth/presentation/view_model/auth_flow_view_model.dart';
import 'package:zefyr/features/auth/usecases/enums/auth_sign_enum.dart';
import 'package:collection/collection.dart';
import 'package:zefyr/features/auth/usecases/privacy_text.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                child: Consumer(
                  builder: (context, ref, _) => Column(
                    children: AuthSignEnum.values
                        .mapIndexed(
                          (i, el) => Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(8),
                            ),
                            color: const Color(0xff374151),
                            clipBehavior: Clip.hardEdge,
                            child: ListTile(
                              onTap: () => el.onTap(
                                ref.read(authFlowViewModelProvider.notifier),
                                ref,
                              ),
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
              ),
              const Spacer(),
              PrivacyText.buildStyledTermsText(context),

              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, _) => Text.rich(
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
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => ref
                              .read(authFlowViewModelProvider.notifier)
                              .setFlowType(AuthFlowType.login),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

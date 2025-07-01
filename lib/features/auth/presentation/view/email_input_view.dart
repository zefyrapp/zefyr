import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyr/common/extensions/context_theme.dart';
import 'package:zefyr/common/extensions/localization.dart';
import 'package:zefyr/core/utils/icons/app_icons_icons.dart';
import 'package:zefyr/features/auth/presentation/view/widgets/app_text_field.dart';
import 'package:zefyr/features/auth/presentation/view_model/auth_flow_view_model.dart';

class EmailInputView extends ConsumerStatefulWidget {
  const EmailInputView({super.key});
  @override
  ConsumerState<EmailInputView> createState() => _EmailInputPageState();
}

class _EmailInputPageState extends ConsumerState<EmailInputView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _appendEmailDomain(String domain) {
    final currentText = _emailController.text;
    final atIndex = currentText.indexOf('@');

    String newText;
    if (atIndex != -1) {
      // Если @ уже есть, заменяем домен
      newText = currentText.substring(0, atIndex) + domain;
    } else {
      // Если @ нет, добавляем домен
      newText = currentText + domain;
    }

    _emailController.text = newText;
    _emailController.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authFlowState = ref.watch(authFlowViewModelProvider);
    final authFlowViewModel = ref.read(authFlowViewModelProvider.notifier);
    final color = context.customTheme.overlayApp;
    final local = context.localization;
    return Scaffold(
      backgroundColor: color.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: color.backgroundColor,
        leading: IconButton(
          icon: const Icon(AppIcons.left_shefron, size: 20),
          onPressed: authFlowViewModel.previousStep,
          color: color.white,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  local.emailPasswordPrompt,
                  style: TextStyle(
                    fontSize: 22,
                    height: 32 / 22,
                    fontWeight: FontWeight.w700,
                    color: color.white,
                  ),
                ),

                const SizedBox(height: 32),

                AppTextField.email(
                  controller: _emailController,
                  hintText: local.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return local.enterEmail;
                    }
                    if (!EmailValidator.validate(value)) {
                      return local.enterValidEmail;
                    }
                    return null;
                  },
                  onChanged: (value) {},
                ),
                const SizedBox(height: 22),
                AppTextField.password(
                  controller: _passwordController,
                  hintText: local.enterPassword,

                  onChanged: (value) {},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return local.enterPassword;
                    }
                    if (value.length < 8 || value.length > 20) {
                      return local.passwordLengthError;
                    }

                    final hasLetter = RegExp('[A-Za-z]').hasMatch(value);
                    final hasDigit = RegExp(r'\d').hasMatch(value);
                    final hasSpecial = RegExp(
                      r'[!@#\$%^&*(),.?":{}|<>_\-+=\\/\[\]]',
                    ).hasMatch(value);

                    if (!hasLetter || !hasDigit || !hasSpecial) {
                      return local.passwordShouldContainAll;
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 32),
                _DotText(text: local.passwordLength),
                _DotText(text: local.passwordRequirements),
                _DotText(text: local.strongPassword),
                if (authFlowState.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    authFlowState.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: authFlowState.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              authFlowViewModel.updateFormData(
                                authFlowState.formData.copyWith(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                ),
                              );
                              authFlowViewModel.nextStep();
                            }
                          },
                    style: color.elevatedStyle,
                    child: authFlowState.isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            local.continueButton,
                            style: color.elevatedTextStyle,
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Кнопки с доменами почт
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 8,
                    children: [
                      _EmailDomainButton(
                        domain: '@gmail.com',
                        onTap: () => _appendEmailDomain('@gmail.com'),
                      ),
                      _EmailDomainButton(
                        domain: '@hotmail.com',
                        onTap: () => _appendEmailDomain('@hotmail.com'),
                      ),
                      _EmailDomainButton(
                        domain: '@yahoo.com',
                        onTap: () => _appendEmailDomain('@yahoo.com'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailDomainButton extends StatelessWidget {
  const _EmailDomainButton({required this.domain, required this.onTap});
  final String domain;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    child: Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xff1F2937),
        border: Border.all(color: const Color(0xff374151)),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Center(
        child: Text(
          domain,
          style: const TextStyle(
            color: Color(0xffD1D5DB),
            fontSize: 14,
            height: 1,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

class _DotText extends StatelessWidget {
  const _DotText({required this.text, super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Text(
        '•',
        style: TextStyle(fontSize: 18, color: Color(0xff6B7280), height: 1.55),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 13,
            height: 20 / 13,
            color: Color(0xff9CA3AF),
          ),
        ),
      ),
    ],
  );
}

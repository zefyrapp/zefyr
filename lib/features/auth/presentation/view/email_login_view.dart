import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyr/common/extensions/context_theme.dart';
import 'package:zefyr/common/extensions/localization.dart';
import 'package:zefyr/core/utils/icons/app_icons_icons.dart';
import 'package:zefyr/features/auth/presentation/view/widgets/app_text_field.dart';
import 'package:zefyr/features/auth/presentation/view_model/auth_flow_view_model.dart';

class EmailLogin extends ConsumerStatefulWidget {
  const EmailLogin({super.key});

  @override
  ConsumerState<EmailLogin> createState() => _EmailLoginState();
}

class _EmailLoginState extends ConsumerState<EmailLogin> {
  late final TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final authFlowState = ref.watch(authFlowViewModelProvider);
    final authFlowViewModel = ref.read(authFlowViewModelProvider.notifier);
    final color = context.customTheme.overlayApp;
    final local = context.localization;
    return Scaffold(
      backgroundColor: color.backgroundColor,
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
                  local.emailUsernameLabel,
                  style: TextStyle(
                    fontSize: 18,
                    height: 32 / 22,
                    fontWeight: FontWeight.w700,
                    color: color.white,
                  ),
                ),
                const SizedBox(height: 32),

                AppTextField.email(
                  controller: _emailController,
                  hintText: local.emailUsername,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return local.enterEmailUsername;
                    }
                    if (!EmailValidator.validate(value)) {
                      return local.enterValidEmail;
                    }
                    return null;
                  },
                  onChanged: (value) {},
                ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

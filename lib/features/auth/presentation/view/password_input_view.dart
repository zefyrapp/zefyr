// Страница ввода пароля
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyr/common/extensions/context_theme.dart';
import 'package:zefyr/common/extensions/localization.dart';
import 'package:zefyr/core/utils/icons/app_icons_icons.dart';
import 'package:zefyr/features/auth/presentation/view/widgets/app_text_field.dart';
import 'package:zefyr/features/auth/presentation/view_model/auth_flow_view_model.dart';

class PasswordInputView extends ConsumerStatefulWidget {
  const PasswordInputView({super.key});
  @override
  ConsumerState<PasswordInputView> createState() => _PasswordInputPageState();
}

class _PasswordInputPageState extends ConsumerState<PasswordInputView> {
  late final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
          icon: const Icon(AppIcons.leftShefron, size: 20),
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
                  local.enterPassword,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color.white,
                  ),
                ),

                const SizedBox(height: 32),

                AppTextField.password(
                  controller: _passwordController,
                  hintText: local.password,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return local.enterPassword;
                    }

                    return null;
                  },
                ),

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
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authFlowState.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              authFlowViewModel.updateFormData(
                                authFlowState.formData.copyWith(
                                  password: _passwordController.text,
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

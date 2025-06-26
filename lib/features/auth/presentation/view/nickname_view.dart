import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifyr/common/extensions/context_theme.dart';
import 'package:zifyr/common/extensions/localization.dart';
import 'package:zifyr/features/auth/presentation/view/widgets/app_text_field.dart';
import 'package:zifyr/features/auth/presentation/view_model/auth_flow_view_model.dart';

class NicknameView extends ConsumerStatefulWidget {
  const NicknameView({super.key});

  @override
  ConsumerState<NicknameView> createState() => _NicknamePageState();
}

class _NicknamePageState extends ConsumerState<NicknameView> {
  late final TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authFlowState = ref.watch(authFlowViewModelProvider);
    final authFlowViewModel = ref.read(authFlowViewModelProvider.notifier);
    final color = context.customTheme.overlayApp;
    final local = context.localization;
    return Scaffold(
      backgroundColor: color.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: authFlowViewModel.skipNickname,
                child: Text(
                  local.skip,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 1,
                    color: color.inactiveIcon,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                local.createNickname,
                style: TextStyle(
                  fontSize: 22,
                  height: 32 / 22,
                  fontWeight: FontWeight.w700,
                  color: color.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                local.nicknameDescription,
                style: TextStyle(
                  fontSize: 14,
                  height: 1,
                  fontWeight: FontWeight.w400,
                  color: color.inactiveIcon,
                ),
              ),
              const SizedBox(height: 24),
              AppTextField.nickname(hintText: local.enterNickname),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: authFlowViewModel.skipNickname,
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
    );
  }
}

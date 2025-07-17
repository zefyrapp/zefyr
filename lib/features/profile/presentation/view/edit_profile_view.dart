import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:zefyr/common/extensions/context_theme.dart';
import 'package:zefyr/common/extensions/localization.dart';
import 'package:zefyr/common/widgets/animated_error_message.dart';
import 'package:zefyr/features/profile/domain/entities/profile_entity.dart';
import 'package:zefyr/features/profile/presentation/view_model/edit_profile_view_model.dart';

class EditProfileView extends ConsumerStatefulWidget {
  const EditProfileView({required this.profile, super.key});
  final ProfileEntity profile;
  @override
  ConsumerState<EditProfileView> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  late final EditProfileViewModel viewModel;
  @override
  void initState() {
    super.initState();
    viewModel = ref.read(editProfileViewModelProvider(widget.profile).notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(editProfileViewModelProvider(widget.profile));

      _nameController.text = state.name ?? '';
      _nicknameController.text = state.nickname ?? '';
      _bioController.text = state.bio ?? '';
    });

    // Слушаем изменения в полях и обновляем ViewModel
    _nameController.addListener(() {
      viewModel.updateName(_nameController.text);
    });

    _nicknameController.addListener(() {
      viewModel.updateNickname(_nicknameController.text);
    });

    _bioController.addListener(() {
      viewModel.updateBio(_bioController.text);
    });
  }

  Future<void> _saveProfile() async {
    final success = await viewModel.saveProfile();

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.customTheme.overlayApp;
    final local = context.localization;
    final viewModel = ref.read(
      editProfileViewModelProvider(widget.profile).notifier,
    );
    final state = ref.watch(editProfileViewModelProvider(widget.profile));
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Редактировать профиль',
          style: TextStyle(
            color: Color(0xffE0E0E0),
            fontSize: 17,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            height: 28 / 20,
          ),
        ),
        centerTitle: false,
        bottom: const PreferredSize(
          preferredSize: Size(double.infinity, 1),
          child: Divider(color: Color(0xff2A2A2A)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Аватар
                      const SizedBox(height: 20),
                      Stack(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: ClipOval(
                              child: state.avatar != null
                                  ? Image.file(File(state.avatar!))
                                  : CachedNetworkImage(
                                      imageUrl:
                                          state.avatar ?? state.avatarUrl ?? '',

                                      errorWidget: (context, url, error) =>
                                          Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey[800],
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Кнопка изменить фото
                      TextButton(
                        onPressed: viewModel.selectPick,
                        child: const Text(
                          'Изменить фото',
                          style: TextStyle(
                            color: Color(0xFF9972F4),
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Поле имени
                      _buildTextField(
                        label: 'Имя',
                        controller: _nameController,
                      ),

                      // Поле никнейма
                      _buildTextField(
                        label: 'Никнейм',
                        controller: _nicknameController,
                      ),

                      // Поле "О себе"
                      _buildTextField(
                        label: 'О себе',
                        controller: _bioController,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),
                      if (state.errorMessage != null)
                        AnimatedErrorMessage(
                          message: state.errorMessage!,
                          show: state.errorMessage != null,
                          autoHideDuration: const Duration(seconds: 3),
                          onHide: viewModel.clearError,
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Кнопка сохранить
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  onPressed: viewModel.hasChanges && !state.isLoading
                      ? _saveProfile
                      : null,
                  style: color.elevatedStyle,
                  child: state.isLoading
                      ? const CircularProgressIndicator()
                      : Text(local.save, style: color.elevatedTextStyle),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) => CustomProfileField(
    label: label,
    controller: controller,
    maxLines: maxLines,
  );
}

class CustomProfileField extends StatelessWidget {
  const CustomProfileField({
    required this.label,
    super.key,
    this.controller,
    this.hintText,
    this.maxLines = 1,
    this.showDivider = true,
    this.onTap,
    this.readOnly = false,
    this.keyboardType,
    this.onChanged,
  });
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final int maxLines;
  final bool showDivider;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 57),
    child: Column(
      children: [
        Row(
          children: [
            // Лейбл
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFE0E0E0),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                  height: 1,
                ),
              ),
            ),

            // Поле ввода
            Expanded(
              child: TextFormField(
                controller: controller,
                maxLines: maxLines,
                readOnly: readOnly,
                keyboardType: keyboardType,
                onTap: onTap,
                onChanged: onChanged,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                  height: 20 / 18,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 17,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),

        // Разделитель
        if (showDivider)
          const Divider(color: Color(0xFF3A3A3C), thickness: 0.5, height: 0.5),
      ],
    ),
  );
}

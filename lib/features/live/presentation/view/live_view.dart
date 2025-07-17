import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:zefyr/common/extensions/context_theme.dart';
import 'package:zefyr/common/extensions/localization.dart';
import 'package:zefyr/features/auth/presentation/view/widgets/app_text_field.dart';
import 'package:zefyr/features/live/providers/stream_providers.dart';

class LiveView extends ConsumerStatefulWidget {
  const LiveView({super.key});

  @override
  ConsumerState<LiveView> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends ConsumerState<LiveView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _previewUrlController = TextEditingController();
  final _titleNode = FocusNode();
  final _descriptionNode = FocusNode();
  final _previewUrlNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Заполняем поля текущими значениями из стейта
    _loadCurrentValues();
  }

  void _loadCurrentValues() {
    final formState = ref.read(streamFormProvider);
    _titleController.text = formState.title;
    _descriptionController.text = formState.description;
    _previewUrlController.text = formState.previewUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _previewUrlController.dispose();
    _titleNode.dispose();
    _descriptionNode.dispose();
    _previewUrlNode.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      // Обновляем стейт с новыми значениями
      ref
          .read(streamFormProvider.notifier)
          .updateAll(
            title: _titleController.text,
            description: _descriptionController.text,
            previewUrl: _previewUrlController.text,
          );

      // Показываем уведомление об успешном сохранении
      _showSuccessToast();

      // Возвращаемся к экрану OnAir
      context.pop();
    }
  }

  void _showSuccessToast() {
    Toastification().show(
      title: const Text(
        'Настройки сохранены',
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 20 / 12,
          color: Colors.white,
        ),
      ),
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      primaryColor: Colors.green,
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  void _showErrorToast(String message) {
    Toastification().show(
      title: Text(
        message,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 20 / 12,
          color: Colors.white,
        ),
      ),
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      primaryColor: const Color(0x9E5B687B),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.customTheme.overlayApp;
    final local = context.localization;
    final formState = ref.watch(streamFormProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          local.streamSetup,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Заголовок стрима
              Text(
                local.streamTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _titleController,
                focusNode: _titleNode,
                hintText: local.enterStreamTitle,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return local.enterStreamTitleError;
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _descriptionNode.requestFocus(),
              ),

              const SizedBox(height: 24),

              // Описание стрима
              Text(
                local.streamDescription,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _descriptionController,
                focusNode: _descriptionNode,
                hintText: local.enterStreamDescription,
                maxLines: 3,
                onFieldSubmitted: (_) => _previewUrlNode.requestFocus(),
              ),

              const SizedBox(height: 24),

              // URL превью
              Text(
                local.streamPreviewUrl,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _previewUrlController,
                focusNode: _previewUrlNode,
                hintText: 'https://example.com/preview.jpg',
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final uri = Uri.tryParse(value);
                    if (uri == null || !uri.hasScheme) {
                      return 'Введите корректный URL';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Информация о текущем состоянии формы
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Статус настройки стрима:',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          formState.canCreateStream
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: formState.canCreateStream
                              ? Colors.green
                              : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formState.canCreateStream
                              ? 'Готов к созданию стрима'
                              : 'Требуется заполнить название',
                          style: TextStyle(
                            color: formState.canCreateStream
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Кнопка "Сохранить"
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: theme.elevatedStyle,
                  child: Text(local.save, style: theme.elevatedTextStyle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

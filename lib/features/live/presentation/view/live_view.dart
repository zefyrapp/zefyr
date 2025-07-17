import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:zefyr/common/extensions/context_theme.dart';
import 'package:zefyr/common/extensions/localization.dart';
import 'package:zefyr/features/auth/presentation/view/widgets/app_text_field.dart';
import 'package:zefyr/features/live/data/models/stream_create_response.dart';
import 'package:zefyr/features/live/presentation/view_model/stream_view_state.dart';
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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _previewUrlController.dispose();
    _titleNode.dispose();
    _descriptionNode.dispose();
    _previewUrlNode.dispose();
    super.dispose();
  }

  Future<void> _createStream() async {
    // Обновляем состояние формы с текущими значениями
    ref
        .read(streamFormProvider.notifier)
        .updateAll(
          title: _titleController.text,
          description: _descriptionController.text,
          previewUrl: _previewUrlController.text,
        );

    final formState = ref.read(streamFormProvider);

    if (_formKey.currentState!.validate() && formState.canCreateStream) {
      final request = formState.toRequest();
      await ref.read(streamViewModelProvider.notifier).createNewStream(request);
    }
  }

  void _navigateToStreamScreen() {
    context.push('/onAir');
  }

  void _showErrorDialog(String message) {
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
    final streamState = ref.watch(streamViewModelProvider);
    final formState = ref.watch(streamFormProvider);
    // Слушаем изменения стейта для навигации и показа ошибок
    ref.listen<StreamViewState>(streamViewModelProvider, (previous, next) {
      if (next is StreamStateSuccess) {
        // Сбрасываем форму после успешного создания стрима
        ref.read(streamFormProvider.notifier).reset();
        _navigateToStreamScreen();
      } else if (next is StreamStateError) {
        _showErrorDialog(next.message);
      }
    });
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
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
              ),

              const Spacer(),

              // Кнопка "Войти в стрим"
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: streamState.isLoading ? null : _createStream,
                  style: theme.elevatedStyle,
                  child: streamState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(local.startStream, style: theme.elevatedTextStyle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

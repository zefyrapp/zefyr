
import 'package:flutter/material.dart';
import 'package:zefyr/common/extensions/context_theme.dart';
import 'package:zefyr/common/extensions/localization.dart';
import 'package:zefyr/features/auth/presentation/view/widgets/app_text_field.dart';

class StreamData {
  StreamData({
    required this.title,
    required this.description,
    required this.previewUrl,
  });
  String title;
  String description;
  String previewUrl;
}

class LiveView extends StatefulWidget {
  const LiveView({super.key});

  @override
  State<LiveView> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends State<LiveView> {
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

  void _goToStreamScreen() {
    if (_formKey.currentState!.validate()) {
      final streamData = StreamData(
        title: _titleController.text,
        description: _descriptionController.text,
        previewUrl: _previewUrlController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StreamScreen(streamData: streamData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.customTheme.overlayApp;
    final local = context.localization;
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
                  onPressed:
                      // authFlowState.isLoading
                      //     ? null
                      //     :
                      _goToStreamScreen,
                  style: theme.elevatedStyle,
                  child:
                      //  authFlowState.isLoading
                      //     ? const CircularProgressIndicator()
                      //     :
                      Text(local.startStream, style: theme.elevatedTextStyle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StreamScreen extends StatelessWidget {
  const StreamScreen({required this.streamData, super.key});
  final StreamData streamData;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // Основной контент стрима (здесь будет камера)
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: const Center(
            child: Icon(Icons.videocam, size: 100, color: Colors.grey),
          ),
        ),

        // Верхняя панель с информацией о стриме
        SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        streamData.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (streamData.description.isNotEmpty)
                        Text(
                          streamData.description,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Статус LIVE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Нижняя панель с кнопкой "Выйти в эфир"
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Статистика стрима
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(Icons.visibility, '2.5K'),
                    _buildStatItem(Icons.favorite, '100'),
                    _buildStatItem(Icons.chat, '45'),
                  ],
                ),

                const SizedBox(height: 16),

                // Кнопка "Выйти в эфир"
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showEndStreamDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Выйти в эфир',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
      ],
    ),
  );

  Widget _buildStatItem(IconData icon, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.6),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  void _showEndStreamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Завершить стрим?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Вы уверены, что хотите завершить стрим?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Завершить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

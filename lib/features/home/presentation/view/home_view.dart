import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zefyr/common/extensions/context_theme.dart';
import 'package:zefyr/common/widgets/gradient_border_image.dart';
import 'package:zefyr/features/auth/providers/auth_providers.dart';
import 'package:zefyr/features/home/presentation/view/streaming/streaming_list_view.dart';
import 'package:zefyr/features/home/presentation/view/widgets/stream_category_chips.dart';
import 'package:zefyr/features/home/presentation/widgets/money_chip.dart';

class HomeView extends StatelessWidget {
  /// Главный экран
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.customTheme.overlayApp;
    return Scaffold(
      backgroundColor: color.black,
      body: CustomScrollView(
        slivers: [
          // Анимированный заголовок
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,

            snap: true,
            backgroundColor: color.black,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: const FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Секция с аватаром и монетами
                  AvatarHomeSection(),
                  // Секция с категориями
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: StreamCategoryChips(),
                  ),
                ],
              ),
            ),
          ),
          // Основной контент
          const StreamingListView(),
        ],
      ),
    );
  }
}

class AvatarHomeSection extends ConsumerWidget {
  const AvatarHomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final color = context.customTheme.overlayApp;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: user != null ? 13 : 8,
      ),
      child: user != null
          ? Row(
              spacing: 9,
              children: [
                GradientBorderImage(
                  size: 42,
                  onTap: () => context.push('/profile'),
                  //!TODO: аватар пользователя
                  child: const SizedBox.shrink(),
                ),
                MoneyChip(onTap: () {}, coins: '100'),
              ],
            )
          : Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () => context.push('/auth'),
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: BorderSide(color: color.indicatorColor),
                    ),
                  ),
                  minimumSize: const WidgetStatePropertyAll(Size(80, 30)),
                  backgroundColor: const WidgetStatePropertyAll(Colors.black),
                ),
                child: Text(
                  'Войти',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    height: 1,
                    color: color.white,
                  ),
                ),
              ),
            ),
    );
  }
}

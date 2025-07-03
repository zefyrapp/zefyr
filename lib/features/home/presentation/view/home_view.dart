import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zefyr/common/extensions/context_theme.dart';
import 'package:zefyr/common/widgets/gradient_border_image.dart';
import 'package:zefyr/features/home/presentation/view/streaming/streamin_list_view.dart';
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
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Секция с аватаром и монетами
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    child: Row(
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
                    ),
                  ),
                  // Секция с категориями
                  const Padding(
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

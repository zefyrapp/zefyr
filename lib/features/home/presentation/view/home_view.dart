import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zifyr/common/extensions/context_theme.dart';
import 'package:zifyr/common/widgets/gradient_border_image.dart';
import 'package:zifyr/features/home/presentation/widgets/money_chip.dart';

class HomeView extends StatelessWidget {
  /// Главный экран
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.customTheme.overlayApp;
    return Scaffold(
      backgroundColor: color.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
          ],
        ),
      ),
    );
  }
}

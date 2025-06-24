import 'package:flutter/material.dart';
import 'package:zifyr/common/extensions/context_theme.dart';
import 'package:zifyr/core/utils/icons/app_asset_icon.dart';

class MoneyChip extends StatelessWidget {
  /// Чип виджет для отображения текущего количества монет
  const MoneyChip({required this.onTap, required this.coins, super.key});
  final VoidCallback onTap;
  final String coins;
  @override
  Widget build(BuildContext context) {
    final color = context.customTheme.overlayApp;
    return Card(
      color: const Color.fromRGBO(203, 197, 197, 0.21),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(22),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 37,

          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 11),
            child: Row(
              spacing: 5,
              children: [
                Image.asset(AppAssetIcon.money, height: 21, width: 21),
                Text(
                  coins,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 1,
                    color: color.white,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.white,
                  ),
                  child: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

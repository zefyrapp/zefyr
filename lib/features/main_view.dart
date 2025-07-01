import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zefyr/common/extensions/context_theme.dart';
import 'package:zefyr/common/widgets/custom_convex_bottom_bar.dart';
import 'package:zefyr/core/constants/navigation_enum.dart';
import 'package:zefyr/features/auth/data/datasources/user_dao.dart';

class MainView extends StatelessWidget {
  const MainView({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final color = context.customTheme.overlayApp;
    return Scaffold(
      backgroundColor: color.black,
      body: SafeArea(child: navigationShell),
      bottomNavigationBar: CustomConvexBottomBar(
        currentIndex: navigationShell.currentIndex,
        activeColor: color.activeIcon,
        inactiveColor: color.inactiveIcon,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: NavigationEnum.values.mapIndexed((i, nav) {
          if (i == 2) {
            return ConvexBarItem(
              icon: nav.icon,
              label: nav.label,
              isCenter: true,
            );
          }
          if (i == 4) {
            return ConvexBarItem(icon: nav.icon, label: nav.label, badge: '3');
          }
          return ConvexBarItem(icon: nav.icon, label: nav.label);
        }).toList(),
      ),
    );
  }
}

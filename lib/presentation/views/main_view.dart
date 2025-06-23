import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zifyr/core/constants/navigation_enum.dart';

///Основной экран с навигацией
class MainView extends StatelessWidget {
  const MainView({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: navigationShell),
    bottomNavigationBar: BottomNavigationBar(
      backgroundColor: const Color(0xffFFFFFF),
      currentIndex: navigationShell.currentIndex,

      elevation: 0,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      items: NavigationEnum.values
          .map(
            (nav) =>
                BottomNavigationBarItem(icon: Icon(nav.icon), label: nav.label),
          )
          .toList(),
    ),
  );
}

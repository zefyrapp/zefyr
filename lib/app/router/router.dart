import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import "package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart";
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zifyr/core/constants/navigation_enum.dart';
import 'package:zifyr/core/extensions/context_theme.dart';
import 'package:zifyr/core/utils/fade_transition/fade_transition.dart';
import 'package:zifyr/presentation/views/chat/chat_view.dart';
import 'package:zifyr/presentation/views/explore/explore_view.dart';
import 'package:zifyr/presentation/views/home/home_view.dart';
import 'package:zifyr/presentation/views/live/live_view.dart';
import 'package:zifyr/presentation/views/mission/mission_view.dart';
import 'package:zifyr/presentation/views/profile/profile_view.dart';

part 'router.g.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class PersistentStateShell extends StatefulWidget {
  const PersistentStateShell({required this.child, super.key});
  final Widget child;

  @override
  State<PersistentStateShell> createState() => _PersistentStateShellState();
}

class _PersistentStateShellState extends State<PersistentStateShell> {
  final Map<String, Widget> _persistentWidgets = {};

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (!_persistentWidgets.containsKey(location)) {
      _persistentWidgets[location] = widget.child;
    }
    return IndexedStack(
      index: _persistentWidgets.keys.toList().indexOf(location),
      children: _persistentWidgets.values.toList(),
    );
  }
}

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final shellNavigatorKey = GlobalKey<NavigatorState>();

  final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    observers: [MyNavigatorObserver()],
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final color = context.customTheme.overlayApp;
          return PersistentTabView.router(
            backgroundColor: color.black,
            navigationShell: navigationShell,
            tabs: NavigationEnum.values
                .map(
                  (nav) => PersistentRouterTabConfig(
                    item: ItemConfig(
                      icon: Icon(nav.icon, size: 18),
                      activeForegroundColor: color.activeIcon,
                      inactiveForegroundColor: color.inactiveIcon,
                      title: nav.label,
                    ),
                  ),
                )
                .toList(),
            navBarBuilder: (navBarConfig) => Style13BottomNavBar(
              navBarConfig: navBarConfig,
              navBarDecoration: NavBarDecoration(color: color.black),
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: shellNavigatorKey,
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) => FadeTransitionPage(
                  key: state.pageKey,
                  child: const HomeView(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mission',
                pageBuilder: (context, state) => FadeTransitionPage(
                  key: state.pageKey,
                  child: const MissionView(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/live',
                pageBuilder: (context, state) => FadeTransitionPage(
                  key: state.pageKey,
                  child: const LiveView(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                pageBuilder: (context, state) => FadeTransitionPage(
                  key: state.pageKey,
                  child: const ExploreView(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => FadeTransitionPage(
                  key: state.pageKey,
                  child: const ProfileView(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                pageBuilder: (context, state) => FadeTransitionPage(
                  key: state.pageKey,
                  child: const ChatView(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    log('Pushed route: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    log('Popped route: ${route.settings.name}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    log('Removed route: ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    log('Replaced route: ${newRoute?.settings.name}');
  }
}

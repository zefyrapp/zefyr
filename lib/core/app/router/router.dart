import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zifyr/core/services/redirect_service.dart';
import 'package:zifyr/core/utils/fade_transition/fade_transition.dart';
import 'package:zifyr/features/auth/presentation/view/auth_view.dart';
import 'package:zifyr/features/chat/presentation/view/chat_view.dart';
import 'package:zifyr/features/explore/presentation/view/explore_view.dart';
import 'package:zifyr/features/home/presentation/view/home_view.dart';
import 'package:zifyr/features/live/presentation/view/live_view.dart';
import 'package:zifyr/features/main_view.dart';
import 'package:zifyr/features/mission/presentation/view/mission_view.dart';
import 'package:zifyr/features/profile/presentation/view/profile_view.dart';

part 'router.g.dart';

final navigatorKey = GlobalKey<NavigatorState>();

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
        builder: (context, state, navigationShell) =>
            MainView(navigationShell: navigationShell),
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
                redirect: (context, state) =>
                    RedirectService().authRedirect(ref: ref, state: state),
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
                path: '/chat',
                redirect: (context, state) =>
                    RedirectService().authRedirect(ref: ref, state: state),
                pageBuilder: (context, state) => FadeTransitionPage(
                  key: state.pageKey,
                  child: const ChatView(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                redirect: (context, state) =>
                    RedirectService().authRedirect(ref: ref, state: state),
                pageBuilder: (context, state) => FadeTransitionPage(
                  key: state.pageKey,
                  child: const ProfileView(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) =>
            FadeTransitionPage(key: state.pageKey, child: const AuthFlowView()),
        routes: [],
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

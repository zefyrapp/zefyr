import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zefyr/core/services/redirect_service.dart';
import 'package:zefyr/core/utils/fade_transition/fade_transition.dart';
import 'package:zefyr/features/auth/data/models/user_model.dart';
import 'package:zefyr/features/auth/presentation/view/auth_flow_view.dart';
import 'package:zefyr/features/auth/providers/auth_providers.dart';
import 'package:zefyr/features/chat/presentation/view/chat_view.dart';
import 'package:zefyr/features/explore/presentation/view/explore_view.dart';
import 'package:zefyr/features/home/presentation/view/home_view.dart';
import 'package:zefyr/features/live/presentation/view/live_view.dart';
import 'package:zefyr/features/live/presentation/view/on_air/on_air_view.dart';
import 'package:zefyr/features/main_view.dart';
import 'package:zefyr/features/mission/presentation/view/mission_view.dart';
import 'package:zefyr/features/profile/presentation/view/profile_view.dart';

part 'router.g.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AuthNotifier extends ChangeNotifier {
  AuthNotifier(this._stream) {
    _subscription = _stream.listen((_) {
      if (!_disposed) {
        notifyListeners();
      }
    });
  }
  final Stream<dynamic> _stream;
  late final StreamSubscription<dynamic> _subscription;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _subscription.cancel();
    super.dispose();
  }
}

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final shellNavigatorKey = GlobalKey<NavigatorState>();
  final authStateStream = ref.watch(authStateChangesProvider.stream);
  final authNotifier = AuthNotifier(authStateStream);

  ref.onDispose(() {
    authNotifier.dispose();
  });

  final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,

    redirect: (context, state) =>
        RedirectService().authRedirect(ref: ref, state: state),

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
        path: 'onAir',
        pageBuilder: (context, state) =>
            FadeTransitionPage(key: state.pageKey, child: const OnAirView()),
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

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

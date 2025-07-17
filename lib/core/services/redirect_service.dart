import 'package:go_router/go_router.dart';

class RedirectService {
  /// Выполняет редирект в зависимости от статуса аутентификации.
  /// Возвращает маршрут для редиректа или `null`, если редирект не требуется.
  String? authRedirect({required bool isAuth, required GoRouterState state}) {
    const publicRoutes = ['/auth', '/home','/', '/onAir/remoteParticipant'];

    final isLoggedIn = isAuth;

    final location = state.matchedLocation;
    final isGoingToPublicRoute = publicRoutes.contains(location);

    // Если пользователь не залогинен и идет НЕ на публичный роут - редирект на /auth.
    if (!isLoggedIn && !isGoingToPublicRoute) {
      final from = Uri.encodeComponent(state.uri.toString());
      return '/auth?from=$from';
    }

    // Если пользователь залогинен и случайно попал на /auth - редирект домой или откуда пришел.
    if (isLoggedIn && isGoingToPublicRoute) {
      final from = state.uri.queryParameters['from'];
      if (from != null && from != location) return from;

      // не редиректим, если уже на нужной странице
      if (from == null || from == location) return null;

      return from;
    }

    // В остальных случаях редирект не нужен.
    return null;
  }
}

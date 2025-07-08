import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zefyr/features/auth/providers/auth_providers.dart';

class RedirectService {
  /// Выполняет редирект в зависимости от статуса аутентификации.
  /// Возвращает маршрут для редиректа или `null`, если редирект не требуется.
  String? authRedirect({required Ref ref, required GoRouterState state}) {
    const publicRoutes = ['/auth', '/home', '/', '/onAir/remoteParticipant'];
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final isLoggedIn = user != null;

    final location = state.matchedLocation;
    final isGoingToPublicRoute = publicRoutes.contains(location);

    // Если пользователь не залогинен и идет НЕ на публичный роут - редирект на /auth.
    if (!isLoggedIn && !isGoingToPublicRoute) {
      final from = Uri.encodeComponent(state.uri.toString());
      return '/auth?from=$from';
    }

    // Если пользователь залогинен и случайно попал на /auth - редирект домой или откуда пришел.
    if (isLoggedIn && isGoingToPublicRoute) {
      return state.uri.queryParameters['from'] ?? state.fullPath;
    }

    // В остальных случаях редирект не нужен.
    return null;
  }
}

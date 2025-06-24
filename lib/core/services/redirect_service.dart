import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RedirectService {
  //!TODO доделать
  String? authRedirect({
    required Ref ref,
    required GoRouterState state,
    String redirectTo = '/auth',
  }) {
    final isLoggedIn = true; // ref.read(isAuthenticatedProvider);
    final isOnAuthScreen = state.fullPath == redirectTo;

    if (!isLoggedIn && !isOnAuthScreen) return redirectTo;
    if (isLoggedIn && isOnAuthScreen) return '/';

    return null;
  }
}

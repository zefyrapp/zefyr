import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LiveView extends ConsumerWidget {
  const LiveView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Автоматически перенаправляем на экран с камерой
    WidgetsBinding.instance.addPostFrameCallback((_) => context.pushReplacement('/onAir'));

    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator(color: Colors.purple)),
    );
  }
}

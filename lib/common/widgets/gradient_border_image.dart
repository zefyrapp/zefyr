import 'package:flutter/material.dart';

class GradientBorderImage extends StatelessWidget {
  /// Градиентная рамка вокруг аватарок
  const GradientBorderImage({
    required this.child,
    required this.size,
    super.key,
    this.onTap,
  });
  final Widget child;
  final double size;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    shape: const CircleBorder(),
    color: Colors.transparent,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(2.0),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFF618BF), Color(0xFFA3A64D), Color(0xFFD9080C)],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),

          child: ClipOval(child: child),
        ),
      ),
    ),
  );
}

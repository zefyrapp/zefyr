import 'package:flutter/material.dart';

class AnimatedErrorMessage extends StatefulWidget {
  const AnimatedErrorMessage({
    required this.message,
    required this.show,
    super.key,
    this.autoHideDuration = const Duration(seconds: 1),
    this.onHide,
  });
  final String message;
  final bool show;
  final Duration autoHideDuration;
  final VoidCallback? onHide;

  @override
  State<AnimatedErrorMessage> createState() => _AnimatedErrorMessageState();
}

class _AnimatedErrorMessageState extends State<AnimatedErrorMessage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(AnimatedErrorMessage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.show && !oldWidget.show) {
      // Показываем с анимацией
      _animationController.forward();

      // Автоматически скрываем через указанное время
      Future.delayed(widget.autoHideDuration, () {
        if (mounted && widget.show) {
          _hideWithAnimation();
        }
      });
    } else if (!widget.show && oldWidget.show) {
      // Скрываем с анимацией
      _hideWithAnimation();
    }
  }

  void _hideWithAnimation() {
    _animationController.reverse().then((_) {
      if (mounted && widget.onHide != null) {
        widget.onHide!();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(91, 104, 123, 0.62),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: ' Inter',
                        fontWeight: FontWeight.w400,

                        height: 20 / 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

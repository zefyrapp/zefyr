import 'package:flutter/material.dart';
import 'package:zifyr/common/extensions/context_theme.dart';

class ConvexBarItem {
  const ConvexBarItem({
    required this.icon,
    required this.label,
    this.badge,
    this.isCenter = false,
  });
  final IconData icon;
  final String label;
  final String? badge;
  final bool isCenter;
}

class CustomConvexBottomBar extends StatefulWidget {
  const CustomConvexBottomBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    super.key,
    this.backgroundColor = Colors.black,
    this.activeColor = const Color(0xFF6366F1),
    this.inactiveColor = const Color(0xFF6B7280),
    this.height = 68,
  });
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ConvexBarItem> items;
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;
  final double height;

  @override
  State<CustomConvexBottomBar> createState() => _CustomConvexBottomBarState();
}

class _CustomConvexBottomBarState extends State<CustomConvexBottomBar>
    with TickerProviderStateMixin {
  late AnimationController _centerAnimationController;
  late AnimationController _itemAnimationController;
  late Animation<double> _centerScaleAnimation;
  late Animation<double> _centerRotationAnimation;

  @override
  void initState() {
    super.initState();

    _centerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _itemAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _centerScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _centerAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _centerRotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _centerAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _centerAnimationController.dispose();
    _itemAnimationController.dispose();
    super.dispose();
  }

  Future<void> _onItemTap(int index, bool isCenter) async {
    if (isCenter) {
      await _centerAnimationController.forward();
      await _centerAnimationController.reverse();
    } else {
      await _itemAnimationController.forward();
      await _itemAnimationController.reverse();
    }
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Container(
      height: widget.height,
      decoration: BoxDecoration(color: widget.backgroundColor),
      child: Row(
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isActive = index == widget.currentIndex;
          final isCenter = item.isCenter;

          return Expanded(
            child: _buildNavItem(item, index, isActive, isCenter),
          );
        }).toList(),
      ),
    ),
  );

  Widget _buildNavItem(
    ConvexBarItem item,
    int index,
    bool isActive,
    bool isCenter,
  ) => GestureDetector(
    onTap: () => _onItemTap(index, isCenter),

    behavior: HitTestBehavior.translucent,
    child: SizedBox.expand(
      child: isCenter
          ? _buildCenterItem(item, isActive)
          : _buildRegularItem(item, isActive, index),
    ),
  );

  Widget _buildCenterItem(ConvexBarItem item, bool isActive) => Stack(
    clipBehavior: Clip.none,
    alignment: Alignment.center,
    children: [
      Positioned(
        top: -22,
        child: AnimatedBuilder(
          animation: _centerAnimationController,
          builder: (context, child) {
            final color = context.customTheme.overlayApp;
            return Transform.scale(
              scale: _centerScaleAnimation.value,
              child: Transform.rotate(
                angle: _centerRotationAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: color.iconGradient,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFE91E63,
                            ).withValues(alpha: .4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(item.icon, color: Colors.white, size: 18),
                    ),
                    const SizedBox(height: 14),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: isActive
                            ? widget.activeColor
                            : widget.inactiveColor,
                        fontSize: 12,
                        height: 1,
                        fontWeight: FontWeight.w400,
                      ),
                      child: Text(item.label),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );

  Widget _buildRegularItem(ConvexBarItem item, bool isActive, int index) =>
      AnimatedBuilder(
        animation: _itemAnimationController,
        builder: (context, child) {
          final isAnimating =
              index == widget.currentIndex &&
              _itemAnimationController.isAnimating;
          final scale = isAnimating ? 0.95 : 1.0;
          final color = context.customTheme.overlayApp;
          return Transform.scale(
            scale: scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: isActive
                          ? const EdgeInsets.all(8)
                          : const EdgeInsets.all(6),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          item.icon,
                          key: ValueKey('${item.icon}_$isActive'),
                          color: isActive
                              ? widget.activeColor
                              : widget.inactiveColor,
                          size: isActive ? 20 : 18,
                        ),
                      ),
                    ),
                    if (item.badge != null)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: AnimatedScale(
                          scale: isActive ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Badge.count(
                            count: int.parse(item.badge!),
                            backgroundColor: color.badgeColor,
                            alignment: Alignment.center,
                            smallSize: 16,
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              height: 1,
                              color: color.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isActive ? widget.activeColor : widget.inactiveColor,
                    fontSize: 12,
                    height: 1,
                    fontWeight: FontWeight.w400,
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          );
        },
      );
}

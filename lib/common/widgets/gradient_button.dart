import 'package:flutter/material.dart';
import 'package:zefyr/core/utils/icons/app_icons_icons.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({required this.onPressed, required this.text, super.key})
    : isMission = false;

  const GradientButton.isMission({
    required this.onPressed,
    required this.text,
    super.key,
  }) : isMission = true;
  final VoidCallback? onPressed;
  final String text;
  final bool isMission;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: 48,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF7C3AED), // #7C3AED at 0%
          Color(0xFFEC4899), // #EC4899 at 52.88%
          Color(0xFF3B82F6), // #3B82F6 at 100%
        ],
        stops: [0.0, 0.5288, 1.0],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isMission) ...[
                const Icon(AppIcons.missions, color: Colors.white, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

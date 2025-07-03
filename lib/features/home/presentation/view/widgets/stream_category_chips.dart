import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyr/common/extensions/context_theme.dart';

class StreamCategoryChips extends ConsumerStatefulWidget {
  const StreamCategoryChips({super.key});

  @override
  ConsumerState<StreamCategoryChips> createState() =>
      _StreamCategoryChipsState();
}

class _StreamCategoryChipsState extends ConsumerState<StreamCategoryChips> {
  final _categories = [
    'For You',
    'Popular',
    'Gaming',
    'Music',
    'Sports',
    'News',
    'Entertainment',
  ];
  final _selectedCategory = StateProvider<int?>((ref) => null);
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: _categories
          .mapIndexed(
            (i, category) => _CategoryChip(
              category: category,
              isSelected: ref.watch(_selectedCategory) == i,
              onTap: () => ref.read(_selectedCategory.notifier).state = i,
            ),
          )
          .toList(),
    ),
  );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
    super.key,
  });
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.customTheme.overlayApp;
    return Container(
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(colors: color.iconGradient)
                  : null,
              color: color.textFieldBackgroundColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: color.white,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

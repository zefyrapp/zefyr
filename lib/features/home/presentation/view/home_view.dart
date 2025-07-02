import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zefyr/common/extensions/context_theme.dart';
import 'package:zefyr/common/widgets/gradient_border_image.dart';
import 'package:zefyr/features/home/presentation/widgets/money_chip.dart';

class HomeView extends StatelessWidget {
  /// Главный экран
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.customTheme.overlayApp;
    return Scaffold(
      backgroundColor: color.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                spacing: 9,
                children: [
                  GradientBorderImage(
                    size: 42,
                    onTap: () => context.push('/profile'),
                    //!TODO: аватар пользователя
                    child: const SizedBox.shrink(),
                  ),
                  MoneyChip(onTap: () {}, coins: '100'),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: StreamCategoryChips(),
            ),
            const ProfileCardsExample(),
          ],
        ),
      ),
    );
  }
}

class StreamShortCard extends StatelessWidget {
  const StreamShortCard({
    required this.username,
    required this.activity,
    required this.viewCount,
    required this.avatarUrl,
    required this.backgroundImageUrl,
    super.key,
    this.onTap,
  });

  final String username;
  final String activity;
  final String viewCount;
  final String avatarUrl;
  final String backgroundImageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network(
              backgroundImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: Color(0xff111827),
                child: Icon(Icons.person, color: Colors.white54, size: 80),
              ),
            ),
          ),

          // Dark gradient overlay for better text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),

          // View count badge
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                viewCount,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),

          // Bottom content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Username and avatar row
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            avatarUrl,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey[600],
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                height: 14 / 14,
                                letterSpacing: 0,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              activity,
                              style: const TextStyle(
                                color: Color(0xffD1D5DB),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 12 / 12,
                                letterSpacing: 0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Пример использования
class ProfileCardsExample extends StatelessWidget {
  const ProfileCardsExample({super.key});
  static const List<Map<String, String>> streamData = [
    {
      'username': 'Alina_Star',
      'activity': 'Dance party!',
      'viewCount': '2.1K',
      'avatarUrl': 'https://placebeard.it/640/480',
      'backgroundImageUrl': 'https://placebeard.it/640/480',
    },
    {
      'username': 'ProGamer22',
      'activity': 'Apex Legends',
      'viewCount': '843',
      'avatarUrl': 'https://placebeard.it/640/480',
      'backgroundImageUrl': 'https://placebeard.it/640/480',
    },
    {
      'username': 'MusicMaster',
      'activity': 'Live Concert',
      'viewCount': '1.5K',
      'avatarUrl': 'https://placebeard.it/640/480',
      'backgroundImageUrl': 'https://placebeard.it/640/480',
    },
    {
      'username': 'ArtCreator',
      'activity': 'Digital Art',
      'viewCount': '567',
      'avatarUrl': 'https://placebeard.it/640/480',
      'backgroundImageUrl': 'https://placebeard.it/640/480',
    },
    {
      'username': 'ChefExpert',
      'activity': 'Cooking Show',
      'viewCount': '2.8K',
      'avatarUrl': 'https://placebeard.it/640/480',
      'backgroundImageUrl': 'https://placebeard.it/640/480',
    },
    {
      'username': 'FitnessGuru',
      'activity': 'Morning Workout',
      'viewCount': '934',
      'avatarUrl': 'https://placebeard.it/640/480',
      'backgroundImageUrl': 'https://placebeard.it/640/480',
    },
  ];
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 16),
    child: GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 177 / 314.66,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: streamData.length,
      itemBuilder: (context, index) {
        final data = streamData[index];
        return StreamShortCard(
          username: data['username']!,
          activity: data['activity']!,
          viewCount: data['viewCount']!,
          avatarUrl: data['avatarUrl']!,
          backgroundImageUrl: data['backgroundImageUrl']!,
          onTap: () => print('${data['username']} card tapped'),
        );
      },
    ),
  );
}

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

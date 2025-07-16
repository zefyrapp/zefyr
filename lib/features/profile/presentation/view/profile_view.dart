import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zefyr/common/extensions/context_theme.dart';
import 'package:zefyr/common/extensions/invert_color.dart';
import 'package:zefyr/common/extensions/localization.dart';
import 'package:zefyr/common/widgets/gradient_border_image.dart';
import 'package:zefyr/common/widgets/gradient_button.dart';
import 'package:zefyr/core/utils/icons/app_asset_icon.dart';
import 'package:zefyr/core/utils/icons/app_icons_icons.dart';

/// Экран профиля
class ProfileView extends StatelessWidget {
  const ProfileView({required this.isMe, super.key});
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    final color = context.customTheme.overlayApp;
    final local = context.localization;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.black,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          '@alexstream',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
        actions: [
          InkWell(
            onTap: () {},
            child: const Icon(AppIcons.share, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 18),
          InkWell(
            onTap: () {},
            child: const Icon(Icons.more_vert, color: Colors.white, size: 18),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: 86,
                    child: Row(
                      spacing: 16,
                      children: [
                        // Avatar with gradient border and LIVE indicator
                        Stack(
                          children: [
                            GradientBorderImage(
                              size: 84,
                              child: Image.network(
                                'https://example.com/avatar.jpg',
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 84,
                                      height: 84,
                                      color: Colors.grey[800],
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                              ),
                            ),
                            if (!isMe)
                              Positioned(
                                bottom: 0,
                                left: 14,
                                right: 14,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'LIVE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name and rating
                            const Row(
                              children: [
                                Text(
                                  'Алексей Стримов',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    height: 1,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  AppIcons.star_7,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '4.7',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: ' Inter',
                                    fontWeight: FontWeight.w400,

                                    fontSize: 14,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                            if (isMe) ...[
                              ElevatedButton(
                                onPressed: () => context.push('/profile/edit'),
                                style: ButtonStyle(
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                      side: BorderSide(
                                        color: color.indicatorColor,
                                      ),
                                    ),
                                  ),
                                  minimumSize: const WidgetStatePropertyAll(
                                    Size(180, 34),
                                  ),
                                  backgroundColor: const WidgetStatePropertyAll(
                                    Colors.black,
                                  ),
                                ),
                                child: Text(
                                  'Редактировать профиль',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    height: 1,
                                    color: color.white,
                                  ),
                                ),
                              ),
                            ] else ...[
                              Row(
                                spacing: 8,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {},
                                    style: ButtonStyle(
                                      shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          side: BorderSide(
                                            color: color.indicatorColor,
                                          ),
                                        ),
                                      ),
                                      minimumSize: const WidgetStatePropertyAll(
                                        Size(150, 34),
                                      ),
                                      backgroundColor:
                                          const WidgetStatePropertyAll(
                                            Colors.black,
                                          ),
                                    ),
                                    icon: Icon(
                                      Icons.person_add_alt_1,
                                      color: color.indicatorColor,
                                      size: 14,
                                    ),
                                    label: Text(
                                      'Подписаться',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        height: 1,
                                        color: color.white,
                                      ),
                                    ),
                                  ),
                                  IconCircleButton(
                                    icon: AppIcons.ask2,
                                    onPressed: () {},
                                  ),

                                  IconCircleButton(
                                    icon: AppIcons.gift,
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  // Description
                  const Text(
                    'IRL стример и путешественник 🚀 Выполняю любые миссии в реальном мире!',
                    style: TextStyle(
                      color: Color(0xffD1D5DB),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,

                      fontSize: 14,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Statistics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('57', 'Миссий'),
                      _buildStatItem('12,5K', 'Подписчики'),
                      _buildStatItem('342', 'Подписки'),
                      _buildStatItem('30', 'Фаны'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (isMe) ...[
                    // Balance
                    Container(
                      width: double.infinity,
                      height: 61,
                      padding: const EdgeInsets.only(
                        left: 25,
                        right: 8,
                        top: 10,
                        bottom: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(17, 24, 39, .8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ваш баланс:',
                            style: TextStyle(
                              color: Color(0xffA2A2A2),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              height: 1,
                            ),
                          ),
                          Material(
                            color: const Color.fromRGBO(203, 197, 197, 0.21),
                            borderRadius: BorderRadius.circular(22),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 11,
                                top: 8,
                                bottom: 8,
                                right: 8,
                              ),
                              child: Row(
                                spacing: 6,
                                children: [
                                  Image.asset(
                                    AppAssetIcon.money,
                                    height: 21,
                                    width: 21,
                                  ),

                                  const Text(
                                    '100',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: ' Inter',
                                      height: 1,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ButtonStyle(
                                      shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                        ),
                                      ),
                                      padding: const WidgetStatePropertyAll(
                                        EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                      fixedSize: const WidgetStatePropertyAll(
                                        Size(117, 26),
                                      ),
                                      backgroundColor:
                                          const WidgetStatePropertyAll(
                                            Colors.white,
                                          ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          color: color.black,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Пополнить',
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            height: 1,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    GradientButton.isMission(
                      onPressed: () {},
                      text: 'Заказать миссию',
                    ),
                  ],
                ],
              ),
            ),
            // Tabs
            const ProfileMissionChatView(),
            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          height: 1,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          color: Color(0xff9CA3AF),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 1,
        ),
      ),
    ],
  );
}

class ProfileMissionChatView extends StatefulWidget {
  const ProfileMissionChatView({super.key});

  @override
  State<ProfileMissionChatView> createState() => _ProfileMissionChatViewState();
}

class _ProfileMissionChatViewState extends State<ProfileMissionChatView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min, // Add this line
    children: [
      // Tabs (Custom Tab Bar)
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildCustomTab('Миссии', 0),
            const SizedBox(width: 32),
            _buildCustomTab('Чат', 1),
          ],
        ),
      ),
      const SizedBox(height: 16),
      // TabBarView with fixed height
      SizedBox(
        height: 400, // Set a fixed height instead of using Expanded
        child: TabBarView(
          controller: _tabController,
          children: [
            // Страница миссий
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => _buildMissionCard(),
              ),
            ),
            // Страница чата
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Чат',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Здесь может быть ваш чат интерфейс
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Чат интерфейс',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildCustomTab(String title, int index) => AnimatedBuilder(
    animation: _tabController,
    builder: (context, child) {
      final bool isActive = _tabController.index == index;
      return GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white60,
                fontSize: 16,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: 40,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _buildMissionCard() => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      image: const DecorationImage(
        image: NetworkImage(
          'https://example.com/tokyo-night.jpg',
        ), // Replace with actual image
        fit: BoxFit.cover,
      ),
    ),
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
        ),
      ),
      child: Stack(
        children: [
          // View count
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility, color: Colors.white, size: 12),
                  SizedBox(width: 2),
                  Text(
                    '1.2K',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          // Title and flag
          const Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Ночной Токио:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text('🇯🇵', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class IconCircleButton extends StatelessWidget {
  const IconCircleButton({
    required this.icon,
    required this.onPressed,
    super.key,
  });
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 34,
    height: 34,
    child: Material(
      color: Colors.transparent,
      shape: const CircleBorder(side: BorderSide(color: Color(0xFF4B5563))),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Center(child: Icon(icon, size: 16, color: Colors.white)),
      ),
    ),
  );
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:zefyr/features/home/presentation/view/streaming/stream_short_card.dart';

class StreamingListView extends StatelessWidget {
  const StreamingListView({super.key});

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
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
    sliver: SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 177 / 314.66,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final data = streamData[index];
        return StreamShortCard(
          username: data['username']!,
          activity: data['activity']!,
          viewCount: data['viewCount']!,
          avatarUrl: data['avatarUrl']!,
          backgroundImageUrl: data['backgroundImageUrl']!,
          onTap: () =>log('${data['username']} card tapped'),
        );
      }, childCount: streamData.length),
    ),
  );
}

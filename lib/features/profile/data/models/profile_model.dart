import 'dart:convert';
import 'package:zefyr/features/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.name,
    required super.nickname,
    required super.bio,
    required super.avatar,
    required super.rating,
    required super.missionsCount,
    required super.followersCount,
    required super.followingCount,
    required super.fansCount,
    required super.balance,
    required super.isLive,
    required super.isFollowing,
    required super.createdAt,
    required super.updatedAt,
    required super.dateOfBirth,
    required super.isPrivate,
    required super.isFollowedBy,
    required super.user,
    super.avatarUrl,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) => ProfileModel(
    name: map['full_name'] as String,
    nickname: map['nickname'] as String,
    bio: map['bio'] as String? ?? '',
    avatar: map['avatar'] as String?,
    avatarUrl: map['avatar_url'] as String?,
    rating: ProfileRating.fromMap(map['rating'] as Map<String, dynamic>),
    missionsCount: map['missions_count'] as int? ?? 0,
    followersCount: map['followers_count'] as int? ?? 0,
    followingCount: map['following_count'] as int? ?? 0,
    fansCount: map['fans_count'] as int? ?? 0,
    balance: double.tryParse(map['balance'] as String? ?? '0.0'),
    isLive: map['is_live'] as bool? ?? false,
    isFollowing: map['is_following'] as bool? ?? false,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
    dateOfBirth: map['date_of_birth'] as String,
    isPrivate: map['is_private'] as bool? ?? false,
    isFollowedBy: map['is_followed_by'] as bool? ?? false,
    user: ProfileUser.fromMap(map['user'] as Map<String, dynamic>),
  );

  factory ProfileModel.fromJson(String source) =>
      ProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() => {
    'full_name': name,
    'nickname': nickname,
    'bio': bio,
    'avatar': avatar,
    'rating': rating,
    'missions_count': missionsCount,
    'followers_count': followersCount,
    'following_count': followingCount,
    'fans_count': fansCount,
    'balance': balance,
    'is_live': isLive,
    'is_following': isFollowing,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  String toJson() => json.encode(toMap());

  ProfileModel copyWith({
    String? name,
    String? nickname,
    String? avatar,
    String? avatarUrl,
    String? bio,
    String? dateOfBirth,
    int? followersCount,
    int? followingCount,
    int? missionsCount,
    int? fansCount,
    bool? isPrivate,
    bool? isFollowing,
    bool? isFollowedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProfileUser? user,
    ProfileRating? rating,
    double? balance,
    bool? isLive,
  }) => ProfileModel(
    name: name ?? this.name,
    nickname: nickname ?? this.nickname,
    bio: bio ?? this.bio,
    avatar: avatar ?? this.avatar,
    rating: rating ?? this.rating,
    user: user ?? this.user,
    missionsCount: missionsCount ?? this.missionsCount,
    followersCount: followersCount ?? this.followersCount,
    followingCount: followingCount ?? this.followingCount,
    fansCount: fansCount ?? this.fansCount,
    balance: balance ?? this.balance,
    isLive: isLive ?? this.isLive,
    isFollowing: isFollowing ?? this.isFollowing,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    isPrivate: isPrivate ?? this.isPrivate,
    isFollowedBy: isFollowing ?? this.isFollowedBy,
  );
}

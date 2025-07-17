// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.name,
    required this.nickname,
    required this.bio,
    required this.avatar,
    required this.rating,
    required this.missionsCount,
    required this.followersCount,
    required this.followingCount,
    required this.fansCount,
    required this.balance,
    required this.isLive,
    required this.isFollowing,
    required this.createdAt,
    required this.updatedAt,
    required this.dateOfBirth,
    required this.isPrivate,
    required this.isFollowedBy,
    required this.user,
    this.avatarUrl,
  });

  final String name;
  final String nickname;

  final String? avatar;
  final String? avatarUrl;
  final String bio;
  final String dateOfBirth;
  final int followersCount;
  final int followingCount;
  final int missionsCount;
  final int fansCount;
  final bool isPrivate;
  final bool isFollowing;
  final bool isFollowedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProfileUser user;
  final ProfileRating rating;
  final double? balance;
  final bool isLive;

  @override
  List<Object?> get props => [
    name,
    nickname,
    bio,
    avatar,
    rating,
    missionsCount,
    followersCount,
    followingCount,
    fansCount,
    balance,
    isLive,
    isFollowing,
    createdAt,
    updatedAt,
  ];
}

class ProfileUser extends Equatable {
  const ProfileUser({required this.id, required this.email});

  final String id;
  final String email;

  @override
  List<Object> get props => [id, email];

  ProfileUser copyWith({String? id, String? email}) =>
      ProfileUser(id: id ?? this.id, email: email ?? this.email);

  Map<String, dynamic> toMap() => <String, dynamic>{'id': id, 'email': email};

  factory ProfileUser.fromMap(Map<String, dynamic> map) =>
      ProfileUser(id: map['id'] as String, email: map['email'] as String);

  String toJson() => json.encode(toMap());

  factory ProfileUser.fromJson(String source) =>
      ProfileUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}

class ProfileRating extends Equatable {
  const ProfileRating({required this.rating, required this.totalVotes});

  final double rating;
  final int totalVotes;

  @override
  List<Object> get props => [rating, totalVotes];

  ProfileRating copyWith({double? rating, int? totalVotes}) => ProfileRating(
    rating: rating ?? this.rating,
    totalVotes: totalVotes ?? this.totalVotes,
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'rating': rating,
    'total_votes': totalVotes,
  };

  factory ProfileRating.fromMap(Map<String, dynamic> map) => ProfileRating(
    rating: map['rating'] as double,
    totalVotes: map['total_votes'] as int,
  );

  String toJson() => json.encode(toMap());

  factory ProfileRating.fromJson(String source) =>
      ProfileRating.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}

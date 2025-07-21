import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:zefyr/core/database/database.dart';
import 'package:zefyr/features/profile/data/models/profile_model.dart';
import 'package:zefyr/features/profile/domain/entities/profile_entity.dart';

class ProfileDao {
  const ProfileDao(this.db);
  final AppDatabase db;

  /// Сохраняет/обновляет профиль пользователя
  Future<void> insertOrUpdateProfile(ProfileModel profile) async {
    final userId = int.tryParse(profile.user.id) ?? 0;

    await db
        .into(db.profiles)
        .insertOnConflictUpdate(
          ProfilesCompanion(
            userId: Value(userId),
            name: Value(profile.name),
            nickname: Value(profile.nickname),
            bio: Value(profile.bio),
            avatar: Value(profile.avatar),
            avatarUrl: Value(profile.avatarUrl),
            dateOfBirth: Value(profile.dateOfBirth),
            missionsCount: Value(profile.missionsCount),
            followersCount: Value(profile.followersCount),
            followingCount: Value(profile.followingCount),
            fansCount: Value(profile.fansCount),
            balance: Value(profile.balance),
            isLive: Value(profile.isLive),
            isFollowing: Value(profile.isFollowing),
            isPrivate: Value(profile.isPrivate),
            isFollowedBy: Value(profile.isFollowedBy),
            createdAt: Value(profile.createdAt),
            updatedAt: Value(profile.updatedAt),
            rating: Value(json.encode(profile.rating.toMap())),
            user: Value(json.encode(profile.user.toMap())),
          ),
        );
  }

  /// Получает профиль пользователя по ID
  Future<ProfileModel?> getProfile(String userId) async {
    final userIdInt = int.tryParse(userId) ?? 0;
    final profileRow = await (db.select(
      db.profiles,
    )..where((tbl) => tbl.userId.equals(userIdInt))).getSingleOrNull();

    if (profileRow == null) return null;

    return _profileFromDrift(profileRow);
  }

  /// Получает "мой" профиль
  Future<ProfileModel?> getMyProfile() async {
    final myProfileRow = await db.select(db.myProfile).getSingleOrNull();
    if (myProfileRow == null) return null;

    final profileRow =
        await (db.select(db.profiles)
              ..where((tbl) => tbl.userId.equals(myProfileRow.userId)))
            .getSingleOrNull();

    if (profileRow == null) return null;

    return _profileFromDrift(profileRow);
  }

  /// Сохраняет/обновляет "мой" профиль
  Future<void> insertOrUpdateMyProfile(ProfileModel profile) async {
    final userId = int.tryParse(profile.user.id) ?? 0;

    await db.transaction(() async {
      // Сначала сохраняем сам профиль
      await insertOrUpdateProfile(profile);

      // Затем помечаем его как "мой"
      await db
          .into(db.myProfile)
          .insertOnConflictUpdate(
            MyProfileCompanion(id: const Value(1), userId: Value(userId)),
          );
    });
  }

  /// Удаляет профиль пользователя
  Future<void> deleteProfile(String userId) async {
    final userIdInt = int.tryParse(userId) ?? 0;
    await (db.delete(
      db.profiles,
    )..where((tbl) => tbl.userId.equals(userIdInt))).go();
  }

  /// Удаляет отметку "мой профиль"
  Future<void> clearMyProfile() async {
    await db.delete(db.myProfile).go();
  }

  /// Очищает все профили
  Future<void> clearAllProfiles() async {
    await db.transaction(() async {
      await db.delete(db.myProfile).go();
      await db.delete(db.profiles).go();
    });
  }

  /// Получает все закешированные профили
  Future<List<ProfileModel>> getAllProfiles() async {
    final profileRows = await db.select(db.profiles).get();
    return profileRows.map(_profileFromDrift).toList();
  }

  /// Стрим для отслеживания изменений "моего" профиля
  Stream<ProfileModel?> watchMyProfile() => db
      .select(db.myProfile)
      .join([
        innerJoin(
          db.profiles,
          db.profiles.userId.equalsExp(db.myProfile.userId),
        ),
      ])
      .watchSingleOrNull()
      .map((result) {
        if (result == null) return null;
        final profileRow = result.readTable(db.profiles);
        return _profileFromDrift(profileRow);
      });

  /// Создает ProfileModel из данных Drift
  ProfileModel _profileFromDrift(Profile profileRow) => ProfileModel(
    name: profileRow.name,
    nickname: profileRow.nickname,
    bio: profileRow.bio,
    avatar: profileRow.avatar,
    avatarUrl: profileRow.avatarUrl,
    dateOfBirth: profileRow.dateOfBirth,
    missionsCount: profileRow.missionsCount,
    followersCount: profileRow.followersCount,
    followingCount: profileRow.followingCount,
    fansCount: profileRow.fansCount,
    balance: profileRow.balance,
    isLive: profileRow.isLive,
    isFollowing: profileRow.isFollowing,
    isPrivate: profileRow.isPrivate,
    isFollowedBy: profileRow.isFollowedBy,
    createdAt: profileRow.createdAt,
    updatedAt: profileRow.updatedAt,
    rating: ProfileRating.fromMap(
      json.decode(profileRow.rating) as Map<String, dynamic>,
    ),
    user: ProfileUser.fromMap(
      json.decode(profileRow.user) as Map<String, dynamic>,
    ),
  );
}

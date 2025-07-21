import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text()();
  BoolColumn get isActive => boolean().nullable()();
  DateTimeColumn get lastActive => dateTime().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get avatar => text().nullable()();
}

// Таблица для хранения токенов аутентификации
class AuthTokens extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get accessToken => text()();
  TextColumn get refreshToken => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class Profiles extends Table {
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get nickname => text()();
  TextColumn get bio => text()();
  TextColumn get avatar => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get dateOfBirth => text()();
  IntColumn get missionsCount => integer().withDefault(const Constant(0))();
  IntColumn get followersCount => integer().withDefault(const Constant(0))();
  IntColumn get followingCount => integer().withDefault(const Constant(0))();
  IntColumn get fansCount => integer().withDefault(const Constant(0))();
  RealColumn get balance => real().nullable()();
  BoolColumn get isLive => boolean().withDefault(const Constant(false))();
  BoolColumn get isFollowing => boolean().withDefault(const Constant(false))();
  BoolColumn get isPrivate => boolean().withDefault(const Constant(false))();
  BoolColumn get isFollowedBy => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Рейтинг храним как JSON строку
  TextColumn get rating => text()();

  // Данные пользователя храним как JSON строку
  TextColumn get user => text()();

  @override
  Set<Column> get primaryKey => {userId};
}

// Таблица для отметки "моего" профиля
class MyProfile extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Users, AuthTokens, Profiles, MyProfile])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Добавляем новые таблицы при обновлении с предыдущих версий
        await m.addColumn(users, users.avatar);
        await m.addColumn(users, users.name);
        await m.createTable(profiles);
        await m.createTable(myProfile);
      }
    },
  );
}

LazyDatabase _openConnection() => LazyDatabase(() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'app.sqlite'));
  return NativeDatabase(file);
});

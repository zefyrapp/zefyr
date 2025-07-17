// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$remoteProfileDataSourceHash() =>
    r'a339be2088e40d412d552c3c35c9af3aaec315d7';

/// See also [remoteProfileDataSource].
@ProviderFor(remoteProfileDataSource)
final remoteProfileDataSourceProvider =
    AutoDisposeProvider<RemoteProfileDataSource>.internal(
      remoteProfileDataSource,
      name: r'remoteProfileDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$remoteProfileDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RemoteProfileDataSourceRef =
    AutoDisposeProviderRef<RemoteProfileDataSource>;
String _$localProfileDataSourceHash() =>
    r'8f9dab033a08df8f69d3b0f2092c8d19f1ca675a';

/// See also [localProfileDataSource].
@ProviderFor(localProfileDataSource)
final localProfileDataSourceProvider =
    AutoDisposeProvider<LocalProfileDataSource>.internal(
      localProfileDataSource,
      name: r'localProfileDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$localProfileDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalProfileDataSourceRef =
    AutoDisposeProviderRef<LocalProfileDataSource>;
String _$profileRepositoryHash() => r'8d7340e8be0eff1428bec32d359947eabfe513dc';

/// See also [profileRepository].
@ProviderFor(profileRepository)
final profileRepositoryProvider =
    AutoDisposeProvider<ProfileRepository>.internal(
      profileRepository,
      name: r'profileRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileRepositoryRef = AutoDisposeProviderRef<ProfileRepository>;
String _$getMyProfileHash() => r'6009e13f6ba7d8b273c597d7df889d2f704dfeac';

/// See also [getMyProfile].
@ProviderFor(getMyProfile)
final getMyProfileProvider = AutoDisposeProvider<GetMyProfile>.internal(
  getMyProfile,
  name: r'getMyProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getMyProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetMyProfileRef = AutoDisposeProviderRef<GetMyProfile>;
String _$getUserProfileHash() => r'83d8bd4afe1b75d45b9832acfed54a8b0a390d16';

/// See also [getUserProfile].
@ProviderFor(getUserProfile)
final getUserProfileProvider = AutoDisposeProvider<GetUserProfile>.internal(
  getUserProfile,
  name: r'getUserProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getUserProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetUserProfileRef = AutoDisposeProviderRef<GetUserProfile>;
String _$updateMyProfileHash() => r'ce8702781a051db8e1260377fc5129991027354e';

/// See also [updateMyProfile].
@ProviderFor(updateMyProfile)
final updateMyProfileProvider = AutoDisposeProvider<UpdateMyProfile>.internal(
  updateMyProfile,
  name: r'updateMyProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$updateMyProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdateMyProfileRef = AutoDisposeProviderRef<UpdateMyProfile>;
String _$myProfileHash() => r'f689cfd022277400f976b4a4fef5016073d96932';

/// See also [myProfile].
@ProviderFor(myProfile)
final myProfileProvider = AutoDisposeFutureProvider<ProfileEntity?>.internal(
  myProfile,
  name: r'myProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyProfileRef = AutoDisposeFutureProviderRef<ProfileEntity?>;
String _$userProfileHash() => r'fea034f28b17fbbcba45ef53b766878e8b150938';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [userProfile].
@ProviderFor(userProfile)
const userProfileProvider = UserProfileFamily();

/// See also [userProfile].
class UserProfileFamily extends Family<AsyncValue<ProfileEntity?>> {
  /// See also [userProfile].
  const UserProfileFamily();

  /// See also [userProfile].
  UserProfileProvider call(String userId) {
    return UserProfileProvider(userId);
  }

  @override
  UserProfileProvider getProviderOverride(
    covariant UserProfileProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userProfileProvider';
}

/// See also [userProfile].
class UserProfileProvider extends AutoDisposeFutureProvider<ProfileEntity?> {
  /// See also [userProfile].
  UserProfileProvider(String userId)
    : this._internal(
        (ref) => userProfile(ref as UserProfileRef, userId),
        from: userProfileProvider,
        name: r'userProfileProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userProfileHash,
        dependencies: UserProfileFamily._dependencies,
        allTransitiveDependencies: UserProfileFamily._allTransitiveDependencies,
        userId: userId,
      );

  UserProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<ProfileEntity?> Function(UserProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserProfileProvider._internal(
        (ref) => create(ref as UserProfileRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ProfileEntity?> createElement() {
    return _UserProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserProfileRef on AutoDisposeFutureProviderRef<ProfileEntity?> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserProfileProviderElement
    extends AutoDisposeFutureProviderElement<ProfileEntity?>
    with UserProfileRef {
  _UserProfileProviderElement(super.provider);

  @override
  String get userId => (origin as UserProfileProvider).userId;
}

String _$myProfileNotifierHash() => r'33aba2ef2530732d75ed076c5ccb0ea5f62a0924';

/// See also [MyProfileNotifier].
@ProviderFor(MyProfileNotifier)
final myProfileNotifierProvider =
    AsyncNotifierProvider<MyProfileNotifier, ProfileEntity?>.internal(
      MyProfileNotifier.new,
      name: r'myProfileNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$myProfileNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MyProfileNotifier = AsyncNotifier<ProfileEntity?>;
String _$userProfileNotifierHash() =>
    r'0053886b88145ff39bce3a0d6905c64693847630';

abstract class _$UserProfileNotifier
    extends BuildlessAsyncNotifier<ProfileEntity?> {
  late final String nickname;

  FutureOr<ProfileEntity?> build(String nickname);
}

/// See also [UserProfileNotifier].
@ProviderFor(UserProfileNotifier)
const userProfileNotifierProvider = UserProfileNotifierFamily();

/// See also [UserProfileNotifier].
class UserProfileNotifierFamily extends Family<AsyncValue<ProfileEntity?>> {
  /// See also [UserProfileNotifier].
  const UserProfileNotifierFamily();

  /// See also [UserProfileNotifier].
  UserProfileNotifierProvider call(String nickname) {
    return UserProfileNotifierProvider(nickname);
  }

  @override
  UserProfileNotifierProvider getProviderOverride(
    covariant UserProfileNotifierProvider provider,
  ) {
    return call(provider.nickname);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userProfileNotifierProvider';
}

/// See also [UserProfileNotifier].
class UserProfileNotifierProvider
    extends AsyncNotifierProviderImpl<UserProfileNotifier, ProfileEntity?> {
  /// See also [UserProfileNotifier].
  UserProfileNotifierProvider(String nickname)
    : this._internal(
        () => UserProfileNotifier()..nickname = nickname,
        from: userProfileNotifierProvider,
        name: r'userProfileNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userProfileNotifierHash,
        dependencies: UserProfileNotifierFamily._dependencies,
        allTransitiveDependencies:
            UserProfileNotifierFamily._allTransitiveDependencies,
        nickname: nickname,
      );

  UserProfileNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.nickname,
  }) : super.internal();

  final String nickname;

  @override
  FutureOr<ProfileEntity?> runNotifierBuild(
    covariant UserProfileNotifier notifier,
  ) {
    return notifier.build(nickname);
  }

  @override
  Override overrideWith(UserProfileNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: UserProfileNotifierProvider._internal(
        () => create()..nickname = nickname,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        nickname: nickname,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<UserProfileNotifier, ProfileEntity?>
  createElement() {
    return _UserProfileNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileNotifierProvider && other.nickname == nickname;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, nickname.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserProfileNotifierRef on AsyncNotifierProviderRef<ProfileEntity?> {
  /// The parameter `nickname` of this provider.
  String get nickname;
}

class _UserProfileNotifierProviderElement
    extends AsyncNotifierProviderElement<UserProfileNotifier, ProfileEntity?>
    with UserProfileNotifierRef {
  _UserProfileNotifierProviderElement(super.provider);

  @override
  String get nickname => (origin as UserProfileNotifierProvider).nickname;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

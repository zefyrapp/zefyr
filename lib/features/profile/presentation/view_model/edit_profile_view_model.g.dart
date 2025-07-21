// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_profile_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$editProfileViewModelHash() =>
    r'6b2035a5bb90607d8ca882d32bed1f3f4eeed7ce';

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

abstract class _$EditProfileViewModel
    extends BuildlessAutoDisposeNotifier<EditProfileState> {
  late final ProfileEntity profile;

  EditProfileState build(ProfileEntity profile);
}

/// See also [EditProfileViewModel].
@ProviderFor(EditProfileViewModel)
const editProfileViewModelProvider = EditProfileViewModelFamily();

/// See also [EditProfileViewModel].
class EditProfileViewModelFamily extends Family<EditProfileState> {
  /// See also [EditProfileViewModel].
  const EditProfileViewModelFamily();

  /// See also [EditProfileViewModel].
  EditProfileViewModelProvider call(ProfileEntity profile) {
    return EditProfileViewModelProvider(profile);
  }

  @override
  EditProfileViewModelProvider getProviderOverride(
    covariant EditProfileViewModelProvider provider,
  ) {
    return call(provider.profile);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'editProfileViewModelProvider';
}

/// See also [EditProfileViewModel].
class EditProfileViewModelProvider
    extends
        AutoDisposeNotifierProviderImpl<
          EditProfileViewModel,
          EditProfileState
        > {
  /// See also [EditProfileViewModel].
  EditProfileViewModelProvider(ProfileEntity profile)
    : this._internal(
        () => EditProfileViewModel()..profile = profile,
        from: editProfileViewModelProvider,
        name: r'editProfileViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$editProfileViewModelHash,
        dependencies: EditProfileViewModelFamily._dependencies,
        allTransitiveDependencies:
            EditProfileViewModelFamily._allTransitiveDependencies,
        profile: profile,
      );

  EditProfileViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.profile,
  }) : super.internal();

  final ProfileEntity profile;

  @override
  EditProfileState runNotifierBuild(covariant EditProfileViewModel notifier) {
    return notifier.build(profile);
  }

  @override
  Override overrideWith(EditProfileViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: EditProfileViewModelProvider._internal(
        () => create()..profile = profile,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        profile: profile,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<EditProfileViewModel, EditProfileState>
  createElement() {
    return _EditProfileViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EditProfileViewModelProvider && other.profile == profile;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, profile.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EditProfileViewModelRef
    on AutoDisposeNotifierProviderRef<EditProfileState> {
  /// The parameter `profile` of this provider.
  ProfileEntity get profile;
}

class _EditProfileViewModelProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          EditProfileViewModel,
          EditProfileState
        >
    with EditProfileViewModelRef {
  _EditProfileViewModelProviderElement(super.provider);

  @override
  ProfileEntity get profile => (origin as EditProfileViewModelProvider).profile;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

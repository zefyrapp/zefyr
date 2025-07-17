// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_profile_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$editProfileViewModelHash() =>
    r'1a93c5f2d05be5b64eb6f96e80755c86a13e0e69';

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
  late final EditProfileRequest request;

  EditProfileState build(EditProfileRequest request);
}

/// See also [EditProfileViewModel].
@ProviderFor(EditProfileViewModel)
const editProfileViewModelProvider = EditProfileViewModelFamily();

/// See also [EditProfileViewModel].
class EditProfileViewModelFamily extends Family<EditProfileState> {
  /// See also [EditProfileViewModel].
  const EditProfileViewModelFamily();

  /// See also [EditProfileViewModel].
  EditProfileViewModelProvider call(EditProfileRequest request) {
    return EditProfileViewModelProvider(request);
  }

  @override
  EditProfileViewModelProvider getProviderOverride(
    covariant EditProfileViewModelProvider provider,
  ) {
    return call(provider.request);
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
  EditProfileViewModelProvider(EditProfileRequest request)
    : this._internal(
        () => EditProfileViewModel()..request = request,
        from: editProfileViewModelProvider,
        name: r'editProfileViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$editProfileViewModelHash,
        dependencies: EditProfileViewModelFamily._dependencies,
        allTransitiveDependencies:
            EditProfileViewModelFamily._allTransitiveDependencies,
        request: request,
      );

  EditProfileViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.request,
  }) : super.internal();

  final EditProfileRequest request;

  @override
  EditProfileState runNotifierBuild(covariant EditProfileViewModel notifier) {
    return notifier.build(request);
  }

  @override
  Override overrideWith(EditProfileViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: EditProfileViewModelProvider._internal(
        () => create()..request = request,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        request: request,
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
    return other is EditProfileViewModelProvider && other.request == request;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, request.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EditProfileViewModelRef
    on AutoDisposeNotifierProviderRef<EditProfileState> {
  /// The parameter `request` of this provider.
  EditProfileRequest get request;
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
  EditProfileRequest get request =>
      (origin as EditProfileViewModelProvider).request;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

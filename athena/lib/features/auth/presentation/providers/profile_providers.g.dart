// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileRemoteDataSourceHash() =>
    r'122de584f61aaf8913ee3016a511f58c4ae57ca3';

/// See also [profileRemoteDataSource].
@ProviderFor(profileRemoteDataSource)
final profileRemoteDataSourceProvider =
    Provider<ProfileRemoteDataSource>.internal(
      profileRemoteDataSource,
      name: r'profileRemoteDataSourceProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$profileRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileRemoteDataSourceRef = ProviderRef<ProfileRemoteDataSource>;
String _$profileRepositoryHash() => r'4f561b7f3adc7fec5c962ff19bf232320b9c6e40';

/// See also [profileRepository].
@ProviderFor(profileRepository)
final profileRepositoryProvider = Provider<ProfileRepository>.internal(
  profileRepository,
  name: r'profileRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileRepositoryRef = ProviderRef<ProfileRepository>;
String _$currentUserProfileHash() =>
    r'2eaf95c2c2bf36d3d5c956f3f59461a53a270fdc';

/// See also [currentUserProfile].
@ProviderFor(currentUserProfile)
final currentUserProfileProvider =
    AutoDisposeFutureProvider<ProfileEntity?>.internal(
      currentUserProfile,
      name: r'currentUserProfileProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$currentUserProfileHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserProfileRef = AutoDisposeFutureProviderRef<ProfileEntity?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

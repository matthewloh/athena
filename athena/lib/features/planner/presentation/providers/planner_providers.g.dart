// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planner_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$plannerDataSourceHash() => r'a554a0b2259a5d200b8a2e75234c9e383de368b1';

/// Provides the Supabase data source implementation
///
/// Copied from [plannerDataSource].
@ProviderFor(plannerDataSource)
final plannerDataSourceProvider =
    AutoDisposeProvider<PlannerSupabaseDataSourceImpl>.internal(
      plannerDataSource,
      name: r'plannerDataSourceProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$plannerDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlannerDataSourceRef =
    AutoDisposeProviderRef<PlannerSupabaseDataSourceImpl>;
String _$plannerRepositoryHash() => r'1a469d76be92105df44abee0cfb74e4d28cf1e0f';

/// Provides the planner repository implementation
///
/// Copied from [plannerRepository].
@ProviderFor(plannerRepository)
final plannerRepositoryProvider =
    AutoDisposeProvider<PlannerRepository>.internal(
      plannerRepository,
      name: r'plannerRepositoryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$plannerRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlannerRepositoryRef = AutoDisposeProviderRef<PlannerRepository>;
String _$getStudyGoalsUseCaseHash() =>
    r'321c40c889c43eccb97b5464308a3cd02ded0a2e';

/// Provides the get study goals use case
///
/// Copied from [getStudyGoalsUseCase].
@ProviderFor(getStudyGoalsUseCase)
final getStudyGoalsUseCaseProvider =
    AutoDisposeProvider<GetStudyGoalsUseCase>.internal(
      getStudyGoalsUseCase,
      name: r'getStudyGoalsUseCaseProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$getStudyGoalsUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetStudyGoalsUseCaseRef = AutoDisposeProviderRef<GetStudyGoalsUseCase>;
String _$getUpcomingSessionsUseCaseHash() =>
    r'8c38f6789399c74a472a0b794d96ce4263a07564';

/// Provides the get upcoming sessions use case
///
/// Copied from [getUpcomingSessionsUseCase].
@ProviderFor(getUpcomingSessionsUseCase)
final getUpcomingSessionsUseCaseProvider =
    AutoDisposeProvider<GetUpcomingSessionsUseCase>.internal(
      getUpcomingSessionsUseCase,
      name: r'getUpcomingSessionsUseCaseProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$getUpcomingSessionsUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetUpcomingSessionsUseCaseRef =
    AutoDisposeProviderRef<GetUpcomingSessionsUseCase>;
String _$currentUserIdHash() => r'a721cc26981c48fb97d50823142127aa9cc551ef';

/// Provides the current authenticated user ID
///
/// Copied from [currentUserId].
@ProviderFor(currentUserId)
final currentUserIdProvider = AutoDisposeProvider<String?>.internal(
  currentUserId,
  name: r'currentUserIdProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentUserIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserIdRef = AutoDisposeProviderRef<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

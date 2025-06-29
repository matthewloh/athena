// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeViewModelHash() => r'ec0f368c4e503666f41ab8387eca0805674d27c1';

/// ViewModel for managing home screen state and operations.
///
/// Handles the complete home dashboard flow:
/// - Loading user profile information
/// - Fetching dashboard statistics (materials, quiz items)
/// - Loading upcoming sessions from planner
/// - Fetching review items due for review
/// - Managing edge function demo calls
/// - Coordinating refresh operations
///
/// Copied from [HomeViewModel].
@ProviderFor(HomeViewModel)
final homeViewModelProvider =
    AutoDisposeNotifierProvider<HomeViewModel, HomeState>.internal(
      HomeViewModel.new,
      name: r'homeViewModelProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$homeViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeViewModel = AutoDisposeNotifier<HomeState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

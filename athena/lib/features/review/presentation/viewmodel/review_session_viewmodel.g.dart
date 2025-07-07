// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_session_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reviewSessionViewModelHash() =>
    r'cf2fa01ef07cc9b7cbb250c33240cc1da8ddc2ae';

/// ViewModel for managing review session state and operations.
///
/// Handles the complete review session flow:
/// - Starting and managing review sessions
/// - Presenting quiz items (flashcards and MCQs)
/// - Processing user responses and applying spaced repetition
/// - Tracking session progress and performance
///
/// Copied from [ReviewSessionViewModel].
@ProviderFor(ReviewSessionViewModel)
final reviewSessionViewModelProvider = AutoDisposeNotifierProvider<
  ReviewSessionViewModel,
  ReviewSessionState
>.internal(
  ReviewSessionViewModel.new,
  name: r'reviewSessionViewModelProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$reviewSessionViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReviewSessionViewModel = AutoDisposeNotifier<ReviewSessionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

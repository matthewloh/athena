// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_goals_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeStudyGoalsHash() => r'977fca032b1ea2da913f9c2f04fa3bea66f3ca3a';

/// Provider for active goals (not completed)
///
/// Copied from [activeStudyGoals].
@ProviderFor(activeStudyGoals)
final activeStudyGoalsProvider =
    AutoDisposeProvider<List<StudyGoalEntity>>.internal(
      activeStudyGoals,
      name: r'activeStudyGoalsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$activeStudyGoalsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveStudyGoalsRef = AutoDisposeProviderRef<List<StudyGoalEntity>>;
String _$completedStudyGoalsHash() =>
    r'92dddcc71478e22e6575242bb3c777b3f86a9a67';

/// Provider for completed goals
///
/// Copied from [completedStudyGoals].
@ProviderFor(completedStudyGoals)
final completedStudyGoalsProvider =
    AutoDisposeProvider<List<StudyGoalEntity>>.internal(
      completedStudyGoals,
      name: r'completedStudyGoalsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$completedStudyGoalsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompletedStudyGoalsRef = AutoDisposeProviderRef<List<StudyGoalEntity>>;
String _$overdueStudyGoalsHash() => r'e0b68296486e7f6aa36ca1b6b771f815e2ca458a';

/// Provider for overdue goals
///
/// Copied from [overdueStudyGoals].
@ProviderFor(overdueStudyGoals)
final overdueStudyGoalsProvider =
    AutoDisposeProvider<List<StudyGoalEntity>>.internal(
      overdueStudyGoals,
      name: r'overdueStudyGoalsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$overdueStudyGoalsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OverdueStudyGoalsRef = AutoDisposeProviderRef<List<StudyGoalEntity>>;
String _$studyGoalsViewModelHash() =>
    r'3187b9eb59968e53e2f4bf73394518059a12f14e';

/// ViewModel for managing study goals
///
/// Copied from [StudyGoalsViewModel].
@ProviderFor(StudyGoalsViewModel)
final studyGoalsViewModelProvider =
    AutoDisposeNotifierProvider<StudyGoalsViewModel, StudyGoalsState>.internal(
      StudyGoalsViewModel.new,
      name: r'studyGoalsViewModelProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$studyGoalsViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StudyGoalsViewModel = AutoDisposeNotifier<StudyGoalsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

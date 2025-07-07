// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_sessions_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionsByDateHash() => r'b74933abcdf1be71972af349ae8fa38bf95b28d9';

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

/// Provider for sessions on a specific date
///
/// Copied from [sessionsByDate].
@ProviderFor(sessionsByDate)
const sessionsByDateProvider = SessionsByDateFamily();

/// Provider for sessions on a specific date
///
/// Copied from [sessionsByDate].
class SessionsByDateFamily extends Family<List<StudySessionEntity>> {
  /// Provider for sessions on a specific date
  ///
  /// Copied from [sessionsByDate].
  const SessionsByDateFamily();

  /// Provider for sessions on a specific date
  ///
  /// Copied from [sessionsByDate].
  SessionsByDateProvider call(DateTime date) {
    return SessionsByDateProvider(date);
  }

  @override
  SessionsByDateProvider getProviderOverride(
    covariant SessionsByDateProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sessionsByDateProvider';
}

/// Provider for sessions on a specific date
///
/// Copied from [sessionsByDate].
class SessionsByDateProvider
    extends AutoDisposeProvider<List<StudySessionEntity>> {
  /// Provider for sessions on a specific date
  ///
  /// Copied from [sessionsByDate].
  SessionsByDateProvider(DateTime date)
    : this._internal(
        (ref) => sessionsByDate(ref as SessionsByDateRef, date),
        from: sessionsByDateProvider,
        name: r'sessionsByDateProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$sessionsByDateHash,
        dependencies: SessionsByDateFamily._dependencies,
        allTransitiveDependencies:
            SessionsByDateFamily._allTransitiveDependencies,
        date: date,
      );

  SessionsByDateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    List<StudySessionEntity> Function(SessionsByDateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionsByDateProvider._internal(
        (ref) => create(ref as SessionsByDateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<StudySessionEntity>> createElement() {
    return _SessionsByDateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionsByDateProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SessionsByDateRef on AutoDisposeProviderRef<List<StudySessionEntity>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _SessionsByDateProviderElement
    extends AutoDisposeProviderElement<List<StudySessionEntity>>
    with SessionsByDateRef {
  _SessionsByDateProviderElement(super.provider);

  @override
  DateTime get date => (origin as SessionsByDateProvider).date;
}

String _$upcomingSessionsHash() => r'ebe7d23766abbd2e9d0e6f02bf66366f4bde95ed';

/// Provider for upcoming sessions
///
/// Copied from [upcomingSessions].
@ProviderFor(upcomingSessions)
final upcomingSessionsProvider =
    AutoDisposeProvider<List<StudySessionEntity>>.internal(
      upcomingSessions,
      name: r'upcomingSessionsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$upcomingSessionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpcomingSessionsRef = AutoDisposeProviderRef<List<StudySessionEntity>>;
String _$todaySessionsHash() => r'060c71c738d38ca5ad6485b24c7b5eb49cad4986';

/// Provider for today's sessions
///
/// Copied from [todaySessions].
@ProviderFor(todaySessions)
final todaySessionsProvider =
    AutoDisposeProvider<List<StudySessionEntity>>.internal(
      todaySessions,
      name: r'todaySessionsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$todaySessionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodaySessionsRef = AutoDisposeProviderRef<List<StudySessionEntity>>;
String _$overdueSessionsHash() => r'79c396194eaaa961a70cb83c50ffad76012e560c';

/// Provider for overdue sessions
///
/// Copied from [overdueSessions].
@ProviderFor(overdueSessions)
final overdueSessionsProvider =
    AutoDisposeProvider<List<StudySessionEntity>>.internal(
      overdueSessions,
      name: r'overdueSessionsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$overdueSessionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OverdueSessionsRef = AutoDisposeProviderRef<List<StudySessionEntity>>;
String _$studySessionsViewModelHash() =>
    r'163736a80dd9e6c1d954a6ef2bc8b62d84d7d7d3';

/// ViewModel for managing study sessions
///
/// Copied from [StudySessionsViewModel].
@ProviderFor(StudySessionsViewModel)
final studySessionsViewModelProvider = AutoDisposeNotifierProvider<
  StudySessionsViewModel,
  StudySessionsState
>.internal(
  StudySessionsViewModel.new,
  name: r'studySessionsViewModelProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studySessionsViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StudySessionsViewModel = AutoDisposeNotifier<StudySessionsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

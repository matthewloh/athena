// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardRepositoryHash() =>
    r'01cd7672e50556b587406862d9dd7bd6e3a01208';

/// Provider for the dashboard repository
///
/// Copied from [dashboardRepository].
@ProviderFor(dashboardRepository)
final dashboardRepositoryProvider =
    AutoDisposeProvider<DashboardRepository>.internal(
      dashboardRepository,
      name: r'dashboardRepositoryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$dashboardRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardRepositoryRef = AutoDisposeProviderRef<DashboardRepository>;
String _$getDashboardDataUseCaseHash() =>
    r'0a01def012a5e620bc44a83b950c63194905a439';

/// Provider for the get dashboard data use case
///
/// Copied from [getDashboardDataUseCase].
@ProviderFor(getDashboardDataUseCase)
final getDashboardDataUseCaseProvider =
    AutoDisposeProvider<GetDashboardDataUseCase>.internal(
      getDashboardDataUseCase,
      name: r'getDashboardDataUseCaseProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$getDashboardDataUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetDashboardDataUseCaseRef =
    AutoDisposeProviderRef<GetDashboardDataUseCase>;
String _$dashboardDataHash() => r'1071ba03d8e348c6cdd8ef1896bded820afbef5f';

/// Provider for dashboard data
///
/// Copied from [dashboardData].
@ProviderFor(dashboardData)
final dashboardDataProvider = AutoDisposeFutureProvider<DashboardData>.internal(
  dashboardData,
  name: r'dashboardDataProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardDataRef = AutoDisposeFutureProviderRef<DashboardData>;
String _$isDashboardLoadingHash() =>
    r'be58f269e5711884cacf01635e799935fbc2d0b9';

/// Provider for dashboard loading state
///
/// Copied from [isDashboardLoading].
@ProviderFor(isDashboardLoading)
final isDashboardLoadingProvider = AutoDisposeProvider<bool>.internal(
  isDashboardLoading,
  name: r'isDashboardLoadingProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$isDashboardLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsDashboardLoadingRef = AutoDisposeProviderRef<bool>;
String _$materialCountHash() => r'a1d09cbe77021b1ab8f1eae4b0b19e7ad2b6deec';

/// Provider for dashboard material count
///
/// Copied from [materialCount].
@ProviderFor(materialCount)
final materialCountProvider = AutoDisposeFutureProvider<int>.internal(
  materialCount,
  name: r'materialCountProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$materialCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MaterialCountRef = AutoDisposeFutureProviderRef<int>;
String _$quizItemCountHash() => r'4b2c61e57ff622d3ee2d191ba00d1bae41216c52';

/// Provider for dashboard quiz items count
///
/// Copied from [quizItemCount].
@ProviderFor(quizItemCount)
final quizItemCountProvider = AutoDisposeFutureProvider<int>.internal(
  quizItemCount,
  name: r'quizItemCountProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$quizItemCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QuizItemCountRef = AutoDisposeFutureProviderRef<int>;
String _$upcomingSessionsHash() => r'f78c54802299db7007229ec55ce41cffd1f96d40';

/// Provider for upcoming sessions
///
/// Copied from [upcomingSessions].
@ProviderFor(upcomingSessions)
final upcomingSessionsProvider =
    AutoDisposeFutureProvider<List<UpcomingSession>>.internal(
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
typedef UpcomingSessionsRef =
    AutoDisposeFutureProviderRef<List<UpcomingSession>>;
String _$reviewItemsHash() => r'7f4cd99391ff1cf1faeaea262b059f1235766625';

/// Provider for review items
///
/// Copied from [reviewItems].
@ProviderFor(reviewItems)
final reviewItemsProvider =
    AutoDisposeFutureProvider<List<ReviewItem>>.internal(
      reviewItems,
      name: r'reviewItemsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$reviewItemsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReviewItemsRef = AutoDisposeFutureProviderRef<List<ReviewItem>>;
String _$helloEdgeFunctionHash() => r'0c43515ae154e2a59dc4f22a15df0f3d72db3d1a';

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

/// Provider for calling the hello-name edge function
///
/// Copied from [helloEdgeFunction].
@ProviderFor(helloEdgeFunction)
const helloEdgeFunctionProvider = HelloEdgeFunctionFamily();

/// Provider for calling the hello-name edge function
///
/// Copied from [helloEdgeFunction].
class HelloEdgeFunctionFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// Provider for calling the hello-name edge function
  ///
  /// Copied from [helloEdgeFunction].
  const HelloEdgeFunctionFamily();

  /// Provider for calling the hello-name edge function
  ///
  /// Copied from [helloEdgeFunction].
  HelloEdgeFunctionProvider call(String userName) {
    return HelloEdgeFunctionProvider(userName);
  }

  @override
  HelloEdgeFunctionProvider getProviderOverride(
    covariant HelloEdgeFunctionProvider provider,
  ) {
    return call(provider.userName);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'helloEdgeFunctionProvider';
}

/// Provider for calling the hello-name edge function
///
/// Copied from [helloEdgeFunction].
class HelloEdgeFunctionProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// Provider for calling the hello-name edge function
  ///
  /// Copied from [helloEdgeFunction].
  HelloEdgeFunctionProvider(String userName)
    : this._internal(
        (ref) => helloEdgeFunction(ref as HelloEdgeFunctionRef, userName),
        from: helloEdgeFunctionProvider,
        name: r'helloEdgeFunctionProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$helloEdgeFunctionHash,
        dependencies: HelloEdgeFunctionFamily._dependencies,
        allTransitiveDependencies:
            HelloEdgeFunctionFamily._allTransitiveDependencies,
        userName: userName,
      );

  HelloEdgeFunctionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userName,
  }) : super.internal();

  final String userName;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(HelloEdgeFunctionRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HelloEdgeFunctionProvider._internal(
        (ref) => create(ref as HelloEdgeFunctionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userName: userName,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _HelloEdgeFunctionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HelloEdgeFunctionProvider && other.userName == userName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HelloEdgeFunctionRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `userName` of this provider.
  String get userName;
}

class _HelloEdgeFunctionProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with HelloEdgeFunctionRef {
  _HelloEdgeFunctionProviderElement(super.provider);

  @override
  String get userName => (origin as HelloEdgeFunctionProvider).userName;
}

String _$edgeFunctionNameHash() => r'1928df5262f9aa7dd8f1108914d9603782b38aa7';

/// Provider to track the input name for the edge function
///
/// Copied from [EdgeFunctionName].
@ProviderFor(EdgeFunctionName)
final edgeFunctionNameProvider =
    AutoDisposeNotifierProvider<EdgeFunctionName, String>.internal(
      EdgeFunctionName.new,
      name: r'edgeFunctionNameProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$edgeFunctionNameHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EdgeFunctionName = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

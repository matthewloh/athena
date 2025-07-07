// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quizDetailViewModelHash() =>
    r'a02a606ec71d6df06ec4f73167e482686aeef592';

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

abstract class _$QuizDetailViewModel
    extends BuildlessAutoDisposeNotifier<QuizDetailState> {
  late final String quizId;

  QuizDetailState build(String quizId);
}

/// See also [QuizDetailViewModel].
@ProviderFor(QuizDetailViewModel)
const quizDetailViewModelProvider = QuizDetailViewModelFamily();

/// See also [QuizDetailViewModel].
class QuizDetailViewModelFamily extends Family<QuizDetailState> {
  /// See also [QuizDetailViewModel].
  const QuizDetailViewModelFamily();

  /// See also [QuizDetailViewModel].
  QuizDetailViewModelProvider call(String quizId) {
    return QuizDetailViewModelProvider(quizId);
  }

  @override
  QuizDetailViewModelProvider getProviderOverride(
    covariant QuizDetailViewModelProvider provider,
  ) {
    return call(provider.quizId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'quizDetailViewModelProvider';
}

/// See also [QuizDetailViewModel].
class QuizDetailViewModelProvider
    extends
        AutoDisposeNotifierProviderImpl<QuizDetailViewModel, QuizDetailState> {
  /// See also [QuizDetailViewModel].
  QuizDetailViewModelProvider(String quizId)
    : this._internal(
        () => QuizDetailViewModel()..quizId = quizId,
        from: quizDetailViewModelProvider,
        name: r'quizDetailViewModelProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$quizDetailViewModelHash,
        dependencies: QuizDetailViewModelFamily._dependencies,
        allTransitiveDependencies:
            QuizDetailViewModelFamily._allTransitiveDependencies,
        quizId: quizId,
      );

  QuizDetailViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.quizId,
  }) : super.internal();

  final String quizId;

  @override
  QuizDetailState runNotifierBuild(covariant QuizDetailViewModel notifier) {
    return notifier.build(quizId);
  }

  @override
  Override overrideWith(QuizDetailViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: QuizDetailViewModelProvider._internal(
        () => create()..quizId = quizId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        quizId: quizId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<QuizDetailViewModel, QuizDetailState>
  createElement() {
    return _QuizDetailViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuizDetailViewModelProvider && other.quizId == quizId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, quizId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin QuizDetailViewModelRef
    on AutoDisposeNotifierProviderRef<QuizDetailState> {
  /// The parameter `quizId` of this provider.
  String get quizId;
}

class _QuizDetailViewModelProviderElement
    extends
        AutoDisposeNotifierProviderElement<QuizDetailViewModel, QuizDetailState>
    with QuizDetailViewModelRef {
  _QuizDetailViewModelProviderElement(super.provider);

  @override
  String get quizId => (origin as QuizDetailViewModelProvider).quizId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

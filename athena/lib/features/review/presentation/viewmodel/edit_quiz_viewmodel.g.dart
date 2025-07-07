// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_quiz_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$editQuizViewModelHash() => r'790db685bb6bc7ae03ed5619759b58b6e56a797e';

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

abstract class _$EditQuizViewModel
    extends BuildlessAutoDisposeNotifier<EditQuizState> {
  late final String quizId;

  EditQuizState build(String quizId);
}

/// See also [EditQuizViewModel].
@ProviderFor(EditQuizViewModel)
const editQuizViewModelProvider = EditQuizViewModelFamily();

/// See also [EditQuizViewModel].
class EditQuizViewModelFamily extends Family<EditQuizState> {
  /// See also [EditQuizViewModel].
  const EditQuizViewModelFamily();

  /// See also [EditQuizViewModel].
  EditQuizViewModelProvider call(String quizId) {
    return EditQuizViewModelProvider(quizId);
  }

  @override
  EditQuizViewModelProvider getProviderOverride(
    covariant EditQuizViewModelProvider provider,
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
  String? get name => r'editQuizViewModelProvider';
}

/// See also [EditQuizViewModel].
class EditQuizViewModelProvider
    extends AutoDisposeNotifierProviderImpl<EditQuizViewModel, EditQuizState> {
  /// See also [EditQuizViewModel].
  EditQuizViewModelProvider(String quizId)
    : this._internal(
        () => EditQuizViewModel()..quizId = quizId,
        from: editQuizViewModelProvider,
        name: r'editQuizViewModelProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$editQuizViewModelHash,
        dependencies: EditQuizViewModelFamily._dependencies,
        allTransitiveDependencies:
            EditQuizViewModelFamily._allTransitiveDependencies,
        quizId: quizId,
      );

  EditQuizViewModelProvider._internal(
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
  EditQuizState runNotifierBuild(covariant EditQuizViewModel notifier) {
    return notifier.build(quizId);
  }

  @override
  Override overrideWith(EditQuizViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: EditQuizViewModelProvider._internal(
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
  AutoDisposeNotifierProviderElement<EditQuizViewModel, EditQuizState>
  createElement() {
    return _EditQuizViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EditQuizViewModelProvider && other.quizId == quizId;
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
mixin EditQuizViewModelRef on AutoDisposeNotifierProviderRef<EditQuizState> {
  /// The parameter `quizId` of this provider.
  String get quizId;
}

class _EditQuizViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<EditQuizViewModel, EditQuizState>
    with EditQuizViewModelRef {
  _EditQuizViewModelProviderElement(super.provider);

  @override
  String get quizId => (origin as EditQuizViewModelProvider).quizId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatSupabaseDataSourceHash() =>
    r'4c794e99b3eb5b709ed8e3da511c6515bbe4b31b';

/// See also [chatSupabaseDataSource].
@ProviderFor(chatSupabaseDataSource)
final chatSupabaseDataSourceProvider =
    AutoDisposeProvider<ChatSupabaseDataSourceImpl>.internal(
      chatSupabaseDataSource,
      name: r'chatSupabaseDataSourceProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$chatSupabaseDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatSupabaseDataSourceRef =
    AutoDisposeProviderRef<ChatSupabaseDataSourceImpl>;
String _$chatRepositoryHash() => r'7e3d78d721b1eec6b207ea5d646f3719e1f6e992';

/// See also [chatRepository].
@ProviderFor(chatRepository)
final chatRepositoryProvider = AutoDisposeProvider<ChatRepository>.internal(
  chatRepository,
  name: r'chatRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatRepositoryRef = AutoDisposeProviderRef<ChatRepository>;
String _$sendMessageUseCaseHash() =>
    r'dda92eb2e903ee948d8c3f7f3ebaef1817d9b6fa';

/// See also [sendMessageUseCase].
@ProviderFor(sendMessageUseCase)
final sendMessageUseCaseProvider =
    AutoDisposeProvider<SendMessageUseCase>.internal(
      sendMessageUseCase,
      name: r'sendMessageUseCaseProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$sendMessageUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SendMessageUseCaseRef = AutoDisposeProviderRef<SendMessageUseCase>;
String _$getChatHistoryUseCaseHash() =>
    r'7b15b8290b4c7b6d4cb764caa43b40ebbb9e6b80';

/// See also [getChatHistoryUseCase].
@ProviderFor(getChatHistoryUseCase)
final getChatHistoryUseCaseProvider =
    AutoDisposeProvider<GetChatHistoryUseCase>.internal(
      getChatHistoryUseCase,
      name: r'getChatHistoryUseCaseProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$getChatHistoryUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetChatHistoryUseCaseRef =
    AutoDisposeProviderRef<GetChatHistoryUseCase>;
String _$getConversationsUseCaseHash() =>
    r'83ee68cae6703887d787d9977f407564d4344321';

/// See also [getConversationsUseCase].
@ProviderFor(getConversationsUseCase)
final getConversationsUseCaseProvider =
    AutoDisposeProvider<GetConversationsUseCase>.internal(
      getConversationsUseCase,
      name: r'getConversationsUseCaseProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$getConversationsUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetConversationsUseCaseRef =
    AutoDisposeProviderRef<GetConversationsUseCase>;
String _$createConversationUseCaseHash() =>
    r'c6adbcafa65b471c8f7ae71d0d43c178c5b490ab';

/// See also [createConversationUseCase].
@ProviderFor(createConversationUseCase)
final createConversationUseCaseProvider =
    AutoDisposeProvider<CreateConversationUseCase>.internal(
      createConversationUseCase,
      name: r'createConversationUseCaseProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$createConversationUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreateConversationUseCaseRef =
    AutoDisposeProviderRef<CreateConversationUseCase>;
String _$updateConversationHash() =>
    r'd6dff3ed925fa07ffaa3bbdd06b7c6a072779a69';

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

/// See also [updateConversation].
@ProviderFor(updateConversation)
const updateConversationProvider = UpdateConversationFamily();

/// See also [updateConversation].
class UpdateConversationFamily extends Family<AsyncValue<void>> {
  /// See also [updateConversation].
  const UpdateConversationFamily();

  /// See also [updateConversation].
  UpdateConversationProvider call(String conversationId, {String? title}) {
    return UpdateConversationProvider(conversationId, title: title);
  }

  @override
  UpdateConversationProvider getProviderOverride(
    covariant UpdateConversationProvider provider,
  ) {
    return call(provider.conversationId, title: provider.title);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'updateConversationProvider';
}

/// See also [updateConversation].
class UpdateConversationProvider extends AutoDisposeFutureProvider<void> {
  /// See also [updateConversation].
  UpdateConversationProvider(String conversationId, {String? title})
    : this._internal(
        (ref) => updateConversation(
          ref as UpdateConversationRef,
          conversationId,
          title: title,
        ),
        from: updateConversationProvider,
        name: r'updateConversationProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$updateConversationHash,
        dependencies: UpdateConversationFamily._dependencies,
        allTransitiveDependencies:
            UpdateConversationFamily._allTransitiveDependencies,
        conversationId: conversationId,
        title: title,
      );

  UpdateConversationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
    required this.title,
  }) : super.internal();

  final String conversationId;
  final String? title;

  @override
  Override overrideWith(
    FutureOr<void> Function(UpdateConversationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpdateConversationProvider._internal(
        (ref) => create(ref as UpdateConversationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
        title: title,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _UpdateConversationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateConversationProvider &&
        other.conversationId == conversationId &&
        other.title == title;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);
    hash = _SystemHash.combine(hash, title.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UpdateConversationRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;

  /// The parameter `title` of this provider.
  String? get title;
}

class _UpdateConversationProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with UpdateConversationRef {
  _UpdateConversationProviderElement(super.provider);

  @override
  String get conversationId =>
      (origin as UpdateConversationProvider).conversationId;
  @override
  String? get title => (origin as UpdateConversationProvider).title;
}

String _$deleteConversationHash() =>
    r'8b2f48d7936e7894ec3875efb910d6db483c32af';

/// See also [deleteConversation].
@ProviderFor(deleteConversation)
const deleteConversationProvider = DeleteConversationFamily();

/// See also [deleteConversation].
class DeleteConversationFamily extends Family<AsyncValue<void>> {
  /// See also [deleteConversation].
  const DeleteConversationFamily();

  /// See also [deleteConversation].
  DeleteConversationProvider call(String conversationId) {
    return DeleteConversationProvider(conversationId);
  }

  @override
  DeleteConversationProvider getProviderOverride(
    covariant DeleteConversationProvider provider,
  ) {
    return call(provider.conversationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deleteConversationProvider';
}

/// See also [deleteConversation].
class DeleteConversationProvider extends AutoDisposeFutureProvider<void> {
  /// See also [deleteConversation].
  DeleteConversationProvider(String conversationId)
    : this._internal(
        (ref) =>
            deleteConversation(ref as DeleteConversationRef, conversationId),
        from: deleteConversationProvider,
        name: r'deleteConversationProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$deleteConversationHash,
        dependencies: DeleteConversationFamily._dependencies,
        allTransitiveDependencies:
            DeleteConversationFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  DeleteConversationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  Override overrideWith(
    FutureOr<void> Function(DeleteConversationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeleteConversationProvider._internal(
        (ref) => create(ref as DeleteConversationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _DeleteConversationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteConversationProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DeleteConversationRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _DeleteConversationProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with DeleteConversationRef {
  _DeleteConversationProviderElement(super.provider);

  @override
  String get conversationId =>
      (origin as DeleteConversationProvider).conversationId;
}

String _$searchConversationsHash() =>
    r'ccf4fefd8d22613d751edaf439df3a0475ac48bc';

/// See also [searchConversations].
@ProviderFor(searchConversations)
const searchConversationsProvider = SearchConversationsFamily();

/// See also [searchConversations].
class SearchConversationsFamily extends Family<AsyncValue<List<dynamic>>> {
  /// See also [searchConversations].
  const SearchConversationsFamily();

  /// See also [searchConversations].
  SearchConversationsProvider call(String query) {
    return SearchConversationsProvider(query);
  }

  @override
  SearchConversationsProvider getProviderOverride(
    covariant SearchConversationsProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchConversationsProvider';
}

/// See also [searchConversations].
class SearchConversationsProvider
    extends AutoDisposeFutureProvider<List<dynamic>> {
  /// See also [searchConversations].
  SearchConversationsProvider(String query)
    : this._internal(
        (ref) => searchConversations(ref as SearchConversationsRef, query),
        from: searchConversationsProvider,
        name: r'searchConversationsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$searchConversationsHash,
        dependencies: SearchConversationsFamily._dependencies,
        allTransitiveDependencies:
            SearchConversationsFamily._allTransitiveDependencies,
        query: query,
      );

  SearchConversationsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<dynamic>> Function(SearchConversationsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchConversationsProvider._internal(
        (ref) => create(ref as SearchConversationsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<dynamic>> createElement() {
    return _SearchConversationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchConversationsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchConversationsRef on AutoDisposeFutureProviderRef<List<dynamic>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchConversationsProviderElement
    extends AutoDisposeFutureProviderElement<List<dynamic>>
    with SearchConversationsRef {
  _SearchConversationsProviderElement(super.provider);

  @override
  String get query => (origin as SearchConversationsProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

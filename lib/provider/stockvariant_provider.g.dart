// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stockvariant_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stockVariantsHash() => r'f2a52f512c737eeb2916ac33d4c32c190a8b0bb2';

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

abstract class _$StockVariants
    extends BuildlessAutoDisposeAsyncNotifier<List<StockProduct>> {
  late final int selectedItemId;

  FutureOr<List<StockProduct>> build(
    int selectedItemId,
  );
}

/// See also [StockVariants].
@ProviderFor(StockVariants)
const stockVariantsProvider = StockVariantsFamily();

/// See also [StockVariants].
class StockVariantsFamily extends Family<AsyncValue<List<StockProduct>>> {
  /// See also [StockVariants].
  const StockVariantsFamily();

  /// See also [StockVariants].
  StockVariantsProvider call(
    int selectedItemId,
  ) {
    return StockVariantsProvider(
      selectedItemId,
    );
  }

  @override
  StockVariantsProvider getProviderOverride(
    covariant StockVariantsProvider provider,
  ) {
    return call(
      provider.selectedItemId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'stockVariantsProvider';
}

/// See also [StockVariants].
class StockVariantsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    StockVariants, List<StockProduct>> {
  /// See also [StockVariants].
  StockVariantsProvider(
    int selectedItemId,
  ) : this._internal(
          () => StockVariants()..selectedItemId = selectedItemId,
          from: stockVariantsProvider,
          name: r'stockVariantsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$stockVariantsHash,
          dependencies: StockVariantsFamily._dependencies,
          allTransitiveDependencies:
              StockVariantsFamily._allTransitiveDependencies,
          selectedItemId: selectedItemId,
        );

  StockVariantsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.selectedItemId,
  }) : super.internal();

  final int selectedItemId;

  @override
  FutureOr<List<StockProduct>> runNotifierBuild(
    covariant StockVariants notifier,
  ) {
    return notifier.build(
      selectedItemId,
    );
  }

  @override
  Override overrideWith(StockVariants Function() create) {
    return ProviderOverride(
      origin: this,
      override: StockVariantsProvider._internal(
        () => create()..selectedItemId = selectedItemId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        selectedItemId: selectedItemId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<StockVariants, List<StockProduct>>
      createElement() {
    return _StockVariantsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StockVariantsProvider &&
        other.selectedItemId == selectedItemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, selectedItemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StockVariantsRef
    on AutoDisposeAsyncNotifierProviderRef<List<StockProduct>> {
  /// The parameter `selectedItemId` of this provider.
  int get selectedItemId;
}

class _StockVariantsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<StockVariants,
        List<StockProduct>> with StockVariantsRef {
  _StockVariantsProviderElement(super.provider);

  @override
  int get selectedItemId => (origin as StockVariantsProvider).selectedItemId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

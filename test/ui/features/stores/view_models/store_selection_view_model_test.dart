import 'package:flutter_test/flutter_test.dart';
import 'package:test_retail_off/data/repositories/shop_repository.dart';
import 'package:test_retail_off/domain/models/shop.dart';
import 'package:test_retail_off/domain/shops_sheet.dart';
import 'package:test_retail_off/ui/features/stores/view_models/store_selection_view_model.dart';

void main() {
  group('StoreSelectionViewModel', () {
    const shops = [
      Shop(id: '1', name: 'North'),
      Shop(id: '2', name: 'South'),
    ];

    test('restores the saved store and updates the header', () async {
      final preferences = MemoryStorePreferences('2');
      final viewModel = StoreSelectionViewModel(
        shopRepository: FakeShopRepository(shops),
        preferences: preferences,
      );

      await viewModel.load();

      expect(viewModel.appBarTitle, 'South');
      expect(viewModel.selected?.id, '2');
      expect(viewModel.errorMessage, isNull);
    });

    test('persists the store chosen in the dropdown', () async {
      final preferences = MemoryStorePreferences(null);
      final viewModel = StoreSelectionViewModel(
        shopRepository: FakeShopRepository(shops),
        preferences: preferences,
      );
      await viewModel.load();

      await viewModel.selectStore(shops.first);

      expect(viewModel.appBarTitle, 'North');
      expect(preferences.savedId, '1');
    });

    test('shows the spreadsheet error and clears it on a successful retry', () async {
      final repository = FakeShopRepository(
        shops,
        error: const ShopLoadException('The shops spreadsheet was not found.'),
      );
      final viewModel = StoreSelectionViewModel(
        shopRepository: repository,
        preferences: MemoryStorePreferences(null),
      );

      await viewModel.load();
      expect(viewModel.errorMessage, contains('not found'));
      expect(viewModel.shops, isEmpty);

      repository.error = null;
      await viewModel.load();

      expect(viewModel.errorMessage, isNull);
      expect(viewModel.shops, shops);
    });
  });
}

class FakeShopRepository implements ShopRepository {
  FakeShopRepository(this.shops, {this.error});

  final List<Shop> shops;
  ShopLoadException? error;

  @override
  Future<List<Shop>> loadShops() async {
    final error = this.error;
    if (error != null) {
      throw error;
    }
    return shops;
  }
}

class MemoryStorePreferences implements StorePreferenceRepository {
  MemoryStorePreferences(this.savedId);

  String? savedId;

  @override
  Future<void> clear() async {
    savedId = null;
  }

  @override
  Future<String?> readSelectedStoreId() async => savedId;

  @override
  Future<void> saveSelectedStoreId(String id) async {
    savedId = id;
  }
}

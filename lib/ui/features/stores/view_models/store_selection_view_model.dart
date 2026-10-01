import 'package:flutter/foundation.dart';

import '../../../../data/repositories/shop_repository.dart';
import '../../../../domain/models/shop.dart';
import '../../../../domain/shops_sheet.dart';

/// Loads shops and remembers the store chosen in the dropdown.
class StoreSelectionViewModel extends ChangeNotifier {
  StoreSelectionViewModel({
    required this.shopRepository,
    required this.preferences,
  });

  final ShopRepository shopRepository;
  final StorePreferenceRepository preferences;

  List<Shop> shops = const [];
  Shop? selected;
  String? errorMessage;
  var loading = false;

  String get appBarTitle => selected?.name ?? 'Select a store';

  Future<void> load() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final loaded = await shopRepository.loadShops();
      final savedId = await preferences.readSelectedStoreId();
      shops = loaded;
      selected = _shopWithId(loaded, savedId);
    } on ShopLoadException catch (error) {
      shops = const [];
      selected = null;
      errorMessage = error.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> selectStore(Shop? shop) async {
    if (shop == null) {
      return;
    }
    selected = shop;
    errorMessage = null;
    notifyListeners();
    try {
      await preferences.saveSelectedStoreId(shop.id);
    } on Object {
      errorMessage = 'Could not save the selected store on this device.';
      notifyListeners();
    }
  }

  Future<void> clear() async {
    shops = const [];
    selected = null;
    errorMessage = null;
    loading = false;
    await preferences.clear();
    notifyListeners();
  }

  Shop? _shopWithId(List<Shop> loaded, String? id) {
    if (id == null) {
      return null;
    }
    for (final shop in loaded) {
      if (shop.id == id) {
        return shop;
      }
    }
    return null;
  }
}

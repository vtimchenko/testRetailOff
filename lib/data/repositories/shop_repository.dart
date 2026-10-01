import '../../domain/models/shop.dart';

/// Loads stores from the shared shops spreadsheet.
abstract class ShopRepository {
  Future<List<Shop>> loadShops();
}

/// Remembers the last selected store on this device.
abstract class StorePreferenceRepository {
  Future<String?> readSelectedStoreId();

  Future<void> saveSelectedStoreId(String id);

  Future<void> clear();
}

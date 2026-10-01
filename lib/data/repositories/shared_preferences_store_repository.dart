import 'package:shared_preferences/shared_preferences.dart';

import 'shop_repository.dart';

/// Stores the selected shop id in [SharedPreferences].
class SharedPreferencesStoreRepository implements StorePreferenceRepository {
  SharedPreferencesStoreRepository(this._preferences);

  static const selectedStoreIdKey = 'selected_store_id';

  final SharedPreferences _preferences;

  @override
  Future<String?> readSelectedStoreId() async {
    return _preferences.getString(selectedStoreIdKey);
  }

  @override
  Future<void> saveSelectedStoreId(String id) {
    return _preferences.setString(selectedStoreIdKey, id);
  }

  @override
  Future<void> clear() {
    return _preferences.remove(selectedStoreIdKey);
  }
}
